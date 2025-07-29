--!optimize 2
--!strict
local Variant = require("./Variant")

type BenchMetric = Variant.BenchMetric

Variant = nil

local Stats = {}

@native
function sum(t: {number})
	local total = 0
	for _,v in t do
		total += v
	end
	return total
end

@native
function Stats.metrics(data: BenchMetric)
	local dataTab = data.Data
	local lenData = #dataTab

	data.Total = sum(dataTab)
	data.Average = data.Total / lenData
	data.Minimum = dataTab[1]
	data.Maximum = dataTab[lenData]
	data.Low = dataTab[(0.01 * lenData) // 1] or dataTab[1]
	data.Median = dataTab[(0.5 * lenData) // 1]
	data.High = dataTab[(0.99 * lenData) // 1]
end

@native
function Stats.hist(data: BenchMetric)
	local boxCount = 8

	data.Histogram.Range = (data.High - data.Low) / boxCount

	local hist = data.Histogram
	local histLow = data.Low
	local histRange = data.Histogram.Range

	if histRange == 0 then
		hist[1] = #data.Data
		return
	end

	for i,v in data.Data do
		-- place each value in a box
		local box = (v - histLow) // histRange
		if box < 0 then
			continue
		end
		if box > boxCount then
			continue
		end
		-- values matching High
		if box == boxCount then
			hist[box] += 1
			continue
		end
		hist[box+1] += 1
	end
end

return Stats