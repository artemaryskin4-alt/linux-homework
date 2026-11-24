#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ----- Parameters ------
params.input = "samplesheet.csv"
params.reference = "test_data/genome.fa"
params.outdir = "results"
params.min_mapq	= 20

// ----- Process 1: FastQC -----
process FASTQC {
	publishDir "${params.outdir}/fastqc", mode: 'copy'

	input:
	tuple val(sample), path(reads)

	output:
	tuple val(sample), path("*.html"), path("*.zip")

	script:
	"""
	fastqc ${reads}
	"""
}

// ---- Process 2: MultiQC ----
process MULTIQC {
	publishDir "${params.outdir}/multiqc", mode: 'copy'

	input:
	path "*"

	output:
	path "multiqc_report.html"
	path "multiqc_data"

	script:
	"""
	multiqc .
	"""
}

// ---- Process 3: BWA index ----
process BWA_INDEX {
	publishDir "${params.outdir}/bwa_index", mode: 'copy'

	input:
	path reference

	output:
	path ("${reference}.*"), emit: index
	path(reference), emit: ref

	script:
	"""
	bwa-mem2 index ${reference}
	"""
}

// ---- Process 4: BWA mem ----
process BWA_MEM {
	publishDir "${params.outdir}/bam", mode: 'copy'

	input:
	tuple val(sample), path(reads)
	path reference 
	path index_files

	output:
	tuple val(sample), path ("${sample}.bam")

	script:
	"""
	bwa-mem2 mem -t 4 ${reference} ${reads[0]} ${reads[1]} | samtools sort -o ${sample}.bam
	"""
}

// ---- Process 5: Samtools Filter ------
process SAMTOOLS_FILTER {
	publishDir "${params.outdir}/filtered_bam", mode: 'copy'

	input:
		tuple val(sample), path(bam)

	output:
		tuple val(sample), path("${sample}.filtered.bam")
	script:
	"""
	samtools view -b -q ${params.min_mapq} ${bam} > ${sample}.filtered.bam
	"""
}

// ---- Process 6: Samtools Index ----
process SAMTOOLS_INDEX {
	publishDir "${params.outdir}/filtered_bam", mode: 'copy'

	input:
		tuple val(sample), path(bam)

	output:
		tuple val(sample), path("${bam}.bai")
	script:
	"""
	samtools index ${bam}
	"""
}

// ---- Workflow -----
workflow {
	// Reading samplesheet
	samples = Channel
		.fromPath(params.input)
		.splitCsv(header: true)
		.map { row -> [row.sample, [file(row.fastq_1), file(row.fastq_2)]] }
	
	// 1. Starting FastQC for all samples
	FASTQC(samples)

	// 2. Assembly only ZIP-files (second element of tuple)
	multiqc_input = FASTQC.out.map { sample, html, zip -> zip }.collect()
	MULTIQC(multiqc_input)

	// 3. BWA index
	reference_ch = Channel.fromPath(params.reference)
	BWA_INDEX(reference_ch)

	// 4.BWA mem
	BWA_MEM(samples, BWA_INDEX.out.ref, BWA_INDEX.out.index)

	// 5 & 6. Filtering and Indexing
	SAMTOOLS_FILTER(BWA_MEM.out)
	SAMTOOLS_INDEX(SAMTOOLS_FILTER.out)
}


