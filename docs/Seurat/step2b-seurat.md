# Seurat + FICTURE analytical strategy

## Step 2b. Infer cell type factors using Seurat

This example illustrates infering cell type factors using Seurat. Since this step, the output files will be stored at `${model_dir}`, which is defined as `model_dir=${output_dir}/${train_model}`.

This process contains two stops, which require manual evaluation. One stop is at step 2b.2 and the other at step 2b.4. 

**Prefix**:

The `nf` will be determined in step2b.5
```
hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"    
```



### step 2b.1 Create hexagonal SGE and test different cutoffs for nFeature_RNA
This step will creates hexagonal SGE that is compatible with Seurat. It also examine the distribution of Ncount and Nfeature and tests filtering the SGE using different nFeature_RNA cutoffs, including 50, 100, 200, 300, 400, 500, 750, and 1000.

Input & Output
```
# Input:
${output_dir}/${prefix}.merged.matrix.tsv.gz
${output_dir}/${prefix}.feature.tsv.gz

# Output: 
# * Hexagonal SGE: 
        ${model_dir}/features.tsv.gz    ## model_dir=${output_dir}/${train_model}
        ${model_dir}/barcodes.tsv.gz
        ${model_dir}/matrix.mtx.gz
# * Evaluation files: 
        ${model_dir}/Ncount_Nfeature_vln.png
        ${model_dir}/nFeature_RNA_dist.png
        * for each cut off ${cutoff} in 50, 100, 200, 300, 400, 500, 750, and 1000:
                ${model_dir}/nFeature_RNA_cutoff${cutoff}.png

```

Command:
```
$neda_dir/steps/step2b.1-creat-hexagons-for-Seurat.sh $input_configfile
```

### step 2b.2 Manually select the cutoffs.

Review the density plots from the `step2b-Seurat-01-hexagon.sh` and select a threshold for nFeature_RNA. It is optional to define x y ranges. Add those variables to the `input_data_and_params` file.

Regarding to the thresholds for nFeature_RNA, we applied a cutoff of nFeature_RNA_cutoff=500 for deep sequencing data, and nFeature_RNA_cutoff=100 for shallow sequencing data. 

Example:
```
# In this case, the Y_max is not applied. 
nFeature_RNA_cutoff=100
X_min=2.5e+06
X_max=1e+07
Y_min=1e+06
```

### step 2b.3 Seurat clustering analysis
The Seurat_analysis.R script, by default, evaluates clustering at various resolutions, specifically 0.25, 0.5, 0.75, 1, 1.25, 1.5, and 1.75. 

For each resolution level, it creates both a Dimensionality Reduction and Spatial plot to illustrate the clusters using a UMAP manifold and their spatial positioning, as well as a Differential Expression (DE) file listing the marker genes for every cluster. 

Additionally, the script generates a metadata file containing information on the cluster assignment for each cell, and an RDS file that stores the complete Seurat object with all the compiled data.

Input & Output
```
# Input: 
${model_dir}/features.tsv.gz
${model_dir}/barcodes.tsv.gz
${model_dir}/matrix.mtx.gz

#Output: 
# * A metadata file:
        ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv
# * An RDS file:
        ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_SCT.RDS
# * For each resolution `$res` in 0.25, 0.5, 0.75, 1, 1.25, 1.5, and 1.75:
        ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res${res}_DE.csv
        ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res${res}_DimSpatial.png
```

Command:
```
$neda_dir/steps/step2b.3-Seurat-clustering.sh $input_configfile
```

### step 2b.4 Manually select the resolution for clustering
Examine the Dimensionality Reduction and Spatial plots from the previous step and choose a resolution to continue with. Then, save this chosen resolution into the `input_data_and_params` file as the res_of_interest variable. 

Example:
```
res_of_interest=1
```

### step 2b.5 Prepare a count matrix with the selected resolution.
Transform the metadata into a count matrix to serve as the model matrix for the subsequent step. 
Additionally, this process determines the number of clusters present at the chosen resolution and assigns this count to the nf variable in the `input_data_and_params` file.

Input & Output
```
#Input:
${model_dir}/features.tsv.gz
${model_dir}/barcodes.tsv.gz
${model_dir}/matrix.mtx.gz
${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv

#Output: 
${model_dir}/${train_prefix}.model.tsv.gz
```

Command:
```
$neda_dir/steps/step2b.5-Seurat-count-matrix.sh $input_configfile
```
