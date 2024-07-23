# Preparing Input Dataset

The input spatial digital gene expression (SGE) matrix can be generated using [NovaScope](https://github.com/seqscope/NovaScope/tree/main). 

## Input Files:
The following files are essential and can be prepared using NovaScope:

### (1) A Spatial Digital Gene Expression (SGE) Matrix in TSV format

* Description: A SGE matrix in **FICTURE-compatible TSV format**, containing information of spatial barcode, gene, and UMI count for each genomic feature by barcode and gene.
* Preparation: NovaScope facilitates the preparation of a raw SGE matrix via [Rule sdgeAR_reformat](https://seqscope.github.io/NovaScope/fulldoc/rules/sdgeAR_reformat) and a filtered SGE matrix via [Rule sdgeAR_polygonfilter](https://seqscope.github.io/NovaScope/fulldoc/rules/sdgeAR_polygonfilter). Both can serve as input files for NEDA. The filtered SGE matrix undergoes gene filtering and density-based polygon filtering in this format. Users can select the option that best suits their requirements. Our example uses the filtered SGE matrix as input.

### (2) A Tab-Delimited Feature File

* Description: A TSV file provides information of gene ID, gene name, and counts unique molecular identifiers (UMIs) for each genomic feature per gene.

* Preparation: NovaScope also offers two options for this file, including the one corresponds to the raw SGE matrix from Rule [sdgeAR_reformat](https://seqscope.github.io/NovaScope/fulldoc/rules/sdgeAR_reformat) (naming convention: `*.feature.tsv.gz`), and the clean feature file that passed the filtering based on gene names, gene types, and number of UMIs per gene from Rule [sdgeAR_featurefilter](https://seqscope.github.io/NovaScope/fulldoc/rules/sdgeAR_featurefilter) (naming convention: `*.feature.clean.tsv.gz`). Our example data uses the clean feature file.

**(3) A Metadata File for X Y Coordinates:**  

* Description: This file contains the minimum and maximum X Y coordinates for the input SGE matrix.
* Preparation: When the input SGE matrix is prepared by NovaScope, it includes a corresponding meta file for coordinates. The naming conventions for the raw and filtered coordinate meta files are `*.raw.coordinate_minmax.tsv` and `*.filtered.coordinate_minmax.tsv`, respectively.

**(4) (Model-Specific) Hexagon-Indexed SGE Matrices:**

* Description: The hexagon-indexed SGE matrix is created by segmenting pixels in the SGE matrix into hexagonal units, with the size defined by the user.
* Preparation: The required format for the hexagon-indexed SGE varies based on the chosen analytical strategy
    * For LDA+FICTURE analysis, provide a hexagon-indexed SGE matrix in FICTURE-compatible TSV format. This file can be generated using Rule [sdgeAR_segment_ficture](https://seqscope.github.io/NovaScope/fulldoc/rules/c04_sdgeAR_segment_ficture) in NovaScope.
    * For Seurat+FICTURE analysis, supply a hexagon-indexed SGE matrix in 10x Genomics format. This file can be generated using Rule [sdgeAR_segment_10x](https://seqscope.github.io/NovaScope/fulldoc/rules/c04_sdgeAR_segment_10x) in NovaScope.

## Example Datasets
Alternatively, NEDA offers three example datasets for this pixel-level analysis. For detailed information on these datasets and instructions on how to download them, see [Accessing Example Datasets](../../installation/example_data.md#input-for-spatial-transcriptomic-analysis).