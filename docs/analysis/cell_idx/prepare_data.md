# Preparing Input Dataset

## Mandatory Input Files:

The following required input files can be generated using [NovaScope](https://github.com/seqscope/NovaScope/tree/main).

- **A referenced Histology File:**  
  The referenced histology file, which is in GeoTIFF format, allows the coordinate transformation between the SGE matrix and a histology image. See details [here](https://seqscope.github.io/NovaScope/walkthrough/rules/historef/#1-a-referenced-histology-file).
 
- **Transcript-Indexed Spatial Digital Gene Expression Matrix (SGE) in 10x Genome Format:**  
  A transcript-indexed spatial digital gene expression matrix (SGE) in 10x Genomics format contains all available genomic feature. Each SGE dataset is composed of `features.tsv.gz`, `barcodes.tsv.gz`, and `matrix.mtx.gz`. Details are provided [here](https://seqscope.github.io/NovaScope/walkthrough/rules/dge2sdge/#1-spatial-digital-gene-expression-matrix-sge).


## Example Datasets

Additionally, NEDA provides two datasets, including [the Shallow Liver Section Dataset](../../installation/example_data.md#shallow-liver-section-dataset) and [Deep Liver Section Dataset](../../installation/example_data.md#deep-liver-section-dataset), include both transcript-indexed SGE and a corresponding histology file. These datasets are specifically suitable for this preliminary single-cell analysis. 

Details on these datasets and download instructions are available in [Accessing Example Datasets](../../installation/example_data.md#input-for-preliminary-single-cell-analysis).
