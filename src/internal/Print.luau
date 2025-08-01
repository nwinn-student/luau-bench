--!optimize 2
--!strict
local Variant = require("./Variant")

type BenchData = Variant.BenchData
type BenchMetric = Variant.BenchMetric
type BenchCompareData = Variant.BenchCompareData

Variant = nil

local Print = {}

@native
local function precision(x: number, n: number)
	local value = nil
	
	local absX = math.abs(x)
	
	if absX < 1e-9 then
		return "0"
	else
		local exp = math.log10(absX) // 1

		if exp >= 0 then
			-- ensure x is rounded to correct value
			local decimalRound = math.pow(10, exp+1)
			return (math.round(x * decimalRound) / decimalRound) .. ""
		end
		value = x / math.pow(10, exp)..'e'..exp
		
		if value:find("nan") then
			return "nan"
		end
		if value:find("inf") then
			return "inf"
		end
	end
	local temp = value:split("e")
	local first = temp[1]
	if #first > n + 1 then
		first = first:sub(1, n + 1)
	elseif #first < n + 1 then
		first ..= not first:find(".") and "."
			.. string.rep("0", n - #first) or
			string.rep("0", n + 1 - #first)
	end
	return first..'e'..temp[2]
end

local function metricString(data: number, other: number?, name: string)
	if data == 0 or other and other == 0 then
		return ""
	end
	local dataStr = precision(math.abs(data), 4)
	return `\n        {name}:{string.rep(" ", 7 - #name)}{
		if math.sign(data) == -1 then "-" else if other then "+" else ""
	}{ dataStr }{
		if other then `{
			string.rep(" ", 10 - #dataStr)
		}({ 
			math.sign(other) == 1 and "+" or "" 
		}{ math.round(other * 10) / 10 }%)`
		else ""
	}`
end
--[[
	Regular:
		Min: 1.234e-5
	Compare:
		Min: +1.234e-5  (+15%)
]]
local function metricPrint(data: BenchMetric, other: BenchMetric?)
	-- If any aspect is 0 we should NOT display it
	local str = metricString(data.Minimum, other and other.Minimum, "Min")
		.. metricString(data.Low, other and other.Low, "Low")
		.. metricString(data.Median, other and other.Median, "Median")
		.. metricString(data.Average, other and other.Average, "Avg")
		.. metricString(data.High, other and other.High, "High")
		.. metricString(data.Maximum, other and other.Maximum, "Max")
		.. metricString(data.Total, other and other.Total, "Total")
	
	-- Will occur for memory, and RARELY for speed
	if str == "" then
		str = if other then "\n        [No difference]" 
			else "\n        [Non-existant]"
	end
	
	return str
end
local function histPrint(data: BenchMetric)
	local str = ""
	local boxCount = data.Histogram.Range == 0 and 1 or 8
	for i=1, boxCount do
		local count = data.Histogram[i]
		
		if count == 0 then
			continue
		end
		
		str ..= `\n            {
			count..string.rep(" ", 6 - #tostring(count))
		}({
			precision(data.Low + data.Histogram.Range * (i - 1), 4)
		} to {
			precision(data.Low + data.Histogram.Range * i, 4)
		})`
	end
	return str
end

--[[
	Formats and prints the benchmark data.
	
	@param self the input benchmark data

	@return the input benchmark data
]]--
function Print.benchPrint(self: BenchData): BenchData
	local str = `Name: {
		self.Name
	}\n    Speed: [seconds]{
		metricPrint(self.Speed)
	}\n        Histogram:{
		histPrint(self.Speed)
	}\n    Memory: [kB]{
		metricPrint(self.Memory)
	}\n        Histogram:{
		histPrint(self.Memory)
	}{ self.Output and "\n    " .. tostring(self.Output) or "" }`
	
	print(str)
	return self
end

--[[
	Formats and prints the comparison data.
	
	@param self the comparison data
]]--
function Print.benchComparePrint(self: BenchCompareData)
	local str = `\nComparing against {
		self.Name
	}...\n\n`
	
	for i,v in ipairs(self) do
		str ..= `Name: {
			v.Name
		}\n    Speed: [seconds]{
			metricPrint(v.Speed.Exact, v.Speed.Percentage)
		}\n    Memory: [kB]{
			metricPrint(v.Memory.Exact, v.Memory.Percentage)
		}\n`
	end
	
	print(str)
end

return Print