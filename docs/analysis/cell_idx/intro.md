# Cell Segmentation-based Analysis

This is an example to illustrate aggregating the spatial transcriptomic data from [NovaScope](https://github.com/seqscope/NovaScope/tree/main) at the cell level, and clustering those identified cells using [Seurat](https://satijalab.org/seurat/) build-in graph-based clustering approach. 

![overview_brief](./SC_overview.png)
**Figure 2: A Brief Overview of the Inputs, Outputs, and Process Steps for Cell Segmentation-based Analysis.** SGE: spatial digital gene expression matrix; UMAP: Uniform Manifold Approximation and Projection.

## Step-by-Step Procedure

Before beginning the analysis, ensure that NEDA and its dependencies are [installed](../../installation/installation.md). Follow these steps as outlined:

1. Create a cell-indexed spatial digital gene expression matrix. This step requires the users manually perform histology-based cell segmentation outside of NEDA using methods such as [Watershed](https://imagej.net/imaging/watershed) and [Cellpose](https://github.com/MouseLand/cellpose). 

2. Apply Seurat to identify cell type clusters for those staining-based segmented cells.
