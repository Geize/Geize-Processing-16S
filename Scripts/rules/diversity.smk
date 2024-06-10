
# Processing data: 
	# 16S amplicon V3-V4 region amplified.
	# Alpha and beta diversity.
	# Minimum threads 24.


# Retrieve Files from config.yaml
import yaml # Import the PyYAML library

configfile: "config.yaml"


#---- Exploring the Diversity ----#

rule phylo:
	input:
		 "rep-seqs-dada2.qza"
		 
	output:
		 align= "aligned-rep-seqs.qza", 
		 mask_align= "masked-aligned-rep-seqs.qza",
		 unrooted= "unrooted-tree.qza",
		 rooted = "rooted-tree.qza"
	shell:
		 '''
		 qiime phylogeny\
		  align-to-tree-mafft-fasttree \
		  --i-sequences {input} \
		  --o-alignment {output.align} \
		  --o-masked-alignment {output.mask_align} \
		  --o-tree {output.unrooted} \
		  --o-rooted-tree {output.rooted}
		 '''

#---- Exploring the Alpha ----#

rule core_metrics:
	input: 
		 root = rules.phylo.output.rooted, 
		 dada2 = "table-dada2.qza"
	output:
	     rarefaction = config["core_metrics"] + "rarefied_table.qza",
		 faith= config["core_metrics"] + "faith_pd_vector.qza", 
		 observed = config["core_metrics"] + "observed_features_vector.qza",
		 shannon = config["core_metrics"] + "shannon_vector.qza",
		 evenness = config["core_metrics"] + "evenness_vector.qza", 
		 unweighted = config["core_metrics"] + "unweighted_unifrac_distance_matrix.qza",
		 weighted = config["core_metrics"] + "weighted_unifrac_distance_matrix.qza",
		 jaccard = config["core_metrics"] + "jaccard_distance_matrix.qza", 
		 bray = config["core_metrics"] + "bray_curtis_distance_matrix.qza", 
		 pcoa_unweighted= config["core_metrics"] + "unweighted_unifrac_pcoa_results.qza",
		 pcoa_weighted = config["core_metrics"] + "weighted_unifrac_pcoa_results.qza",
		 pcoa_jaccard= config["core_metrics"] + "jaccard_pcoa_results.qza",
		 pcoa_bray= config["core_metrics"] + "bray_curtis_pcoa_results.qza",
		 unweighted_qzv = config["core_metrics"] + "unweighted_unifrac_emperor.qzv",
		 weighted_qzv = config["core_metrics"] + "weighted_unifrac_emperor.qzv",
		 jaccard_qzv = config["core_metrics"] + "jaccard_emperor.qzv", 
		 bray_qzv = config["core_metrics"] + "bray_curtis_emperor.qzv"

	params:
		 metadata = config["metadata"],
		 sampling_depth= config["core_sampling_depth"],
		 threads = config["alpha_threads"]
	shell:
		 '''
		 qiime diversity core-metrics-phylogenetic \
		 --i-phylogeny {input.root} \
		 --i-table {input.dada2} \
		 --p-sampling-depth {params.sampling_depth} \
		 --m-metadata-file {params.metadata} \
		 --o-rarefied-table {output.rarefaction}\
		 --o-faith-pd-vector {output.faith} \
		 --o-observed-features-vector {output.observed}\
		 --o-shannon-vector {output.shannon}\
		 --o-evenness-vector {output.evenness}\
		 --o-unweighted-unifrac-distance-matrix {output.unweighted}\
		 --o-weighted-unifrac-distance-matrix {output.weighted}\
		 --o-jaccard-distance-matrix {output.jaccard} \
		 --o-bray-curtis-distance-matrix {output.bray}\
		 --o-unweighted-unifrac-pcoa-results {output.pcoa_unweighted}\
		 --o-weighted-unifrac-pcoa-results {output.pcoa_weighted} \
		 --o-jaccard-pcoa-results {output.pcoa_jaccard}\
		 --o-bray-curtis-pcoa-results {output.pcoa_bray} \
		 --o-unweighted-unifrac-emperor {output.unweighted_qzv} \
		 --o-weighted-unifrac-emperor {output.weighted_qzv} \
		 --o-jaccard-emperor {output.jaccard_qzv} \
		 --o-bray-curtis-emperor {output.bray_qzv} \
		 --p-n-jobs-or-threads {threads}
		 '''


rule faith_qzv:
	input:
		 faith_qza= config["core_metrics"] + "faith_pd_vector.qza"
	output:
		 faith_qzv = config["core_metrics"] + "faith-pd-group-significance.qzv"
	params:
		 metadata = config["metadata"]
	shell:
		 '''
		 qiime diversity alpha-group-significance\
		  --i-alpha-diversity {input} \
		  --m-metadata-file {params} \
		  --o-visualization {output}
		 '''

