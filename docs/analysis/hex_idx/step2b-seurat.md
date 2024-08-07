# Step 2b. Inferring Cell Type Factors using Seurat

This example illustrates inferring cell type factors using Seurat. This process contains two stops that require manual evaluations at [step 2b.2](#step-2b2-manually-select-the-cutoffs) and [step 2b.4](#step-2b4-manually-select-the-resolution-for-clustering).

**Prefix**:

This documentation uses the following prefixes to illustrate input and output filenames, which are automatically assigned by the script.

```bash
train_prefix="${prefix}.${solo_feature}.nf${nfactor}.d_${train_width}.s_${train_n_epoch}"
```

* The `nfactor` will be determined in [step 2b.5](#step-2b5-prepare-a-count-matrix-with-the-selected-resolution).
* Variable details for the prefixes are in the [Job Configuration](./job_config.md).

## Step 2b.1 Data Evaluation
This step applies the `Seurat_analysis.R` script in test mode to

* assess and remove mitochondrial and hypothetical genes,
* examine the distribution of the number of spatial barcodes per hexagon (nCount_RNA) and the number of genes detected per hexagon (`Nfeature_RNA`),
* evaluate assess the performance of different nFeature_RNA thresholds — 50, 100, 200, 300, 400, 500, 750, and 1000 — to filter the input hexagon-indexed SGE.

Input & Output
```bash
# Input: 
${input_hexagon_sge_10x_dir}/barcodes.tsv.gz                        ## user-defined input hexagon SGE in 10X Genomics format
${input_hexagon_sge_10x_dir}/features.tsv.gz     
${input_hexagon_sge_10x_dir}/matrix.mtx.gz  

# Output: 
${output_dir}/${train_model}/Ncount_Nfeature_vln.png
${output_dir}/${train_model}/nFeature_RNA_dist.png
${output_dir}/${train_model}/nFeature_RNA_cutoff${cutoff}.png       ## a density plot with two panels, displaying the hexagon-indexed SGE before and after filtering by Nfeature_RNA, for each nFeature_RNA cutoff
```

Commands:
```bash
$neda_dir/steps/step2b.1-Seurat-test-cutoff.sh $input_configfile
```

## Step 2b.2 Manually Selecting the Optimal nFeature_RNA Cutoff
Examine density plots generated by [step 2b.1](#step-2b1-data-evaluation) to choose the optimal `nFeature_RNA` cutoff to remove noise signals. For our example data, we applied a cut off of 500 for the deep liver section dataset, and 100 for the shallow liver section dataset and the minimal test dataset. It is optional to define x y ranges(`X_min`, `X_max`, `Y_min`, and `Y_max`).

Define the following variables to the input configuration file.

Example:
```bash
nFeature_RNA_cutoff=100   
X_min=2.5e+06
X_max=1e+07
Y_min=1e+06
Y_max=6e+06
```

## Step 2b.3 Seurat Clustering Analysis
This step starts with removing mitochondrial and hypothetical genes and filtering the hexagon-indexed SGE matrix by `nFeature_RNA_cutoff`. When X Y coordinate ranges are applied, the hexagon-indexed SGE matrix will also be filtered by coordinates.

Subsequently, this step applies [sctransform](https://github.com/satijalab/sctransform) normalization followed by dimensionality reduction through [Principal Component Analysis (PCA)](https://satijalab.org/seurat/reference/runpca) and [Uniform Manifold Approximation and Projection (UMAP)](https://satijalab.org/seurat/reference/runumap) embedding.

Next, the step employs [`FindClusters`](https://satijalab.org/seurat/reference/findclusters) to segregate hexagons into clusters utilizing a shared nearest neighbor (SNN) modularity optimization-based clustering algorithm. During this process, [`FindClusters`](https://satijalab.org/seurat/reference/findclusters) applies an argument of `resolution` to determine the "granularity" of clusters, i.e., a higher resolution value yields more clusters. A range of `resolutions`, including 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, and 2, are applied to explore the optimal `resolution`. For each resolution, the step generates an UMAP for dimensionality reduction, a spatial plot to visualize the clusters and their spatial arrangement, and a CSV file of differentially expressed genes for each cluster.

Additionally, this step generates a metadata file containing information on the cluster assignment for each hexagon, and an RDS (R Data Serialization) file that stores the complete Seurat object with all the compiled data.

Input & Output
```bash
# Input: 
${input_hexagon_sge_10x_dir}/barcodes.tsv.gz                                                    ## user-defined input hexagon-indexed SGE in 10X Genomics-compatible format
${input_hexagon_sge_10x_dir}/features.tsv.gz     
${input_hexagon_sge_10x_dir}/matrix.mtx.gz     

# Output: 
${output_dir}/${train_model}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv                ## a metadata file
${output_dir}/${train_model}/${prefix}_cutoff${nFeature_RNA_cutoff}_SCT.RDS                     ## an RDS file
${output_dir}/${train_model}/${prefix}_cutoff${nFeature_RNA_cutoff}_res${res}_DE.csv            ## Each resolution returns a CSV file of differentially expressed genes for each cluster
${output_dir}/${train_model}/${prefix}_cutoff${nFeature_RNA_cutoff}_res${res}_DimSpatial.png    ## Each resolution returns an image of two panels including an UMAP for dimensionality reduction, a spatial plot to visualize the clusters and their spatial arrangement 
```

Commands:
```bash
$neda_dir/steps/step2b.3-Seurat-clustering.sh $input_configfile
```

## Step 2b.4 Manually Selecting the Optimal Clustering Resolution
Examine the UMAP and spatial plots from the [step 2b.3](#step-2b3-seurat-clustering-analysis) and choose the optimal `resolution`. Then, save this chosen `resolution` into the input configuration file as the `res_of_interest` variable.

Example:
```bash
res_of_interest=1
```

## Step 2b.5 Preparing a Count Matrix
Transform the metadata file into a count matrix to serve as the model matrix for the subsequent steps. This step automatically detects the number of clusters from the model matrix and assigns it as a `nfactor` variable in the input configuration file.

Input & Output
```bash
# Input:
${input_hexagon_sge_10x_dir}/barcodes.tsv.gz                                                       ## user-defined input hexagon-indexed SGE in 10X Genomics-compatible format
${input_hexagon_sge_10x_dir}/features.tsv.gz     
${input_hexagon_sge_10x_dir}/matrix.mtx.gz     
${output_dir}/${train_model}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv                   ## the meta file from step 2b.3

# Output: 
${output_dir}/${train_model}/${train_prefix}.model_matrix.tsv.gz
```

Commands:
```bash
$neda_dir/steps/step2b.5-Seurat-count-matrix.sh $input_configfile
```
