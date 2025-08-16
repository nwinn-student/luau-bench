local bench = require("./Bench")

-- Shows that all are roughly the same
bench(function()
	
end):withName("nothing")
	:print()
	:compare(
		bench(function()
			do
				
			end
		end):withName("do"),
		-- Very useful for cases where you want to skip sections w/o returning
		-- and if statements make it messy
		bench(function()
			for i=1,1 do
				
			end
		end):withName("for")
	):print()

-- Shows that for i=1,1 is actually much slower

local n = 1_000 -- Change this to whatever, higher = better reflection

bench(function()
	for i=1, n do

	end
end):withName("nothing xN")
	:print()
	:compare(
		bench(function() -- No difference
			for i=1, n do
				do
					
				end
			end
		end):withName("do xN"),
		bench(function() -- 400% slower than nothing
			for i=1, n do
				for x=1,1 do
					
				end
			end
		end):withName("for xN")
	):print()

--[[
	Final notes:
		--!optimization 2 or @native may change results!
		--!optimize 2 makes for i=1,1 do ... end behave no slower!
		Results are subject to change as Luau evolves
]]--