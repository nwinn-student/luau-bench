export type BenchHistogram = {
	[number]: number,
	Range: number,
}

export type BenchMetric = {
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

export type BenchCompareMetric = {
	Name: string,
	Speed: {
		Percentage: BenchMetric,
		Exact: BenchMetric
	},
	Memory: {
		Percentage: BenchMetric,
		Exact: BenchMetric
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
		print: (self: BenchData)-> BenchData,
		compare: (self: BenchData, ...BenchData) -> BenchCompareData,
		withName: (self: BenchData, name: string) -> BenchData,
		-- mainly used to prepare the value for printing (we just print the value itself)
		updateOutput: (self: BenchData, fn: (output: any)->(any)?) -> BenchData,
	}	
}>

return {}