--!optimize 2
--!strict
local Variant = require("./Variant")

type BenchData = Variant.BenchData
type BenchMetric = Variant.BenchMetric
type BenchCompareData = Variant.BenchCompareData
type SimpleBenchMetric = Variant.SimpleBenchMetric

local Print = {}

@native
local function precision(x: number, n: number)
	if x ~= x then
		return "nan"
	end
	if x == math.huge or x == -math.huge then
		return "inf"
	end
	-- removed support for negative values since we abs them prior at input
	if x < 1e-9 then
		return "0"
	end
	
	local exp = math.log10(x) // 1
	if exp >= 0 then
		-- ensure x is rounded to correct value
		local decimalRound = math.pow(10, exp+1)
		return (math.round(x * decimalRound) / decimalRound) .. ""
	end
	local value = x / math.pow(10, exp)
	local strValue = tostring(value)
	local len = #strValue

	if len == n + 1 then
		return strValue .. 'e' .. exp
	elseif len > n + 1 then
		return string.sub(strValue, 1, n + 1) .. 'e' .. exp
	else
		-- len < n + 1
		local precZero = value % 1 == 0 and string.rep("0", n + 1 - len)
			or "." .. string.rep("0", n - len)
		return strValue .. precZero .. 'e' .. exp
	end
end

local function metricString(data: number, other: number?, name: string)
	if data == 0 or other and other == 0 then
		return ""
	end
	local dataStr = precision(data >= 0 and data or -data, 4)
	return `\n        {name}{
		if data < 0 then "-" else if other then "+" else ""
	}{ dataStr }{
		if other then `{
			string.rep(" ", 10 - #dataStr)
		}({ 
			other > 0 and "+" or "" 
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
local function metricPrint(data: SimpleBenchMetric, other: SimpleBenchMetric?)
	-- If any aspect is 0 we should NOT display it
	local str = metricString(data.Minimum, other and other.Minimum, "Min:    ")
		.. metricString(data.Low, other and other.Low, "Low:    ")
		.. metricString(data.Median, other and other.Median, "Median: ")
		.. metricString(data.Average, other and other.Average, "Avg:    ")
		.. metricString(data.High, other and other.High, "High:   ")
		.. metricString(data.Maximum, other and other.Maximum, "Max:    ")
		.. metricString(data.Total, other and other.Total, "Total:  ")
	
	-- Will occur for memory, and RARELY for speed
	if str == "" then
		str = if other then "\n        [No difference]" 
			else "\n        [Non-existant]"
	end
	
	return str
end
local function histPrint(data: BenchMetric)
	local str = ""
	local hist = data.Histogram
	local low = data.Low
	local range = hist.Range
	local boxCount = range == 0 and 1 or 8
	
	for i = 1, boxCount do
		local count = hist[i]
		
		if count == 0 then
			continue
		end
		
		local strCount = tostring(count)
		
		str ..= `\n            {
			strCount .. string.rep(" ", 6 - #strCount)
		}({
			precision(low + range * (i - 1), 4)
		} to {
			precision(low + range * i, 4)
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

--[[
	Converts a number into a string.
	@ If the number is below 1, the specified decimal precision is applied.
	
	@param x the number
	@param n the precision amount
	
	@return the string associated with the number
]]--
Print.precision = precision

return Print
