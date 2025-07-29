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
The idea to add a histogram came from [Benchmarker](https://boatbomber.itch.io/benchmarker).  
You may notice that the results for the example comparing table.insert and #t + 1 differ from those in here.  That is due to the cost of calling a function

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
    Speed: [seconds]
        Low:    9.999e-8
        Median: 9.999e-8
        Avg:    1.202e-7
        High:   2.000e-7
        Max:    7.999e-6
        Total:  1.231e-4
        Histogram:
            987   (9.999e-8 to 1.124e-7)
            13    (1.875e-7 to 2.000e-7)
    Memory: [kB]
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
    Speed: [seconds]
        Low:    9.999e-8
        Median: 9.999e-8
        Avg:    1.202e-7
        High:   2.000e-7
        Max:    7.999e-6
        Total:  1.231e-4
        Histogram:
            987   (9.999e-8 to 1.124e-7)
            13    (1.875e-7 to 2.000e-7)
    Memory: [kB]
        Avg:    2.935e-3
        Max:    2
        Total:  3
        Histogram:
            1022  (0 to 0)
Name: Length Insert
    Speed: [seconds]
        Min:    9.999e-8
        Low:    9.999e-8
        Median: 9.999e-8
        Avg:    1.539e-7
        High:   3.000e-7
        Max:    1.100e-5
        Total:  1.576e-4
        Histogram:
            756   (9.999e-8 to 1.249e-7)
            144   (1.750e-7 to 2.000e-7)
            110   (2.000e-7 to 2.250e-7)
    Memory: [kB]
        Avg:    4.892e-3
        Max:    2
        Total:  5
        Histogram:
            1022  (0 to 0)

Comparing against Table Insert...

Name: Length Insert
    Speed: [seconds]
        Min:    +9.999e-8  (+inf%)
        Avg:    +3.369e-8  (+28%)
        High:   +9.999e-8  (+50%)
        Max:    +3.000e-6  (+37.5%)
        Total:  +3.450e-5  (+28%)
    Memory: [kB]
        Avg:    +1.956e-3  (+66.7%)
        Total:  +2         (+66.7%)
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
    Speed: [seconds]
        Min:    4.093e-4
        Low:    4.110e-4
        Median: 5.455e-4
        Avg:    5.296e-4
        High:   7.422e-4
        Max:    1.442e-3
        Total:  5.423e-1
        Histogram:
            237   (4.110e-4 to 4.524e-4)
            42    (4.524e-4 to 4.938e-4)
            55    (4.938e-4 to 5.352e-4)
            542   (5.352e-4 to 5.766e-4)
            89    (5.766e-4 to 6.180e-4)
            13    (6.180e-4 to 6.594e-4)
            12    (6.594e-4 to 7.008e-4)
            14    (7.008e-4 to 7.422e-4)
    Memory: [kB]
        Min:    33
        Low:    33
        Median: 34
        Avg:    33.89
        High:   34
        Max:    34
        Total:  34296
        Histogram:
            112   (33 to 33.13)
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

