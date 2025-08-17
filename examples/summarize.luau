local internalBench = require("./Bench")
local benchPrecision = require("./Bench/Print").precision

type BenchData = internalBench.BenchData

local benchMethods = getmetatable(internalBench(function() end)).__index

-- Shorter print message (somewhat aligned)
function benchMethods:summarize(name: string)
	self.Name = name
	
	-- assume name is 14 chars or less
	print(`{name}{string.rep(" ", 14 - #name)} {
		benchPrecision(self.Speed.Median, 4)
	} s {
		benchPrecision(self.Memory.Average, 4)
	} kB`)
	return self
end

type SummarizedBenchData = BenchData & {
	summarize: typeof(benchMethods.summarize)
}

local function bench(fn: (...any)->(any), ...: any)
	return internalBench(fn, ...) :: SummarizedBenchData
end

bench(function() end)
	:summarize("nothing")

bench(function() return math.exp(2) end)
	:summarize("math.exp")

bench(function() return buffer.create(2) end)
	:summarize("buffer.create")

--[[
	Final notes:
		Bench does not rely on any of its built-in functions, like 
			compare, print, withName.  These can be altered 
			or removed entirely.
		Internal functions are provided for reference and convenience.
]]--