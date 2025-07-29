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
		value = '0e0'
	else
		local exp = math.log10(math.abs(x)) // 1
		value = x / math.pow(10, exp)..'e'..exp
		if value:find("nan") then
			value = '0e0'
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

-- new to replace
local function metricString(data: number, other: number?, name: string)
	if data ~= 0 and (if other and other ~= 0 then true else not other) then
		
	end
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
	
	if data.Minimum ~= 0 
		and (if other and other.Minimum ~= 0 then true else not other)
	then
		str ..= `\n        Min:    {
			if other then math.sign(data.Minimum) == 1 and "+" or "" else ""
		}{ precision(data.Minimum, 4) }{
			if other then `  ({ math.sign(other.Minimum) == 1 and "+" or "" }{ math.round(other.Minimum) }%)`
			else ""
		}`
	end
	if data.Low ~= 0 
		and (if other and other.Low ~= 0 then true else not other)
	then
		str ..= `\n        Low:    {
			if other then math.sign(data.Low) == 1 and "+" or "" else ""
		}{ precision(data.Low, 4) }{
			if other then `  ({ math.sign(other.Low) == 1 and "+" or "" }{ math.round(other.Low) }%)`
			else ""
		}`
	end
	if data.Median ~= 0 
		and (if other and other.Median ~= 0 then true else not other)
	then
		str ..= `\n        Median: {
			if other then math.sign(data.Median) == 1 and "+" or "" else ""
		}{ precision(data.Median, 4) }{
			if other then `  ({ math.sign(other.Median) == 1 and "+" or "" }{ math.round(other.Median) }%)`
			else ""
		}`
	end
	if data.Average ~= 0 
		and (if other and other.Average ~= 0 then true else not other)
	then
		str ..= `\n        Avg:    {
			if other then math.sign(data.Average) == 1 and "+" or "" else ""
		}{ precision(data.Average, 4) }{
			if other then `  ({ math.sign(other.Average) == 1 and "+" or "" }{ math.round(other.Average) }%)`
			else ""
		}`
	end
	if data.High ~= 0 
		and (if other and other.High ~= 0 then true else not other)
	then
		str ..= `\n        High:   {
			if other then math.sign(data.High) == 1 and "+" or "" else ""
		}{ precision(data.High, 4) }{
			if other then `  ({ math.sign(other.High) == 1 and "+" or "" }{ math.round(other.High) }%)`
			else ""
		}`
	end
	if data.Maximum ~= 0 
		and (if other and other.Maximum ~= 0 then true else not other)
	then
		str ..= `\n        Max:    {
			if other then math.sign(data.Maximum) == 1 and "+" or "" else ""
		}{ precision(data.Maximum, 4) }{
			if other then `  ({ math.sign(other.Maximum) == 1 and "+" or "" }{ math.round(other.Maximum) }%)`
			else ""
		}`
	end
	if data.Total ~= 0 
		and (if other and other.Total ~= 0 then true else not other)
	then
		str ..= `\n        Total:  {
			if other then math.sign(data.Total) == 1 and "+" or "" else ""
		}{ precision(data.Total, 4) }{
			if other then `  ({ math.sign(other.Total) == 1 and "+" or ""}{ math.round(other.Total) }%)`
			else ""
		}`
	end
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