local bench = require("@Bench")

--[[
	We want to go through all values in a table recursively.
	What is the fastest approach?
		We often hear that functional recursion is slow, but is it really?
]]

function whilerecursion(t)
	local backtrackIndex = { nil }
	local backtrackTable = { t }
	local len = 1
	local currTab = t
	local i, v = next(t, nil)
	while i ~= nil do
		if type(v) == "table" then
			backtrackIndex[len] = i
			backtrackTable[len + 1] = v
			currTab = v
			len += 1
			i = nil
		end
		i, v = next(currTab, i)
		while i == nil and len > 1 do
			len -= 1
			currTab = backtrackTable[len]
			i, v = next(currTab, backtrackIndex[len])
		end
	end
end

local function functionalrecursion(t)
	for i, v in t do
		if type(v) == "table" then
			functionalrecursion(v)
			continue
		end
	end
end

-- try whatever
local data = {
	{ 1, 2, 3, 4 },
	{ 5, 6, 7, 8 },
	{ 9, 1, 2, 3 },
	{ 4, 5, 6, 7 },
	{ 8, 9, 1, 2 },
}

bench(whilerecursion, data):withName("whilerecursion"):print()

bench(functionalrecursion, data):withName("functionalrecursion"):print()

--[[
	Final note:
		The implementation of the recursion without using functions
		is not optimal.  While next(...) is already much slower than the 
		for loop variant.
]]
