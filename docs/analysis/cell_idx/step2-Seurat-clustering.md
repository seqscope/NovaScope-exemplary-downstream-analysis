# Step 2. Inferring Cell Type Factors using Seurat

This example demonstrates how to infer cell type factors from a cell-indexed SGE using `Seurat`.

The step script starts with the removal of mitochondrial and hypothetical genes and the filtering of hexagons based on `nFeature_RNA_cutoff` X Y ranges, when applied. Subsequently, it applies sctransform normalization followed by dimensionality reduction through [Principal Component Analysis (PCA)](https://satijalab.org/seurat/reference/runpca) and [Uniform Manifold Approximation and Projection (UMAP)](https://satijalab.org/seurat/reference/runumap) embedding.

Next, the step script employs [`FindClusters`](https://satijalab.org/seurat/reference/findclusters) segregate hexagons into clusters utilizing a shared nearest neighbor (SNN) modularity optimization-based clustering algorithm. The argument `resolution` in [`FindClusters`](https://satijalab.org/seurat/reference/findclusters) determines the "granularity" of clusters, i.e., a higher resolution value yields more clusters. Thus, this step will examine the performance of a range of `resolutions`, including 0.25, 0.5, 0.75, 1, 1.25, 1.5, and 1.75. For each specified resolution, the script generates an UMAP for dimensionality reduction, a spatial plot to visualize the clusters and their spatial arrangement, and a Differential Expression (DE) file, detailing marker genes identified for each cluster.

Additionally, this step generates a metadata file containing information on the cluster assignment for each hexagon, and an RDS (R Data Serialization) file that stores the complete Seurat object with all the compiled data.

Input & Output
```bash
# Input: 
${output_dir}/${prefix}/barcodes.tsv.gz                                          # the cell-indexed SGE from step1
${output_dir}/${prefix}/features.tsv.gz 
${output_dir}/${prefix}/matrix.mtx.gz

# Output: 
${output_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv                # a metadata file
${output_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_SCT.RDS                     # an RDS file
${output_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res${res}_DE.csv            # for each resolution (`$res`) including 0.25, 0.5, 0.75, 1, 1.25, 1.5, and 1.75
${output_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res${res}_DimSpatial.png    # for each resolution (`$res`) including 0.25, 0.5, 0.75, 1, 1.25, 1.5, and 1.75
```

Parameters:

* `--X_col`: Specify which part of the hexagon ID corresponds to the X coordinate. For instance, in our example dataset, the hexagon ID is formatted as `{X}_{Y}`, i.e., the X coordinate is the first component. In this case, `--X_col` set this argument to 1.  Default: 3.
* `--Y_col`: Specify which part of the hexagon ID corresponds to the Y coordinate. As the Y coordinate is the second component in the example case, it should set to 2.  Default: 4.
* `--nFeature_RNA_cutoff`: Cutoff value for filtering hexagons by nFeature_RNA. Since this cell-indexed SGE is derived from histology files, `nFeature_RNA_cutoff` is set to be 0.


Commands:
```bash
Rscript ${neda}/scripts/seurat_analysis.R \
    --input_dir ${output_dir}/${prefix} \
    --output_dir ${output_dir}/${prefix}/Seurat \
    --unit_id ${prefix} \
    --X_col 1 \
    --Y_col 2 \
    --nFeature_RNA_cutoff 0 
```

