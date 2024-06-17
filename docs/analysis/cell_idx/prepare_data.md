# Preparing Input Dataset

## Mandatory Input Files:

The following required input files can be generated using [NovaScope](https://github.com/seqscope/NovaScope/tree/main).

- **A referenced Histology File:**  
  The input histology file should be a referenced histology file GeoTIFF format, which facilitates the coordinate transformation between the input Spatial Gene Expression (SGE) matrix and the histology image. This means that the histology file must be aligned with the input SGE matrix and match its dimensions. For more details, refer to this [link](https://seqscope.github.io/NovaScope/walkthrough/rules/historef/#1-a-referenced-histology-file).
  
- **Transcript-Indexed Spatial Digital Gene Expression Matrix (SGE) in 10x Genome Format:**  
  A transcript-indexed SGE in 10x Genomics format contains all available genomic feature. Each SGE dataset is composed of `features.tsv.gz`, `barcodes.tsv.gz`, and `matrix.mtx.gz`. Details are provided [here](https://seqscope.github.io/NovaScope/walkthrough/rules/dge2sdge/#1-spatial-digital-gene-expression-matrix-sge).


## Example Datasets

NEDA provides two example datasets for this Cell Segmentation-based Analysis, including [the Shallow Liver Section Dataset](../../installation/example_data.md#shallow-liver-section-dataset) and [Deep Liver Section Dataset](../../installation/example_data.md#deep-liver-section-dataset). Each dataset contains the input transcript-indexed SGE and histology files. We also provide the the cell segment mask from [Cellpose](https://github.com/MouseLand/cellpose)as well as the black and white boundary TIF image from [Watershed](https://imagej.net/imaging/watershed).

Details on these datasets and download instructions are available in [Accessing Example Datasets](../../installation/example_data.md#input-for-preliminary-single-cell-analysis).
