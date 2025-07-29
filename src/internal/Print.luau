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
	if math.abs(x) < 1e-9 then
		return "0"
	else
		local exp = math.log10(math.abs(x)) // 1
		value = x / math.pow(10, exp)..'e'..exp

		if exp >= 0 then
			-- ensure x is rounded to correct value
			return math.round(x * math.pow(10, exp+1)) / math.pow(10, exp+1)..""
		end
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
		first = first:sub(1, n+1)
	elseif #first < n + 1 then
		if first:split(".")[1] == first then
			first ..= '.'
		end
		repeat 
			first ..= '0'
		until #first == n + 1
	end
	return first..'e'..temp[2]
end

local function metricString(data: number, other: number?, name: string)
	local str = ""
	if data ~= 0 and (if other and other ~= 0 then true else not other) then
		local dataStr = precision(math.abs(data), 4)
		str = `\n        {name}:{string.rep(" ", 7 - #name)}{
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
	return str
end
--[[
	Regular:
		Min: 1.234e-5
	Compare:
		Min: +1.234e-5  (+15%)
]]
local function metricPrint(data: BenchMetric, other: BenchMetric?)
	-- If any aspect is 0 we should NOT display it
	local str = ""
	
	str ..= metricString(data.Minimum, other and other.Minimum, "Min")
	str ..= metricString(data.Low, other and other.Low, "Low")
	str ..= metricString(data.Median, other and other.Median, "Median")
	str ..= metricString(data.Average, other and other.Average, "Avg")
	str ..= metricString(data.High, other and other.High, "High")
	str ..= metricString(data.Maximum, other and other.Maximum, "Max")
	str ..= metricString(data.Total, other and other.Total, "Total")
	
	return str
end
local function histPrint(data: BenchMetric)
	local str = ""
	local boxCount = data.Histogram.Range == 0 and 1 or 8
	for i=1, boxCount do
		if data.Histogram[i] == 0 then
			continue
		end
		local count = data.Histogram[i]
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

function Print.benchPrint(self: BenchData): BenchData
	local str = `Name: {
		self.Name
	}\n    Speed: {
		metricPrint(self.Speed)
	}\n        Histogram:{
		histPrint(self.Speed)
	}\n    Memory: {
		metricPrint(self.Memory)
	}\n        Histogram:{
		histPrint(self.Memory)
	}`
	print(str)
	return self
end

function Print.benchComparePrint(self: BenchCompareData)
	local str = `\nComparing against {
		self.Name
	}...\n\n`
	
	for i,v in ipairs(self) do
		str ..= `Name: {
			v.Name
		}\n    Speed: {
			metricPrint(v.Speed.Exact, v.Speed.Percentage)
		}\n    Memory: {
			metricPrint(v.Memory.Exact, v.Memory.Percentage)
		}`
	end
	
	print(str)
end

return Print