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
local tab = {}
bench(table.insert, tab, 0)
	:withName("Insert"):print()

--Name: Insert
--    Speed: 
--        Median: 9.999e-8
--        Avg:    1.074e-7
--        High:   1.999e-7
--        Max:    2.519e-5
--        Total:  2.200e-4
--        Histogram:
--            179   (0.000e0 to 2.499e-8)
--            1838  (9.999e-8 to 1.249e-7)
--    Memory: 
--        Avg:    3.421e-3
--        Max:    4.000e0
--        Total:  7.000e0
--        Histogram:
--            2046  (0.000e0 to 0.000e0)
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

--Name: Bench
--    Speed: 
--        Min:    1.728e-3
--        Low:    1.762e-3
--        Median: 2.245e-3
--        Avg:    2.244e-3
--        High:   3.072e-3
--        Max:    4.542e-3
--        Total:  5.000e0
--        Histogram:
--            170   (1.762e-3 to 1.926e-3)
--            32    (1.926e-3 to 2.090e-3)
--            995   (2.090e-3 to 2.253e-3)
--            825   (2.253e-3 to 2.417e-3)
--            121   (2.417e-3 to 2.581e-3)
--            8     (2.581e-3 to 2.744e-3)
--            16    (2.744e-3 to 2.908e-3)
--            16    (2.908e-3 to 3.072e-3)
--    Memory: 
--        Min:    1.290e2
--        Low:    1.290e2
--        Median: 1.300e2
--        Avg:    1.298e2
--        High:   1.300e2
--        Max:    1.300e2
--        Total:  2.831e5
--        Histogram:
--            230   (1.290e2 to 1.291e2)
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

