
#Aarhus Univeristy
#@autor - Geizecler Tomazetto, Ph.D
#email - geizetomazetto@gmail.com
#Plotting the 16S data processed.


library(ggplot2)
library(microeco)
library(qiime2R)
library(magrittr)
library(phyloseq)

# ☝️Set your directory below.


#To convert QIIME2 file to microtable object directly.

qiimed2meco <- function(ASV_data, sample_data, taxonomy_data, phylo_tree = NULL){
  # Read ASV data
  ASV <- as.data.frame(read_qza(ASV_data)$data)
  #  Read metadata
  metadata <- read_q2metadata(sample_data)
  rownames(metadata) <- as.character(metadata[, 1])
  # Read taxonomy table
  taxa_table <- read_qza(taxonomy_data)
  taxa_table <- parse_taxonomy(taxa_table$data)
  # Make the taxonomic table clean, this is very important.
  taxa_table %<>% tidy_taxonomy
  # Read phylo tree
  if(!is.null(phylo_tree)){
    phylo_tree <- read_qza(phylo_tree)$data
  }
  dataset <- microtable$new(sample_table = metadata, tax_table = taxa_table, otu_table = ASV, phylo_tree = phylo_tree)
  dataset
}
  


mydataset <- qiimed2meco(ASV_data = "table-dada2.qza", sample_data ="sample-metadata.txt", 
                              taxonomy_data = "taxonomyLignum.qza", phylo_tree = "unrooted-tree.qza")

#Checking my data..
print(mydataset)

test <- mydataset$tax_table
for(i in 1:ncol(test)){
  prefix <- paste0(tolower(substr(colnames(test)[i], 1, 1)), "__")
  test[, i] <- gsub(prefix, "", test[, i])
  test[,i] <- paste0(prefix, test[, i])
}

mydataset$tax_table <- test


mydataset$tidy_dataset()
print(mydataset)


#Checking the number of sequencein each sample.

mydataset$sample_sums() %>% range

#Calculating  the taxa abundance at each taxonomic..
mydataset$cal_abund()
class(mydataset$taxa_abund)


#Save it!
dir.create("data_abund")
mydataset$save_abund(dirpath = "data_abund/")


"
Plotting the Bar Chart Graphic
"

info_phylum <- trans_abund$new(dataset = mydataset,taxrank = "Phylum", ntaxa = 12)
info_phylum$plot_bar(others_color = "grey70",  xtext_keep  = TRUE,xtext_size = 8, 
                     legend_text_italic = TRUE,facet = "pH")  

#Bar graphic for classes abundance
info_class$plot_bar(others_color = "grey70",  xtext_keep = TRUE,xtext_size = 8, 
                    legend_text_italic = TRUE,facet = "pH") 


#Heatmap for abundant Class.

info_class <-trans_abund$new(dataset = mydataset,taxrank = "Class", ntaxa=12)
info_class$plot_heatmap(facet = "pH", xtext_keep = TRUE,
                         xtext_size = 4,  withmargin = FALSE,ytext_size = 8)



"
Alpha diversity
"

# It's also stored in the object microtable automatically. 
# I do not want  Faith's phylogenetic diversity because takes much time.

mydataset$cal_alphadiv(PD=FALSE)

# return dataset$alpha_diversity
# Salve the data in another directory
class(mydataset$alpha_diversity)
dir.create("alpha_diversity")
mydataset$save_alphadiv(dirpath = "alpha_diversity")


# Creating trans_alpha object can return two data frame: alpha_data and alpha_stat.

alphaDiversity <- trans_alpha$new(dataset = mydataset, group = "pH")

# 8 indices for group pH 6 --- group! and not sample. 

alphaDiversity$alpha_stat[1:32, ]


# Let's see if there is different among the groups using KW rank. 
alphaDiversity$cal_diff(method = 'KW')
alphaDiversity$res_alpha_diff[1:32, ]


# Let's see if there is different among the groups using ANOVA using multiple comparisons.
# Here do not specify the number lines inside the brackets. 
alphaDiversity$cal_diff(method = "anova")
alphaDiversity$res_alpha_diff


# Number of ASV present in consortia is very low compared to soil. 
#Let's plot PD
# Shannon == evenness 

#alphaDiversity$plot_alpha(measure = "PD")
#alphaDiversity$plot_alpha(add_letter= T, measure = "PD", use_boxplot = FALSE)

alphaDiversity$plot_alpha(measure = "Observed")
alphaDiversity$plot_alpha(pair_compare = TRUE, measure = "Shannon", shape= "pH")
