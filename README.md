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
--		Low: 9.999e-8
--		Median: 1.000e-7
--		Average: 1.391e-7
--		High: 2.000e-7
--		Maximum: 1.042e-4
--		Total: 1.391e-3
--		Histogram:
--			9063	(9.999e-8 to 1.125e-7)
--			738	(1.874e-7 to 2.000e-7)
--	Memory: 
--		Average: 6.501e-3
--		Maximum: 3.200e1
--		Total: 6.500e1
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
--		Min: 4.706e-3
--		Low: 4.757e-3
--		Median: 5.858e-3
--		Average: 5.756e-3
--		High: 7.452e-3
--		Maximum: 8.397e-3
--		Total: 5.002e0
--		Histogram:
--			142	(4.757e-3 to 5.094e-3)
--			37	(5.094e-3 to 5.431e-3)
--			124	(5.431e-3 to 5.768e-3)
--			434	(5.768e-3 to 6.105e-3)
--			88	(6.105e-3 to 6.442e-3)
--			19	(6.442e-3 to 6.778e-3)
--			5	(6.778e-3 to 7.115e-3)
--			3	(7.115e-3 to 7.452e-3)
--	Memory: 
--		Min: 2.570e2
--		Low: 5.140e2
--		Median: 5.140e2
--		Average: 5.135e2
--		High: 5.140e2
--		Maximum: 5.140e2
--		Total: 2.778e5
--		Histogram:
--			541	(5.140e2 to 5.140e2)
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

