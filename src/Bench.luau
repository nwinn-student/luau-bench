--!optimize 2
--!strict

local Variant = require("./internal/Variant")
local Stats = require("./internal/Stats")
local benchPrint = require("./internal/Print").benchPrint
local benchCompare = require("./internal/Compare")

type BenchData = Variant.BenchData

Variant = nil

local function withName(self: BenchData, name: string): BenchData
	self.Name = name
	return self
end

return function(fn: (...any)->(), ...: any): BenchData
	local data: BenchData = {
		Name = "",
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
	}
	
	local speed = data.Speed.Data
	local memory = data.Memory.Data
	
	local initialTime = os.clock()
	
	for i=1, 1_024 do
		local startMemory = gcinfo()
		local startTime = os.clock()
		fn(...)
		local endTime = os.clock() - startTime
		memory[i] = gcinfo() - startMemory
		speed[i] = endTime
				
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
	
	-- Lengths
	local lenSpeed = #speed
	local lenMemory = #memory
	
	-- Sort data
	table.sort(speed)
	table.sort(memory)
	
	-- All negative memory values will be removed
	local lastNegPos = 0
	for i = 1, lenMemory do
		if memory[i] >= 0 then
			lastNegPos = i
			break
		end
	end
	
	table.move(memory, lastNegPos, lenMemory, 1, memory)
	
	-- remove copies
	for i = lenMemory - lastNegPos, lenMemory do
		memory[i] = nil
	end
	lenMemory = #memory
		
	-- Standard deviation is NOT included
	Stats.metrics(data.Speed)
	Stats.metrics(data.Memory)
	
	-- Histogram Outlook
	Stats.hist(data.Speed)
	Stats.hist(data.Memory)
	
	return data
end