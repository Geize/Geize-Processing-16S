# **16S rRNA analysis pipeline**

<br/>

The propose of this page is the reproducibility of the 16S data described in my publications (e.g.,<a href=" https://journals.asm.org/doi/abs/10.1128/AEM.00199-20">Tomazetto et al.</a>) or those are coming up soon. If you are looking for a tutorial, <a href="<https://docs.qiime2.org/2022.2/tutorials/moving-pictures/"> here</a> is the best one you can have.

However, you are more than welcome to reach out to me if you need help. Do not worry, I won't jump into your work. But I'll be glad if you can cite one of my works as a reference. 😊

<br/> **1. Login to the server:**

-   Install <a href="https://docs.qiime2.org/2022.2/install/native/#install-qiime-2-within-a-conda-environment"> qiime2</a>.
-   Run the activate step.
-   Test if qiime2 successfully activated 🔥- very important step.

```
qiime --help
```

<br/>

-   Before you exit the server, create a working directory.
-   Now exit, please. 😊

<br/>

**2. Transfer the fastq.gz files from your computer/HDD to the server.**

```
(base) ➜ ~  scp data/*.fastq.gz  mylogin@login:/home/geize/16S/
```

<br/>

**3. Create the sample-metadata file.**

I usually create metadata files according to the project and what is need to compare. However, below you find of an example metadata file. You can also add other information as much as you wish.

<p>

🔥**Important note.**<br> Do not forget to save the file as tab-delimited - it's the best option. Validate your metadata using a Keemei.

```
#SampleID   Description   Condition   ...
Sample01    Soil    Ref      ...
Sample02    Cons    A        ...
Sample03    Cons    B        ...
and dadada...
```

<br/> **4.Back to the server to create the manifest file.**

The following python script can help you to create a manifest file from any directory. Just type the command bellow to get more instructions - very fancy. 😁

```
(base) ➜ ~  python Write_manifestFile.py -help
```

<br/> **5. Processing the data.**

Once you have the manifest file, `DrT_Qiime2.sh`, and of course, fastq.gz in a directory, you can run the script. All the steps are wrapped in a single script, including the importing the data, denoising, trimming, joining, table ASVs, tree, and basic diverstiy analysis. The script also has the steps to convert QIIME2 artifacts into visualization files, which you can view using qiime tools view or <a href="https://view.qiime2.org">here</a>.

Check out the output files and directories!

<p>

🔥**1. Important note.**<br> The taxonomic classification was set up for amplicon libraries constructed using 515F/806R primer pair - the V4 region.

🔥**2. Important note.**

Open the file `qiime2_OhNO.err`. Try to find a message indicating error. Hope, you won't find anything. 😅

The `qiime tools validate` command was added after some critical steps. Open the `qiime2_GreatJOb.out` file, and check if there are similar message `"Result importing.qza appears to be valid at level=max."` after each step.

<br/>

**6. Plotting some graphics.**

Here, you also find a R script to plot some graphics. Of course, you can plot different graphics emphasizing "little this or little that". It is up to you.

<br/> All the best for us! 🤓

------------------------------------------------------------------------
