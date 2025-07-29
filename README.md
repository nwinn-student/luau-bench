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
        Median: 9.999e-8
        Avg:    1.050e-7
        High:   2.000e-7
        Max:    2.400e-6
        Total:  1.075e-4
        Histogram:
            31    (0 to 2.500e-8)
            824   (7.500e-8 to 1.000e-7)
            136   (1.000e-7 to 1.250e-7)
            13    (1.750e-7 to 2.000e-7)
    Memory: 
        Avg:    2.935e-3
        Max:    2
        Total:  3
        Histogram:
            1022  (0 to 0)
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
        Median: 9.999e-8
        Avg:    1.050e-7
        High:   2.000e-7
        Max:    2.400e-6
        Total:  1.075e-4
        Histogram:
            31    (0 to 2.500e-8)
            824   (7.500e-8 to 1.000e-7)
            136   (1.000e-7 to 1.250e-7)
            13    (1.750e-7 to 2.000e-7)
    Memory: 
        Avg:    2.935e-3
        Max:    2
        Total:  3
        Histogram:
            1022  (0 to 0)
Name: Length Insert
    Speed: 
        Min:    9.999e-8
        Low:    9.999e-8
        Median: 9.999e-8
        Avg:    1.343e-7
        High:   2.000e-7
        Max:    6.199e-6
        Total:  1.375e-4
        Histogram:
            761   (9.999e-8 to 1.124e-7)
            158   (1.875e-7 to 2.000e-7)
    Memory: 
        Avg:    3.913e-3
        Max:    2
        Total:  4
        Histogram:
            1022  (0 to 0)

Comparing against Table Insert...

Name: Length Insert
    Speed: 
        Min:    +9.999e-8  (+inf%)
        Low:    +9.999e-8  (+inf%)
        Avg:    +2.929e-8  (+27.9%)
        Max:    +3.799e-6  (+158.3%)
        Total:  +3.000e-5  (+27.9%)
    Memory: 
        Avg:    +9.784e-4  (+33.3%)
        Total:  +1         (+33.3%)
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
        Min:    4.086e-4
        Low:    4.198e-4
        Median: 5.457e-4
        Avg:    5.539e-4
        High:   7.706e-4
        Max:    1.585e-3
        Total:  5.672e-1
        Histogram:
            89    (4.198e-4 to 4.637e-4)
            12    (4.637e-4 to 5.075e-4)
            506   (5.075e-4 to 5.514e-4)
            281   (5.514e-4 to 5.952e-4)
            60    (5.952e-4 to 6.391e-4)
            22    (6.391e-4 to 6.829e-4)
            23    (6.829e-4 to 7.268e-4)
            10    (7.268e-4 to 7.706e-4)
    Memory: 
        Min:    33
        Low:    33
        Median: 34
        Avg:    33.89
        High:   34
        Max:    34
        Total:  34295
        Histogram:
            113   (33 to 33.13)
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

