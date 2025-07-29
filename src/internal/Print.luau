--!optimize 2
--!strict
local Variant = require("./Variant")

type BenchData = Variant.BenchData
type BenchMetric = Variant.BenchMetric
type BenchCompareData = Variant.BenchCompareData

Variant = nil


function precision(x: number, n: number)
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

local Print = {}

function metricPrint(data: BenchMetric, other: BenchMetric?)
	-- If any aspect is 0 we should NOT display it
	local str = ""
	
	if data.Minimum ~= 0 
		and (if other and other.Minimum ~= 0 then true else not other)
	then
		str ..= `\n        Min:    {precision(data.Minimum, 4)}{
			if other then "%  "..precision(other.Minimum, 4)
			else ""
		}`
	end
	if data.Low ~= 0 
		and (if other and other.Low ~= 0 then true else not other)
	then
		str ..= `\n        Low:    {precision(data.Low, 4)}{
			if other then "%  "..precision(other.Low, 4)
			else ""
		}`
	end
	if data.Median ~= 0 
		and (if other and other.Median ~= 0 then true else not other)
	then
		str ..= `\n        Median: {precision(data.Median, 4)}{
			if other then "%  "..precision(other.Median, 4)
			else ""
		}`
	end
	if data.Average ~= 0 
		and (if other and other.Average ~= 0 then true else not other)
	then
		str ..= `\n        Avg:    {precision(data.Average, 4)}{
			if other then "%  "..precision(other.Average, 4)
			else ""
		}`
	end
	if data.High ~= 0 
		and (if other and other.High ~= 0 then true else not other)
	then
		str ..= `\n        High:   {precision(data.High, 4)}{
			if other then "%  "..precision(other.High, 4)
			else ""
		}`
	end
	if data.Maximum ~= 0 
		and (if other and other.Maximum ~= 0 then true else not other)
	then
		str ..= `\n        Max:    {precision(data.Maximum, 4)}{
			if other then "%  "..precision(other.Maximum, 4)
			else ""
		}`
	end
	if data.Total ~= 0 
		and (if other and other.Total ~= 0 then true else not other)
	then
		str ..= `\n        Total:  {precision(data.Total, 4)}{
			if other then "%  "..precision(other.Total, 4)
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
	local str = `Comparing against {
		self.Name
	}...\n\n`
	
	for i,v in ipairs(self) do
		str ..= `Name: {
			v.Name
		}\n    Speed: {
			metricPrint(v.Speed.Percentage, v.Speed.Exact)
		}\n    Memory: {
			metricPrint(v.Memory.Percentage, v.Memory.Exact)
		}`
	end
	
	print(str)
end

return Print