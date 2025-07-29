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
	withName("Insert"):print()

--Name: Insert
--	Speed: 
--		Min:	9.999e-8
--		Low:	9.999e-8
--		Median:	1.000e-7
--		Avg:	1.442e-7
--		High:	2.000e-7
--		Max:	8.590e-5
--		Total:	1.442e-3
--		Histogram:
--			8175	(9.999e-8 to 1.124e-7)
--			778	(1.875e-7 to 2.000e-7)
--	Memory: 
--		Avg:	6.401e-3
--		Max:	3.200e1
--		Total:	6.400e1
--		Histogram:
--			9998	(0.000e0 to 0.000e0)
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
--	Speed: 
--		Min:		3.379e-3
--		Low:		3.432e-3
--		Median:	4.219e-3
--		Avg:		4.128e-3
--		High:	5.032e-3
--		Max:		6.061e-3
--		Total:	5.003e0
--		Histogram:
--			194		(3.432e-3 to 3.632e-3)
--			76		(3.632e-3 to 3.832e-3)
--			50		(3.832e-3 to 4.032e-3)
--			308		(4.032e-3 to 4.232e-3)
--			444		(4.232e-3 to 4.432e-3)
--			90		(4.432e-3 to 4.632e-3)
--			16		(4.632e-3 to 4.832e-3)
--			9		(4.832e-3 to 5.032e-3)
--	Memory: 
--		Min:		2.570e2
--		Low:		2.580e2
--		Median:	2.580e2
--		Avg:		2.579e2
--		High:	2.580e2
--		Max:		2.580e2
--		Total:	2.061e5
--		Histogram:
--			799		(2.580e2 to 2.580e2)
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

