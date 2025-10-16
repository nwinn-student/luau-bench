--!optimize 2
--!strict
local Variant = require("./Variant")
local benchComparePrint = require("./Print").benchComparePrint

type BenchData = Variant.BenchData
type BenchCompareData = Variant.BenchCompareData
type BenchCompareMetric = Variant.BenchCompareMetric
type SimpleBenchMetric = Variant.SimpleBenchMetric

-- higher value means worse
local function metricPerc(
	first: SimpleBenchMetric,
	second: SimpleBenchMetric,
	new: SimpleBenchMetric
)
	new.Total = 100 * (second.Total - first.Total) / first.Total
	new.Average = 100 * (second.Average - first.Average) / first.Average
	new.Minimum = 100 * (second.Minimum - first.Minimum) / first.Minimum
	new.Maximum = 100 * (second.Maximum - first.Maximum) / first.Maximum
	new.Low = 100 * (second.Low - first.Low) / first.Low
	new.Median = 100 * (second.Median - first.Median) / first.Median
	new.High = 100 * (second.High - first.High) / first.High
end

-- higher value means worse
local function metricExact(
	first: SimpleBenchMetric,
	second: SimpleBenchMetric,
	new: SimpleBenchMetric
)
	new.Total = second.Total - first.Total
	new.Average = second.Average - first.Average
	new.Minimum = second.Minimum - first.Minimum
	new.Maximum = second.Maximum - first.Maximum
	new.Low = second.Low - first.Low
	new.Median = second.Median - first.Median
	new.High = second.High - first.High
end

--[[
	Compares the statistical data between the first benchmark data and 
		all others.  The comparison is done in two parts, an exact comparison 
		and a percentage comparison.
	
	@param self the benchmark data to compare the rest against
	@param ... the benchmark data
	
	@return the comparison data
]]
return function(self: BenchData, ...: BenchData): BenchCompareData
	local data: BenchCompareData = {
		Name = self.Name,
		print = benchComparePrint,
	}

	local dataTab = {
		Total = 0,
		Average = 0,
		Minimum = 0,
		Maximum = 0,
		Low = 0,
		Median = 0,
		High = 0,
	}

	for i, v in { ... } do
		-- compare
		local key = v.Name

		-- the histogram section doesn't matter
		local value: BenchCompareMetric = {
			Name = key,
			Speed = {
				Data = v.Speed.Data,
				Histogram = v.Speed.Histogram,
				Exact = table.clone(dataTab),
				Percentage = table.clone(dataTab),
			},
			Memory = {
				Data = v.Memory.Data,
				Histogram = v.Memory.Histogram,
				Exact = table.clone(dataTab),
				Percentage = table.clone(dataTab),
			},
		}

		metricPerc(self.Speed, v.Speed, value.Speed.Percentage)
		metricPerc(self.Memory, v.Memory, value.Memory.Percentage)

		metricExact(self.Speed, v.Speed, value.Speed.Exact)
		metricExact(self.Memory, v.Memory, value.Memory.Exact)

		data[i] = value
	end
	return data
end
