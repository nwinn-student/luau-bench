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
	
	local total = 0
	
	if histRange == 0 then
		hist[1] = #data.Data
		data.Total = sum(data.Data)
		data.Average = data.Total / #data.Data
		return
	end
	
	-- ... very... fun.. nope, doesnt make faster
	local box1 = 0
	local box2 = 0
	local box3 = 0
	local box4 = 0
	local box5 = 0
	local box6 = 0
	local box7 = 0
	local box8 = 0
	
	-- maybe we try using one to temp store the amount, and when it changes we update hist?
		
	for i,v in data.Data do
		total += v
		-- place each value in a box
		local box = (v - histLow) // histRange
		
		if box < 0 or box >= boxCount then
			-- values matching High, few get in here, so this can be slower
			if box == boxCount then
				if box == 1 then box1 += 1
				elseif box == 2 then box2 += 1
				elseif box == 3 then box3 += 1
				elseif box == 4 then box4 += 1
				elseif box == 5 then box5 += 1
				elseif box == 6 then box6 += 1
				elseif box == 7 then box7 += 1
				elseif box == 8 then box8 += 1
				end
			end
			continue
		end
		
		box += 1
		
		if box == 3 then box3 += 1
		elseif box == 4 then box4 += 1
		elseif box == 5 then box5 += 1
		elseif box == 6 then box6 += 1
		elseif box == 2 then box2 += 1
		elseif box == 7 then box7 += 1
		elseif box == 1 then box1 += 1
		elseif box == 8 then box8 += 1
		end
	end
	
	hist[1] = box1
	hist[2] = box2
	hist[3] = box3
	hist[4] = box4
	hist[5] = box5
	hist[6] = box6
	hist[7] = box7
	hist[8] = box8
	
	-- maybe faster?
	data.Total = total
	data.Average = total / #data.Data
end

return Stats