local bench = require("./Bench/Bench")

-- Shows that all are roughly the same
bench(function(a, b)
	return math.floor(a / b)
end, 500, 33):withName("math.floor")
	:print()
	:compare(
		bench(function(a, b)
			return a // b
		end, 500, 33):withName("floor division"),
		bench(function(a, b)
			local c = a / b
			return c - c % 1
		end, 500, 33):withName("mod division")
	):print()

-- Shows that // is faster than common alternatives

local n = 1_000 -- Change this to whatever, higher = better reflection

bench(function(a, b)
	for i=1, n do
		local c = math.floor(a / b)
	end
end, 500, 33):withName("math.floor xN")
	:print()
	:compare(
		bench(function(a, b) -- 35% faster than math.floor
			for i=1, n do
				local c = a // b
			end
		end, 500, 33):withName("floor division xN"),
		bench(function(a, b) -- 16% slower than math.floor
			for i=1, n do
				local c = a / b
				local d = c - c % 1
			end
		end, 500, 33):withName("mod division xN")
	):print()

--[[
	Final notes:
		--!optimization 2 or @native may change results! (optimize 2 yielded no change)
		Results are subject to change as Luau evolves
]]--