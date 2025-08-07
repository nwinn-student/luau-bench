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
	
	data.Minimum = dataTab[1]
	data.Maximum = dataTab[lenData]
	
	local lowIndex = (0.01 * lenData) // 1
	data.Low = dataTab[lowIndex ~= 0 and lowIndex or 1]
	data.Median = dataTab[(0.5 * lenData) // 1]
	data.High = dataTab[(0.99 * lenData) // 1]
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
	local priorV = -2^32
	
	for _,v in data.Data do
		total += v
		
		if v == priorV then
			cache += 1
			continue
		end
		if v < histLow or v >= histHigh then
			-- entered infrequently
			if v == histHigh then
				if cacheBox + 1 ~= boxCount then
					hist[cacheBox + 1] = cache
					cache = 1
				end
				cacheBox = boxCount - 1
				priorV = histHigh
			end
			continue
		end
		
		-- place each value in a box (very slow)
		local box = (v - histLow) // histRange
		
		if cacheBox == box then
			cache += 1
		else
			hist[cacheBox + 1] = cache
			cache = 1
			cacheBox = box
		end
		priorV = v
	end
	
	if cacheBox + 1 == boxCount then
		hist[boxCount] = cache
	end
		
	data.Total = total
	data.Average = total / len
end

return Stats