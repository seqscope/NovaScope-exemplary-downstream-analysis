# Preparing Input Dataset

While the input spatial transcriptomics data varies between strategies, both can be generated using [NovaScope](https://github.com/seqscope/NovaScope/tree/main). 

## Mandatory Input Files:
Regardless of the chosen strategy, the following files are essential and can be prepared using the Rule [`sdgeAR_reformat`](https://seqscope.github.io/NovaScope/walkthrough/rules/sdgeAR_reformat/) in NovaScope:

- **Ficture-Compatible Spatial Digital Gene Expression (SGE) Matrix:**  
  This file should contain information such as gene ID, gene name, and counts for each genomic feature. It is advisable to use the gene-filtered feature file from NovaScope (i.e., `*.feature.clean.tsv.gz`). Further details are available [here](https://seqscope.github.io/NovaScope/walkthrough/rules/sdgeAR_reformat/#2-two-tab-delimited-feature-files).

- **Tab-Delimited Feature File:**  
  For strategies employing Seurat+FICTURE, it is necessary to prepare a hexagon-indexed SGE in 10x genome format. This can be achieved using the Rule [`sdgeAR_segment`](https://seqscope.github.io/NovaScope/walkthrough/rules/sdgeAR_segment/) in NovaScope.

## Seurat-Only Input Files
When opting for the Seurat+Ficture strategy, the following specific file is required:

- **Hexagon-Indexed SGE in 10x Genome Format:**  
This SGE is created by segmenting pixels into hexagonal units, the size of which is defined by the user. The format aligns with the 10x genome standards. More details are provided [here](https://seqscope.github.io/NovaScope/walkthrough/rules/sdgeAR_segment/#1-hexagon-based-sge).

## Example Datasets
Alternatively, NEDA offers three example datasets, each suitable for input in spatial transcriptomic analysis within NEDA. For detailed information on these datasets and instructions on how to download them, see [Accessing Example Datasets](../../installation/example_data.md).