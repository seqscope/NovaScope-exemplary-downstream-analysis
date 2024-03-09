# Getting Started with Downstream Analysis

## 1. Environment and References Setup

**Software and Dependencies Installation**:

Ensure the installation of the below software and their respective versions to facilitate analysis:

    - Snakemake (v7.25.3)
    - Samtools (v1.14)
    - Python (versions 3.10 and 3.9)
    - R (v4.2)
    - FICTURE (Install from [GitHub](https://github.com/seqscope/ficture))

For Python, 3.9 is applied for the majority steps while 3.10 helps create the pixel figure and HTML report file for LDA factorization and projection.

**Python Environment**:

Set up a dedicated Python environment for FICTURE as per the guidelines found at [this link](https://github.com/seqscope/ficture/blob/8ceb419618c1181bb673255427b53198c4887cfa/requirements.txt#L4).

**R Packages Installation**:

Install the following required R packages:

    ```
    Seurat
    ggplot2
    patchwork
    dplyr
    tidyverse
    stringr
    cowplot
    optparse
    grDevices
    RColorBrewer
    ```

## 2. Input Datasets

Input files required for downstream analysis are `features.tsv.gz`, `barcodes.tsv.gz`, and `matrix.mtx.gz`, which can be generated via [NovaScope](https://github.com/seqscope/NovaScope/tree/main).

For LDA factorization, download the gene info reference dataset matching your input file's species [here](https://github.com/seqscope/ficture/tree/protocol/info).

## 3.Input Configuration

Example configuration is provided in `input_data_and_params_lda.txt` amd `input_data_and_params_seurat.txt`. Those files serve as the input for parameters and dataset paths. Below is a guide for defining minimal parameters in FICTURE; for a comprehensive parameter list, refer to [FICTURE's protocol](https://github.com/seqscope/ficture/tree/protocol).

Use the `prefix` below to identify the input dataset. Both the input dataset prefix and parameters will be used to name output files.

### 3.1 Environment and Path Configuration

```
## Environment Paths
execution_mode="HPC"																  # When execution mode is HPC, load required modules.

py39_env="/nfs/turbo/sph-hmkang/index/data/weiqiuc/ScopeFlow_local/env/pyenv/py39"    # Python 3.9 environment path
py310_env="/nfs/turbo/sph-hmkang/index/data/weiqiuc/ScopeFlow_local/env/pyenv/py310"  # Python 3.10 environment path

ficture="/nfs/turbo/sph-hmkang/weiqiuc/tools/factor_analysis"         				  # Path to FICTURE repository

neda="/nfs/turbo/sph-hmkang/index/data/weiqiuc/NovaScope_local/NovaScope-exemplary-downstream-analysis" # Only needed for Seurat 
ref_geneinfo="/nfs/turbo/sph-hmkang/weiqiuc/tools/factor_analysis/info/Mus_musculus.GRCm39.107.names.tsv.gz"   # Reference gene info dataset path. Only needed for LDA.

## Input/Output Directories
input_dir="/nfs/turbo/umms-leeju/v5/ngeAR/N3-B08C_mouse_default_QCraret1v4i"           # Directory for input files
output_dir="/nfs/turbo/sph-hmkang/index/data/weiqiuc/NovaScope_local/NovaScope-exemplary-downstream-results"  # Directory for output files, including `LDA` and `Seurat` results

## Output Prefix
prefix="N3-B08C_mouse_default_QCraret1v4i"                                             # Prefix for naming output files
```

### 3.2 Factorization/Clustering params

Define your preference for LDA factorization or Seurat clustering and include the appropriate configurations as follows:

#### Option a. LDA Factorization

```
train_model="LDA"   

sf="gn"             # Feature selection, "gn" for gene
tw=18               # Training width, the side length of the hexagon (in micrometers)
nf=12               # Number of factors
ep=3                # Epochs for LDA training
seed=2024030600     # Seed for LDA training randomness
```

#### Option b. Seurat Clustering

For Seurat clustering, the number of factors is determined by the clustering results.

```
train_model="Seurat"

sf="gn"
tw=18           
ep="NA"         # Not applicable for Seurat clustering
```

### 3.3 Projection params
```
pw=18           # Projection width, suggest to use one the same as or less than train width
ar=4            # Anchor point distance (in micrometers)
```
