# Bench

#### Table of Contents
- [Purpose](#purpose)
- [Requirements](#requirements)
- [Usage Cases](#usage-cases)
- [Example](#example)
- [Performance](#performance)
- [Design](#design)

## Purpose

Bench is a general performance benchmarker that performs simple calculations with the obtained data and lets the user perform other necessary calculations.  Bench handles the number of times to run the function internally.  Bench does not keep data with negative values, such as memory when it has been GC'ed or when your function transcends time itself.  

## Requirements
[Luau 0.670+](https://github.com/luau-lang/luau/releases)

## Credit
The idea to add a histogram came from [Benchmarker](https://boatbomber.itch.io/benchmarker)

## Usage Cases
A user needs to measure how expensive and fast a function is, they will use Bench to obtain these metrics.

A user needs to compare how different versions of a function perform, they will use Bench to perform metrics on each function, then Bench will again be used to obtain a comparison.

## Example
```luau
-- General benchmarking case
local tab = {}
bench(table.insert, tab, 0)
	:withName("Insert"):print()

--[[
Name: Insert
    Speed: 
        Low:    9.999e-8
        Median: 9.999e-8
        Avg:    1.071e-7
        High:   2.000e-7
        Max:    2.100e-6
        Total:  1.096e-4
        Histogram:
            995   (9.999e-8 to 1.124e-7)
            10    (1.875e-7 to 2.000e-7)
    Memory: 
        Avg:    2.935e-3
        Max:    2.000e0
        Total:  3.000e0
        Histogram:
            1022  (0.000e0 to 0.000e0)
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
	:print()
	:compare(
		bench(insert, tab2, 0)
			:withName("Length Insert")
			:print()
	):print()

--[[
Name: Table Insert
    Speed: 
        Min:    9.999e-8
        Low:    9.999e-8
        Median: 1.000e-7
        Avg:    1.611e-7
        High:   4.000e-7
        Max:    1.119e-5
        Total:  1.650e-4
        Histogram:
            605   (9.999e-8 to 1.374e-7)
            400   (1.749e-7 to 2.125e-7)
            7     (2.875e-7 to 3.250e-7)
    Memory: 
        Avg:    3.913e-3
        Max:    2
        Total:  4
        Histogram:
            1022  (0 to 0)
Name: Length Insert
    Speed: 
        Min:    9.999e-8
        Low:    9.999e-8
        Median: 9.999e-8
        Avg:    1.343e-7
        High:   2.000e-7
        Max:    1.900e-6
        Total:  1.376e-4
        Histogram:
            720   (9.999e-8 to 1.124e-7)
            209   (1.875e-7 to 2.000e-7)
    Memory: 
        Avg:    2.935e-3
        Max:    2
        Total:  3
        Histogram:
            1022  (0 to 0)

Comparing against Table Insert...

Name: Length Insert
    Speed: 
        Median: -0         (-0%)
        Avg:    -2.675e-8  (-17%)
        High:   -1.999e-7  (-50%)
        Max:    -9.299e-6  (-83%)
        Total:  -2.739e-5  (-17%)
    Memory: 
        Avg:    -9.784e-4  (-25%)
        Total:  -1         (-25%)
]]
```


## Performance

The speed / memory usage of this module matters not, however here are metrics about Bench using Bench.  

 * Notice that the count of values for speed doesn't match those for memory, this is due to the garbage collector.  
 * Notice that the range of values for the histogram doesn't include the minimum or maximum value.  The purpose is to ensure that the boxes can be more reflective of the data.  
 * Notice that the total for the speed is 5 seconds, this is one of the internal limitations.  
 * Notice that for the example, some aspects were non-existant, these aspects 0 seconds or kB and as such took up space without providing any information.  

```luau
bench(bench, function() end)
	:withName("Bench"):print()

--[[
Name: Bench
    Speed: 
        Min:    4.117e-4
        Low:    4.209e-4
        Median: 5.496e-4
        Avg:    5.607e-4
        High:   7.395e-4
        Max:    1.434e-3
        Total:  5.742e-1
        Histogram:
            19    (4.209e-4 to 4.607e-4)
            1     (4.607e-4 to 5.005e-4)
            214   (5.005e-4 to 5.403e-4)
            603   (5.403e-4 to 5.802e-4)
            117   (5.802e-4 to 6.200e-4)
            17    (6.200e-4 to 6.598e-4)
            17    (6.598e-4 to 6.996e-4)
            15    (6.996e-4 to 7.395e-4)
    Memory: 
        Min:    3.300e1
        Low:    3.300e1
        Median: 3.400e1
        Avg:    3.389e1
        High:   3.400e1
        Max:    3.400e1
        Total:  3.436e4
        Histogram:
            110   (3.300e1 to 3.312e1)
]]
```

## Design

`bench`: Takes in a function and its arguments and returns benchmark data.  The benchmark data is of the type: 
```luau
type BenchHistogram = {
	[number]: number,
	Range: number,
}
type BenchMetric = {
	Data: {number},
	Total: number,
	Average: number,
	Minimum: number,
	Maximum: number,
	Low: number,
	Median: number,
	High: number,
	Histogram: BenchHistogram
}
type BenchData = {
	Name: string,
	Speed: BenchMetric,
	Memory: BenchMetric,

	print: (self: BenchData)-> BenchData,
	-- will be explained later
	compare: (self: BenchData, ...BenchData) -> BenchCompareData,
	withName: (self: BenchData, name: string) -> BenchData
}
```
`print`: Returns the input benchmark data after printing a summary of the data.
`withName`: Returns the input benchmark data after changing the Name property to the input string.

