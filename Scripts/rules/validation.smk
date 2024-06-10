
# Rules for validation tables. 


rule importing_validation:
	#Validate the Importing file.
	input:
		 "import.qza"
	output: 
	     dir_val = config["validate"] + "importing_validation.txt"
	shell:
		 '''
		 qiime tools validate {input} > {output}
		 '''


rule dada2_validation:
	input:
		 "table-dada2.qza"
	output:
		 dir_val=config["validate"] + "dada2_validation.txt"	 
	shell:
		 '''
		 qiime tools validate {input} > {output}
		 '''

rule taxa_validation:
	input:
		 taxa_table ="taxonomy.qza"
	output:
         dir_val=config["validate"] +"taxa_validation.txt"
	shell:
		 '''
		 qiime tools validate {input} > {output}
		 '''


rule aligned_validation:
	input:"aligned-rep-seqs.qza"
	output:
		dir_val=config["validate"] +"aligned_validation.txt"
	shell:
		 '''
		 qiime tools validate {input} > {output}
		 '''
rule rooted_validation:
	input:"rooted-tree.qza"
	output:
		 dir_val=config["validate"] + "rooted_validation.txt"
		 
	shell:
		 '''
		 qiime tools validate {input} > {output}
		 '''
