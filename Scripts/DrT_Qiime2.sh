#!/bin/bash
#SBATCH --account dadada...
#SBATCH --job-name="dadada..""
#SBATCH --partition normal
#SBATCH -c 2 # number of cores requested
#SBATCH --mem-per-cpu=4G
#SBATCH --time=00:10:00 # hours:minutes runlimit after which job will be killed
#SBATCH --mail-user=geizetomazetto@bce.au.dk
#SBATCH --mail-type=END,FAIL
#SBATCH -e qiime2_OhNO.err-%N
#SBATCH -o qiime2_GreatJOb.out-%N


# qiime2 is already installed in my area.
# Activate the qiime2 on the server and testing.


eval "$(conda shell.bash hook)"
conda activate qiime2-2022.2

#Chech out the results from this command line in output file.
qiime --help


#Importe the sequence files into a QIIME2 artifact.

qiime tools import --type SampleData[PairedEndSequencesWithQuality] \
                  --input-path manifest.txt \
                  --output-path importing.qza \
                  --input-format PairedEndFastqManifestPhred33



#Important step. Check if there are any errors in the previous file.

qiime tools validate importing.qza


# Summarize the number of sequences per sample, and qualities at each position.
# It is useful for quality control - low quality regions will be removed.

qiime demux summarize --i-data importing.qza  --o-visualization SummaryImporting.qzv


#### Amplicon sequence variant - former OTUs ####
# The amplicon sequence variant is determined by DADA2 pipeline, as implemented in the q2-dada2 plugin.
# DADA2 -  denoising, trimming, joining, and table ASVs
# Here, the ASV table is already generated.

qiime dada2 denoise-paired --i-demultiplexed-seqs importing.qza --p-trim-left-f 17 --p-trim-left-r 21 --p-trunc-len-f 260 \
                           --p-trunc-len-r 240 --o-table table-dada2.qza --o-representative-sequences \
                           rep-seqs-dada2.qza --o-denoising-stats denoising-stats-dada2.qza


#Check out again ....
qiime tools validate table-dada2.qza
qiime tools validate denoising-stats-dada2.qza
qiime tools validate  rep-seqs-dada2.qza



# Convert the QIIME 2 artifact to a visualization file (.qzv)
# Sequences filtered, non-chimeric sequence, and number of sequences remained, and much more.
qiime metadata tabulate --m-input-file denoising-stats-dada2.qza \
                        --o-visualization denoising-stats-dada2.qzv



###################### Exploring the resulting data ######################
## "Total frequency" is the total number of counts/reads of your dataset.
## The “number of features” is the number of different ASVs observed in total and each dataset.

qiime feature-table summarize --i-table table-dada2.qza --o-visualization table.qzv \
                              --m-sample-metadata-file sample-metadata.txt


# Representative sequences - a representative sequence from each ASV.
# Honestly, this output is not really useful unless you want to do a Blast search against NCBI nt database.

qiime feature-table tabulate-seqs --i-data rep-seqs-dada2.qza \
                                  --o-visualization rep-seqs-dada2.qzv



###################### Generate a tree for SOME phylogenetic diversity analyses ######################
# The resulting files will be used in diversity analysis.
# Here, we have 3 output files, aligned-rep-seqs.qza, masked-aligned-rep-seqs.qza, unrooted-tree.qza, rooted-tree.qza.

qiime phylogeny align-to-tree-mafft-fasttree --i-sequences rep-seqs-dada2.qza \
                                              --o-alignment aligned-rep-seqs.qza \
                                              --o-masked-alignment masked-aligned-rep-seqs.qza \
                                              --o-tree unrooted-tree.qza --o-rooted-tree root-tree.qza



#Let's validate these output files.
qiime tools validate aligned-rep-seqs.qza
qiime tools validate masked-aligned-rep-seqs.qza
qiime tools validate root-tree.qza

#PAY ATTENTION.
#Check out first if all samples in **TABLE** have at least XXX sequences.

qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree.qza \
                                           --i-table table-dada2.qza \
                                           --p-sampling-depth 300 \
                                           --m-metadata-file sample-metadata.txt \
                                           --output-dir core-metrics-results

qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/faith_pd-vector.qza \
                                         --m-metadata-file sample-metadata.txt \
                                         --o-visualization core-metrics-results/faith-pd-group-significance.qzv



# Rarefaction curve is no longer use and useful. However, here you are.
qiime diversity alpha-rarefaction --i-tabe table-dada2.qza \
                                  --i-phylogeny root-tree.qza \
                                  --p-max-depth 1000 \
                                  --m-metadata-file sample-metadata.txt \
                                  --o-visualization alpha_rarefaction.qzv


# replace chao1 for ace, shannonor Simpson
qiime diversity alpha --i-table table-dada2.qza \
                      --p-metric chao1 \
                       --o-alpha-diversity chao1.qza

qiime tools export --input-path chao1.qza --output-path export_chao1


######################  Taxonomic classification ######################

# The method below for amplicons constructed using the 515F/806R primer pair - the V4 region.
# Taxonomic classifiction of the sequences in QIIME2 artifact - tabe.qza
# Use pre-trained Naive Bayes classifier and the q2-feature-classifier plugin.

# Considering that
        # Download the  https://data.qiime2.org/2022.2/common/gg-13-8-99-515-806-nb-classifier.qza was made.
        # And the file was rename for gg_515_806_classifier.qza


qiime feature-classifier classify-sklearn --i-classifier gg_515_806_classifier.qza \
                                          --i-reads rep-seqs-dada2.qza \
                                          --o-classification taxonomy.qza


#Let's validate this taxa output file
qiime tools validate taxonomy.qza


# Convert the QIIME 2 artifact to a visualization files (.qzv)
#Honestly, the this taxonomy.qzv not really useful.
qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv

qiime taxa barplot --i-table table-dada2.qza --i-taxonomy taxonomy.qza \
                                            --m-metadata-file sample-metadata.txt \
                                            --o-visualization taxa_Barplot.qzv


# Finally, we have something now to play around.
