# Guide for NovaScope Exemplary Downstream Analysis

## Step-by-Step Instructions

0. Begin with `step0-getstarted.md` to install all necessary software and datasets, and to prepare your input files.

1. Preprocess your input datasets using the following command:
2. 
    ```bash
    ./step1-preprocess.sh ./input_data_and_params.txt
    ```

2. Next, choose between LDA factorization and Seurat clustering for further analysis. Follow the respective instructions:

    **(a) LDA Factorization**: 
    
    Execute LDA factorization by running:
    
    ```bash
    ./step2a-LDA.sh ./input_data_and_params.txt
    ```

    **(b) Seurat Clustering**: 
    
    Seurat clustering involves interactive steps for parameter fine-tuning. Proceed as follows:
    
    ```
    # Begin Seurat analysis:
    ./step2b-Seurat-01-hexagon.sh ./input_data_and_params.txt
    
    # Analyze the density plot to set the nFeature_RNA cutoff. Update this in the parameters file. 
    
    # Execute clustering:
    ./step2b-Seurat-02-clustering.sh ./input_data_and_params.txt
    
    # Review Dimensionality and Spatial plots to choose a clustering resolution.

    # Generate a model file:
    ./step2b-Seurat-03-convert.sh ./input_data_and_params.txt
    ```

3. Perform Pixel-level Spatial Decoding:
4. 
    ```
    ./step3-transform.sh ./input_data_and_params.txt
    ./step4-decoding.sh ./input_data_and_params.txt
    ```

# Notes

* This tutorial assumes the X-axis as the primary axis due to its greater length. Sorting and tabix steps are thus aligned with the X-axis in this downstream analysis.
