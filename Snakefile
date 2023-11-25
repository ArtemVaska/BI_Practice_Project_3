sample_url_dict = {
'forward_PE_470bp': 'https://d28rh4a8wq0iu5.cloudfront.net/bioinfo/SRR292678sub_S1_L001_R1_001.fastq.gz',
'reverse_PE_470bp': 'https://d28rh4a8wq0iu5.cloudfront.net/bioinfo/SRR292678sub_S1_L001_R2_001.fastq.gz',
'forward_MP_2kb': 'https://d28rh4a8wq0iu5.cloudfront.net/bioinfo/SRR292862_S2_L001_R1_001.fastq.gz',
'reverse_MP_2kb': 'https://d28rh4a8wq0iu5.cloudfront.net/bioinfo/SRR292862_S2_L001_R2_001.fastq.gz',
'forward_MP_6kb': 'https://d28rh4a8wq0iu5.cloudfront.net/bioinfo/SRR292770_S1_L001_R1_001.fastq.gz',
'reverse_MP_6kb': 'https://d28rh4a8wq0iu5.cloudfront.net/bioinfo/SRR292770_S1_L001_R2_001.fastq.gz'}


rule all:
	input:
		expand('{sample}', sample = sample_url_dict.keys())


rule libraries_download_from_SRA:  # download three libraries from the TY2482 sample (6 files)
	output:
		sample = 'libraries/{sample}.fastq.gz'
	params:
		url = lambda x: sample_url_dict[x.sample]
	shell:
		"""
		wget -O {output.sample} {params.url}
		"""
		# -O allows you to save results to a file


rule fastqc:  # runs FastQC for all samples (6 files)
	input:
		'libraries/{sample}.fastq.gz'
	output:
		'results/fastqc/{sample}_fastqc.html',
		'results/fastqc/{sample}_fastqc.zip'
	shell:
		"""
		fastqc -o results/fastqc/ --noextract {input}
		"""


rule multiqc:  # runs MultiQC for all samples (6 files)
	input:
		'results/fastqc/'
	output:
		'results/multiqc/multiqc_report.html'
	shell:
		"""
		multiqc {input} -o results/multiqc/
		"""


rule jellyfish_count:  # uses 2 files (forward, reverse) for each library to get k-mer distribution
	input:
		sample1 = 'libraries/forward_{sample_slice}.fastq.gz',
		sample2 = 'libraries/reverse_{sample_slice}.fastq.gz'
	output:
		'results/jellyfish/{sample_slice}_kmer_31.jf'
	params:  # change this parameters before running snakemake!
		m = '-m 31',  # specifies the length of k-mer
		s = '-s 500M'  # set > genome size
	shell:
		"""
		jellyfish count {params.m} {params.s} <(zcat {input.sample1}) <(zcat {input.sample2}) -o {output}
		"""


rule jellyfish_histo:  # make a histogram files
	input:
		'results/jellyfish/{filename}.jf'
	output:
		'results/jellyfish/{filename}_histo.txt'
	shell:
		"""
		jellyfish histo {input} > {output}
		"""


rule reference_download_from_GenBank:  # loads the "Escherichia coli 55989, complete sequence" with Per. Ident = 100%
	output:
		"reference/55989.fasta"
	shell:
		"efetch -db nucleotide -id NC_011748.1 -format fasta > {output}"
