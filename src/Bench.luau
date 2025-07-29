--!optimize 2
--!strict

local Variant = require("./internal/Variant")
local Stats = require("./internal/Stats")
local benchPrint = require("./internal/Print").benchPrint
local benchCompare = require("./internal/Compare")

type BenchData = Variant.BenchData

Variant = nil

--[[
	Applies the specified name to the benchmark data.
	
	@param self benchmark data
	@param name the name

	@return the input benchmark data
]]--
local function withName(self: BenchData, name: string): BenchData
	self.Name = name
	return self
end

--[[
	Processes the output and modifies the existing output.
	
	@param self benchmark data
	@param fn the function to process the output with whose return value 
		becomes the new output value

	@return the input benchmark data
]]--
local function updateOutput(self: BenchData, fn: (output: any)->(any)?): BenchData
	self.Output = fn and fn(self.Output) or nil
	return self
end

--[[
	Runs and collects speed and memory metrics associated with the 
		provided function.  The data is then partially statistically analyzed, 
		excluding standard deviation.
	
	@param fn the function to benchmark
	@param ... the arguments to send to the benchmarked function
	
	@return benchmark data associated with the specified function
]]--
return function(fn: (...any)->(any), ...: any): BenchData
	local data: BenchData = {
		Name = "",
		Output = nil,
		Speed = {
			Data = {},
			Total = 0, Average = 0,
			Minimum = 0, Maximum = 0,
			Low = 0, Median = 0, High = 0,
			Histogram = {
				-- 8 parts
				0,0,0,0,0,0,0,0,
				Range = 0
			}
		},
		Memory = {
			Data = {},
			Total = 0, Average = 0,
			Minimum = 0, Maximum = 0,
			Low = 0, Median = 0, High = 0,
			Histogram = {
				-- 8 parts
				0,0,0,0,0,0,0,0,
				Range = 0
			}
		},
		print = benchPrint,
		compare = benchCompare,
		withName = withName,
		updateOutput = updateOutput
	}
	
	local speed = data.Speed.Data
	local memory = data.Memory.Data
	
	local initialTime = os.clock()
	
	for i=1, 2_048 do
		local startMemory = gcinfo()
		local startTime = os.clock()
		local output = fn(...) -- ensure if there is an output, Luau doesn't somehow optimize it away
		local endTime = os.clock() - startTime
		memory[i] = gcinfo() - startMemory
		speed[i] = endTime
		
		if i == 1 then
			data.Output = output
		end
		-- Amount must be 30+ for statistical significance
		if i < 30 then
			continue
		end
		
		-- Total time elapsed should be less than 5 seconds
		if os.clock() - initialTime > 5.0 then
			print(`TESTED: {i} times and took {os.clock() - initialTime} seconds`)
			break
		end
	end
	
	local lenMemory = #memory
	
	-- Sort data
	table.sort(speed)
	table.sort(memory)
	
	-- All negative memory values will be removed
	local lastNegPos = 0
	for i,v in memory do
		if v >= 0 then
			lastNegPos = i
			break
		end
	end
	
	table.move(memory, lastNegPos, lenMemory, 1, memory)
	
	-- remove copies
	for i = lenMemory - lastNegPos, lenMemory do
		memory[i] = nil
	end
	
	-- Standard deviation is NOT included
	Stats.metrics(data.Speed)
	Stats.metrics(data.Memory)
	
	-- Histogram Outlook
	Stats.hist(data.Speed)
	Stats.hist(data.Memory)
	
	return data
end