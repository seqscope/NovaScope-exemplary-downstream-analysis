# NovaScope-exemplary-downstream-analysis

## Step-by-step Tutorial

0. Follow the `step0-getstarted.md` to install the required softwares and datasets, and prepare input files. 

1. Proprocess the input datasets.
    ```bash
    ./step1-preprocess.sh ./input_data_and_params.txt
    ```

2. Opt for either LDA factorization or Seurat clustering to proceed. Execute the relevant steps as follows:

     **(a) LDA Factorization**: 
       
    ```bash
    ./step2a-LDA.sh ./input_data_and_params.txt
    ```

    (b) **Seurat factorization**.
    
    This process involves interactive decision points requiring parameter adjustments. Follow these steps:

    ```
    # 1) Start the Seurat analysis:
    ./step2b-Seurat-01-hexagon.sh ./input_data_and_params.txt
    
    # 2) Review the density plot to determine the nFeature_RNA cutoff. Update this in input_data_and_params.txt. 
    
    # 3) Clustering:
    ./step2b-Seurat-02-clustering.sh ./input_data_and_params.txt
    
    # 4) Assess the Dim and Spatial plots to select the appropriate clustering resolution.

    # 5) Prepare a model file.
    ./step2b-Seurat-03-convert.sh  ./input_data_and_params.txt
    ```

3. Pixel-level Spatial decoding.
    
    ```
    ./step3-transform.sh  ./input_data_and_params.txt
    ./step4-decoding.sh ./input_data_and_params.txt
    ```

# Notes:

* This example case uses the X as major axis as it is the longer axis. The sort and tabix steps thoroughout this downstream analysis are based on X axis. 
