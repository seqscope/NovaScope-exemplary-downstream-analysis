# Preparing Input Dataset

While the input spatial transcriptomics data varies between strategies, both can be generated using [NovaScope](https://github.com/seqscope/NovaScope/tree/main). 

## Input Files:
The following files are essential and can be prepared using NovaScope:

**(1) A Spatial Digital Gene Expression (SGE) Matrix in FICTURE-Compatible TSV format:**  
This is an SGE matrix in a FICTURE-compatible TSV format, containing information of spatial barcode, gene, and count for each genomic feature by barcode and gene.

NovaScope facilitates the preparation of this file by converting the SGE matrix from the 10X Genomics format into a FICTURE-compatible TSV format through Rule [sdgeAR_reformat](https://seqscope.github.io/NovaScope/fulldoc/rules/sdgeAR_reformat). Additionally, NovaScope offers Rule [sdgeAR_polygonfilter](https://seqscope.github.io/NovaScope/fulldoc/rules/sdgeAR_polygonfilter) to generate an SGE matrix that has undergone gene filtering and density-based polygon filtering in this format. Users can select the option that best suits their requirements. Our example uses the filtered SGE matrix as input.

**(2) A Tab-Delimited Feature File:**  
This file should contain information of gene ID, gene name, and counts for each genomic feature per gene. 

NovaScope also offers two options for this file, including the one corresponds to the SGE matrix from Rule [sdgeAR_reformat](https://seqscope.github.io/NovaScope/fulldoc/rules/sdgeAR_reformat) (naming convention: `*.feature.tsv.gz`), and the clean feature file that passed the filtering based on gene names, gene types, and number of UMIs per gene from Rule [sdgeAR_featurefilter](https://seqscope.github.io/NovaScope/fulldoc/rules/sdgeAR_featurefilter) (naming convention: `*.feature.clean.tsv.gz`). Our example data uses the clean feature file.

**(3) A Metadata File for X Y Coordinates:**  
This file contains the minimum and maximum X Y coordinates for the input SGE matrix.

**(4) (Model-Specific) Hexagon-Indexed SGE:**
The hexagon-indexed SGE is created by segmenting pixels into hexagonal units, with the size defined by the user.

* For LDA+FICTURE analysis, provide the hexagon-indexed SGE in a FICTURE-compatible TSV format. This file can be generated using Rule [sdgeAR_segment_ficture](https://seqscope.github.io/NovaScope/fulldoc/rules/c04_sdgeAR_segment_ficture) in NovaScope.

* For Seurat+FICTURE analysis, supply the hexagon-indexed SGE in 10x Genomics format. This file can be generated using Rule [sdgeAR_segment_10x](https://seqscope.github.io/NovaScope/fulldoc/rules/c04_sdgeAR_segment_10x) in NovaScope.

## Example Datasets
Alternatively, NEDA offers three example datasets, each suitable for input in spatial transcriptomic analysis within NEDA. For detailed information on these datasets and instructions on how to download them, see [Accessing Example Datasets](../../installation/example_data.md#input-for-spatial-transcriptomic-analysis).