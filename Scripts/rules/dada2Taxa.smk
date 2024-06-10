
# Processing data: 
	# Importing data.
	# DADA2 as a denoising method. 
	# Taxonomic classification.
	# Region V3-V4 extracted from GreenGenes2.
	# Primers: 341F:CCTACGGGNGGCWGCAG and 805R:GACTACHVGGGTATCTAATCC
	# Using the qiime2-2023.7-py38-linux-conda.yml.
	# Parameters in yaml file.
 
import yaml # Import the PyYAML library


# Retrieve files and parameters in yaml file.
configfile: "config.yaml"

#---- Rules for processing ----#

rule import_data:
   # PairedEnd sequences
	input:
		 manifest_file= config["manifest_file"]
	output: 
		 q2_import = "import.qza"
	params: 
		 typeSample= "SampleData[PairedEndSequencesWithQuality]",
		 inputFormat= "PairedEndFastqManifestPhred33"

	shell:
		 '''
		 qiime tools import --type {params.typeSample} \
		 --input-path {input}  \
         --output-path {output} \
         --input-format {params.inputFormat}
		 '''

rule summarize:
	#Number and quality of sequences.
	input: 
		 rules.import_data.output.q2_import
	output:
		 qzv = config["q2_qzv"] + "SummaryImport.qzv"
	shell:
		 '''
		  qiime demux summarize \
		  --i-data {input} \
		  --o-visualization {output}
		 '''

rule trimming_reads:
	input: 
		 in_file= rules.import_data.output.q2_import
	output:
		 reads_trimmed= "Import_Trimmed.qza"
	threads: config["trimming_threads"]
	shell:
		 '''
		 qiime cutadapt trim-paired --i-demultiplexed-sequences {input} \
			--p-cores {threads} \
			--p-front-f CCTACGGGNGGCWGCAG \
			--p-front-r GACTACHVGGGTATCTAATCC \
            --p-error-rate 0.1 \
			--o-trimmed-sequences {output} \
		 '''

rule summarize_trimmed:
	input: rules.trimming_reads.output.reads_trimmed

	output:
		 trimmed_seq = config["q2_qzv"] + "Summary_TrimmedReads.qzv" 
	shell:
		 '''
		 qiime demux summarize \
		    --i-data {input} \
		 	--o-visualization {output}
		 '''



rule dada2:
	# Generate ASV table - denoise-paired 
	input:
		 rules.trimming_reads.output.reads_trimmed
	output:
		 dada2 = "table-dada2.qza",
		 rep_seq= "rep-seqs-dada2.qza",
		 denoising = "denoising-stats-dada2.qza"
	threads:  config["dada2_threads"]
	shell:
		 '''
		 qiime dada2 denoise-paired \
		 	--i-demultiplexed-seqs {input} \
			--p-trim-left-f {config[trim-left-f]} \
			--p-trim-left-r {config[trim-left-r]} \
			--p-trunc-len-f {config[trunc-len-f]} \
            --p-trunc-len-r {config[trunc-len-r]} \
			--o-table {output.dada2}\
			--o-representative-sequences {output.rep_seq} \
			--o-denoising-stats {output.denoising} \
			--p-n-threads {threads}
		 '''


#---- Exploring the Statistics ----#
rule denoising_stats:
	# Visualization of the ASV results (.qzv)
	input:
		 denoising_raw = rules.dada2.output.denoising
	output:
	   	 denoising_stats=config["q2_qzv"] + "denoising-stats-dada2.qzv"
	shell:
		 '''qiime metadata tabulate \
			--m-input-file {input.denoising_raw} \
            --o-visualization {output}
		 '''

rule feature_summ:
	# Number of ASVs.
	input:
	     asv_table = rules.dada2.output.dada2
	output:
	     table_viz = config["q2_qzv"] + "table.qzv"
	params: 
		 metadata = config["metadata"]
	shell:
	     '''
		 qiime feature-table summarize \
		 --i-table {input.asv_table} \
		 --o-visualization {output.table_viz} \
         --m-sample-metadata-file {params} 
		 '''

#----   Taxonomic classification ----# 

rule classify:
	input:
         rep_seq= rules.dada2.output.rep_seq,
	output:
		 taxa_table= "taxonomy.qza"
	params:
		 ref_gg2= config["v3v4Region"]
	shell:
		 '''
		 qiime feature-classifier classify-sklearn \
		  --i-classifier {params} \
          --i-reads {input} \
          --o-classification {output.taxa_table}
		 '''

rule barplot:
	input: 
		 asv_table = rules.dada2.output.dada2,
		 taxa_table =rules.classify.output.taxa_table
	output:
		 plot = config["q2_qzv"] + "taxa_Barplot.qzv"
	params:
		 metadata = config["metadata"]
	shell:
		 '''
		 qiime taxa barplot --i-table {input.asv_table}\
		  --i-taxonomy {input.taxa_table} \
          --m-metadata-file {params} \
          --o-visualization {output.plot}
		 '''