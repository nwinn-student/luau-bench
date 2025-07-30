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

 * Notice that the count of values for speed doesn't match those for memory, this is due to the garbage collector.  
 * Notice that the range of values for the histogram doesn't include the minimum or maximum value.  The purpose is to ensure that the boxes can be more reflective of the data.  
 * Notice that the total for the speed is 5 seconds, this is one of the internal limitations.  
 * Notice that for the example, some aspects were non-existant, these aspects 0 seconds or kB and as such took up space without providing any information.  

```luau
bench(bench, function() end)
	:withName("Bench")
	-- removes the benchData table from the output
	:updateOutput()
	:print()

--[[
Name: Bench
    Speed: [seconds]
        Min:    7.276e-4
        Low:    7.331e-4
        Median: 9.759e-4
        Avg:    9.478e-4
        High:   1.164e-3
        Max:    1.399e-3
        Total:  1.9
        Histogram:
            313   (7.331e-4 to 7.870e-4)
            29    (7.870e-4 to 8.410e-4)
            17    (8.410e-4 to 8.950e-4)
            49    (8.950e-4 to 9.490e-4)
            1297  (9.490e-4 to 1.002e-3)
            239   (1.002e-3 to 1.056e-3)
            47    (1.056e-3 to 1.110e-3)
            28    (1.110e-3 to 1.164e-3)
    Memory: [kB]
        Min:    61
        Low:    66
        Median: 66
        Avg:    65.99
        High:   66
        Max:    66
        Total:  111658
        Histogram:
            1692  (66 to 66)
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

