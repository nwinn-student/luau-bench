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

export type BenchData = {
	Name: string,
	Speed: BenchMetric,
	Memory: BenchMetric,

	print: (self: BenchData)-> BenchData,
	compare: (self: BenchData, ...BenchData) -> BenchCompareData,
	withName: (self: BenchData, name: string) -> BenchData
}

return {}