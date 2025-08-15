# Bench

#### Table of Contents
- [Purpose](#purpose)
- [Requirements](#requirements)
- [Usage Cases](#usage-cases)
- [Example](#example)
- [Performance](#performance)
- [Design](#design)

## Purpose

Bench is a general performance benchmarker that performs simple calculations with the obtained data and lets the user perform other necessary calculations.  Bench handles the number of times to run the function internally, capping at 5 seconds or 2048 runs, with a minimum of 30 runs.  Bench does not keep data with negative values, such as memory when it has been GC'ed or when your function transcends time itself. 

## Requirements
[Luau 0.670+](https://github.com/luau-lang/luau/releases): As internal methods may shift to use @self to refer to each other.

## Credit
The idea to add a histogram came from [Benchmarker](https://boatbomber.itch.io/benchmarker).  
You may notice that the results for the example comparing table.insert and #t + 1 differ from those in here.  That is due to the cost of calling a function

## Usage Cases
A user needs to measure how expensive and fast a function is, they will use Bench to obtain these metrics.

A user needs to compare how different versions of a function perform, they will use Bench to perform metrics on each function, then Bench will again be used to obtain a comparison.

## Example

More in-depth examples can be found in [examples](./examples).


```luau
-- General benchmarking case
local tab = {}
bench(table.insert, tab, 0)
	:withName("Insert"):print()

--[[
Name: Insert
    Speed: [seconds]
        Min:    9.999e-8
        Low:    9.999e-8
        Median: 1.000e-7
        Avg:    1.117e-7
        High:   2.000e-7
        Max:    5.500e-6
        Total:  2.288e-4
        Histogram:
            1959  (9.999e-8 to 1.124e-7)
            76    (1.875e-7 to 2.000e-7)
    Memory: [kB]
        Avg:    4.398e-3
        Max:    4
        Total:  9
        Histogram:
            2046  (0 to 0)
]]
```

```luau
-- Comparison case
local tab1 = {}
local tab2 = {}

function insert(t: {}, value: number)
	t[#t + 1] = value
end

bench(table.insert, tab1, 0)
	:withName("Table Insert")
	:compare(
		bench(insert, tab2, 0)
			:withName("Length Insert")
	):print()

--[[

Comparing against Table Insert...

Name: Length Insert
    Speed: [seconds]
        Avg:    +3.178e-8  (+28.5%)
        Max:    +3.000e-6  (+54.5%)
        Total:  +6.509e-5  (+28.5%)
    Memory: [kB]
        Avg:    -4.887e-4  (-11.1%)
        Total:  -1         (-11.1%)
]]
```


## Performance

The speed / memory usage of this module matters not, however here are metrics about Bench using Bench.  

```luau
bench(bench, function() end)
	:withName("Bench")
	-- removes the benchData table from the output
	:updateOutput()
	:print()

--[[
Name: Bench
    Speed: [seconds]
        Min:    6.739e-4
        Low:    6.906e-4
        Median: 8.781e-4
        Avg:    8.687e-4
        High:   1.227e-3
        Max:    1.661e-3
        Total:  1.8
        Histogram:
            351   (6.906e-4 to 7.578e-4)
            47    (7.578e-4 to 8.249e-4)
            931   (8.249e-4 to 8.921e-4)
            537   (8.921e-4 to 9.592e-4)
            83    (9.592e-4 to 1.026e-3)
            37    (1.026e-3 to 1.093e-3)
            13    (1.093e-3 to 1.160e-3)
            8     (1.160e-3 to 1.227e-3)
    Memory: [kB]
        Min:    65
        Low:    65
        Median: 66
        Avg:    65.82
        High:   66
        Max:    66
        Total:  113410
        Histogram:
            308   (65 to 65.13)
            1415  (65.88 to 66)
]]
```

## Design

`bench`: Takes in a function and its arguments and returns benchmark data.  The benchmark data is of the type: 
```luau
type BenchHistogram = {
	[number]: number,
	Range: number,
}

type SimpleBenchMetric = {
	Total: number,
	Average: number,
	Minimum: number,
	Maximum: number,
	Low: number,
	Median: number,
	High: number,
}

type BenchMetric = {
	Data: {number},
	Histogram: BenchHistogram
} & SimpleBenchMetric

type BenchData = setmetatable<{
	Name: string,
	Output: any, -- useful if the user needs to verify the output OR they want to print it
	Speed: BenchMetric,
	Memory: BenchMetric,
}, {
	-- Can be modified externally as shown in examples
	read __index: {
		print: (self: BenchData)-> BenchData,
		compare: (self: BenchData, ...BenchData) -> BenchCompareData,
		withName: (self: BenchData, name: string) -> BenchData,
		-- mainly used to prepare the value for printing (we just print the value itself)
		updateOutput: (self: BenchData, fn: (output: any)->(any)?) -> BenchData,
	}	
}>
```
`print`: Returns the input benchmark data after printing a summary of the data.

`withName`: Returns the input benchmark data after changing the Name property to the input string.

`updateOutput`: Returns the input benchmark data after modifying the Output property using the input function.

`compare`: Takes in multiple benchmark data objects and returns benchmark comparison data.  The benchmark comparison data is of type:
```luau
export type BenchCompareData = {
	[number]: BenchCompareMetric,
	Name: string,
	print: (self: BenchCompareData) -> ()
}
```
