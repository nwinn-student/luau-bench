export type BenchHistogram = {
	[number]: number,
	Range: number,
}

export type SimpleBenchMetric = {
	Total: number,
	Average: number,
	Minimum: number,
	Maximum: number,
	Low: number,
	Median: number,
	High: number,
}

export type BenchMetric = {
	Data: {number},
	Histogram: BenchHistogram
} & SimpleBenchMetric

export type BenchCompareMetric = {
	Name: string,
	Speed: {
		Data: {number},
		Histogram: BenchHistogram,
		Percentage: SimpleBenchMetric,
		Exact: SimpleBenchMetric
	},
	Memory: {
		Data: {number},
		Histogram: BenchHistogram,
		Percentage: SimpleBenchMetric,
		Exact: SimpleBenchMetric
	},
}

export type BenchCompareData = {
	[number]: BenchCompareMetric,
	Name: string,
	print: (self: BenchCompareData) -> ()
}

export type BenchData = setmetatable<{
	Name: string,
	Output: any, -- useful if the user needs to verify the output OR they want to print it
	Speed: BenchMetric,
	Memory: BenchMetric,
}, {
	read __index: {
		[any]: any, -- To avoid type errors when creating custom

		print: (self: BenchData)-> BenchData,
		compare: (self: BenchData, ...BenchData) -> BenchCompareData,
		withName: (self: BenchData, name: string) -> BenchData,
		-- mainly used to prepare the value for printing (we just print the value itself)
		updateOutput: (self: BenchData, fn: ((output: any)->(any))?) -> BenchData,
	}	
}>

return nil
