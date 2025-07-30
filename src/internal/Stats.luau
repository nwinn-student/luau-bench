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
	
	data.Histogram.Range = (data.High - data.Low) / boxCount
	
	local hist = data.Histogram
	local histLow = data.Low
	local histRange = data.Histogram.Range
	
	local total = 0
	local len = #data.Data
	
	if histRange == 0 then
		hist[1] = len
		data.Total = sum(data.Data)
		data.Average = data.Total / len
		return
	end
	
	local cache = 0
	local cacheBox = 1
	
	for i,v in data.Data do
		total += v
		-- place each value in a box
		local box = (v - histLow) // histRange
		
		if box < 0 or box >= boxCount then
			-- values matching High, few get in here, so this can be slower
			if box == boxCount then
				if cacheBox == box then
					cache += 1
				else
					hist[cacheBox] = cache
					cache = 1
					cacheBox = box
				end
			end
			
			continue
		end
		
		if cacheBox == box + 1 then
			cache += 1
		else
			hist[cacheBox] = cache
			cache = 1
			cacheBox = box + 1
		end
	end
	
	if hist[cacheBox] == 0 then
		hist[cacheBox] = cache
	end
		
	-- maybe faster?
	data.Total = total
	data.Average = total / len
end

return Stats