The current documentation include the following sections:


[**Home**](../index.md):

* [Documentation Overview](./documentation_overview.md): Provides a summary of the contents and structure of NEDA.

[**Installation**](../index.md):

* [Installing NEDA](../installation/installation.md): Guidelines on installing NEDA and its dependent software tools.
* [Example Datasets](../installation/example_data.md): Information on accessing three provided example datasets.


[**Pixel-level Analysis**](../analysis/hex_idx/intro.md):

* [Introduction](../analysis/hex_idx/intro.md): Introduction to Pixel-level Analysis in NEDA.
* [Preparing Input Data](../analysis/hex_idx/prepare_data.md): Overview of required input files.
* [Preparing Job Configuration](../analysis/hex_idx/job_config.md): Preparing the input configuration file.
* [Preprocessing](../analysis/hex_idx/step1-preprocess.md): Initialize computing environment and data preprocessing.
* [LDA Factorization](../analysis/hex_idx/step2a-LDA.md): Application of Latent Dirichlet Allocation (LDA) for spatial factor identification.
* [Seurat Clustering](../analysis/hex_idx/step2b-seurat.md): Multi-dimensional clustering with `Seurat` to identify cell types.
* [Transform](../analysis/hex_idx/step3-transform.md): Converting to a factor space using the provided model via `FICTURE`.
* [Pixel-level Decoding](../analysis/hex_idx/step4-decode.md): Decoding of pixel-level factors or clusters using `FICTURE`.


[**Cell Segmentation-based Analysis**](../analysis/cell_idx/intro.md):

* [Introduction](../analysis/cell_idx/intro.md): An Overview of the prelimary single-cell analysis.
* [Preparing Input](../analysis/cell_idx/prepare_data.md): Details of required input files.
* [Create Cell-indexed SGE](../analysis/cell_idx/step1-cell_SGE.md): Computing environment setup and preparation of a cell-indexed spatial digital gene expression matrix 
* [Seurat Clustering](../analysis/cell_idx/step2-Seurat-clustering.md): Application of multi-dimensional clustering with `Seurat` for cell type factor inference.
