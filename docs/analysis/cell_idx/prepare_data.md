# Preparing Input Dataset

## Mandatory Input Files:

The following required input files can be generated using [NovaScope](https://github.com/seqscope/NovaScope/tree/main).

### (1) A referenced Histology File:

* Description: The input histology file must be a referenced histology file in GeoTIFF format, enabling coordinate transformation between the input Spatial Gene Expression (SGE) matrix and the histology image. This means the histology file must be aligned with and match the dimensions of the input SGE matrix.
* Preparation: This histology file can be prepared manually or using NovaScope. For more details on preparing the histology file with NovaScope, refer to Rule [`historef`](https://seqscope.github.io/NovaScope/fulldoc/rules/historef) in NovaScope.

  
### (2) A Spatial Digital Gene Expression (SGE) Matrix in 10x genomics Format:
* Description: A transcript-indexed SGE matrix in 10x Genomics format contains spatial barcodes, gene, and UMI counts for all available genomic features. Each SGE dataset is composed of `features.tsv.gz`, `barcodes.tsv.gz`, and `matrix.mtx.gz`. 
* Preparation: The SGE matrix could be prepared via Rule [dge2sdge](https://seqscope.github.io/NovaScope/fulldoc/rules/dge2sdge) in NovaScope.

## Example Datasets

NEDA provides two example datasets for this Cell Segmentation-based Analysis, including [the Shallow Liver Section Dataset](../../installation/example_data.md#shallow-liver-section-dataset) and [Deep Liver Section Dataset](../../installation/example_data.md#deep-liver-section-dataset). Each dataset contains the input transcript-indexed SGE and histology files. We also provide the the cell segment mask from [Cellpose](https://github.com/MouseLand/cellpose)as well as the black and white boundary TIF image from [Watershed](https://imagej.net/imaging/watershed).

Details on these datasets and download instructions are available in [Accessing Example Datasets](../../installation/example_data.md#input-for-preliminary-single-cell-analysis).
