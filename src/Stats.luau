--!optimize 2
--!strict
local Variant = require("./Variant")

type BenchMetric = Variant.BenchMetric

--[[
	MODIFIABLE CONSTANT
	
	The percentage away from the extreme ends 
	high and low value will be.
	
	The default value (1) means that:
	| Low will represent the lowest 1% of values 
	| High will represent the highest 1% of values
	
	Values between 0 and 10 are recommended.
]]
local DIST_PERC = 1

local LOW_PERC = DIST_PERC / 100
local HIGH_PERC = (100 - DIST_PERC) / 100

local Stats = {}

function Stats.updateDistance(distancePercentage: number)
	DIST_PERC = distancePercentage
	LOW_PERC = DIST_PERC / 100
	HIGH_PERC = (100 - DIST_PERC) / 100
end

@native
function sum(t: { number })
	local total = 0
	for _, v in t do
		total += v
	end
	return total
end

@native
function Stats.metrics(data: BenchMetric)
	local dataTab = data.Data
	local lenData = #dataTab

	data.Minimum = dataTab[1]
	data.Maximum = dataTab[lenData]

	local lowIndex = (LOW_PERC * lenData) // 1
	data.Low = dataTab[lowIndex ~= 0 and lowIndex or 1]
	data.Median = dataTab[(0.5 * lenData) // 1]
	data.High = dataTab[(HIGH_PERC * lenData) // 1]
end

@native
function Stats.hist(data: BenchMetric)
	local boxCount = 8

	local hist = data.Histogram
	local histLow = data.Low
	local histHigh = data.High
	local histRange = (histHigh - histLow) / boxCount
	hist.Range = histRange

	local len = #data.Data

	if histRange == 0 then
		hist[1] = len
		data.Total = sum(data.Data)
		data.Average = data.Total / len
		return
	end

	local total = 0
	local cache = 0
	local cacheBox = 1
	local priorV = -2 ^ 32
	local lowerBound = histLow
	local upperBound = histLow + histRange

	for _, v in data.Data do
		total += v

		if v == priorV then
			cache += 1
			continue
		end

		if lowerBound <= v and v <= upperBound then
			cache += 1
			priorV = v
			continue
		end

		if v < histLow or v > histHigh then
			-- entered infrequently
			continue
		end

		local box = cacheBox
		repeat
			lowerBound += histRange
			upperBound += histRange
			box += 1
		until lowerBound <= v and v <= upperBound

		hist[cacheBox] = cache
		cache = 1
		cacheBox = box

		priorV = v
	end

	if cacheBox == boxCount then
		hist[boxCount] = cache
	end

	data.Total = total
	data.Average = total / len
end

return Stats
