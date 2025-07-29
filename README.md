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
--		Min:   	1.713e-3
--		Low:   	1.768e-3
--		Median:	2.281e-3
--		Avg:   	2.276e-3
--		High:  	3.150e-3
--		Max:   	5.351e-3
--		Total: 	5.000e0
--		Histogram:
--			230   	(1.768e-3 to 1.941e-3)
--			30    	(1.941e-3 to 2.113e-3)
--			929   	(2.113e-3 to 2.286e-3)
--			805   	(2.286e-3 to 2.459e-3)
--			86    	(2.459e-3 to 2.632e-3)
--			24    	(2.632e-3 to 2.804e-3)
--			17    	(2.804e-3 to 2.977e-3)
--			32    	(2.977e-3 to 3.150e-3)
--	Memory: 
--		Min:   	1.290e2
--		Low:   	1.290e2
--		Median:	1.300e2
--		Avg:   	1.298e2
--		High:  	1.300e2
--		Max:   	1.300e2
--		Total: 	2.792e5
--		Histogram:
--			232   	(1.290e2 to 1.291e2)
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

