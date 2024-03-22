The current documentation of [NovaScope Exemplary Downstream Analysis (NEDA)](../../index.md) 
include the following sections:

* [Installation](../installation/installation.md): Instructions on how to install NEDA and dependent software tools.
* [Preparing Input](../prep_input/access_data.md):
    * [Input Data](../prep_input/access_data.md): Accessing the example input spatial digital gene expression matrix datasets.
    * [Job Configuration](../prep_input/job_config.md): Preparing the input configuration file.
* [Starting Downstream Analysis](../analysis/intro.md):
    * [Introduction](../analysis/intro.md): A brief introduction of the step-by-step analytical procedures.
    * [Initializing](../analysis/step1-preprocess.md): Initialize computing environment and data preprocessing
    * [Latent Dirichlet Allocation (LDA) + FICTURE Analysis](../LDA/step2a-LDA.md): The step-by-step instruction for LDA and FICTURE analytical strategy.
        * [LDA Factorization](../LDA/step2a-LDA.md)
        * [Transform](../analysis/LDA/step3-transform.md)
        * [Pixel-level Decoding](../analysis/LDA/step4-decode.md):
    * [Seurat + FICTURE Analysis](../analysis/Seurat/step1-preprocess.md): A step-by-step guideline for the analytical strategy using Seurat and FICTURE.
        * [Seurat Clustering](../analysis/Seurat/step2b-seurat.md)
        * [Transform](../analysis/Seurat/step3-transform.md)
        * [Pixel-level Decoding](../analysis/Seurat/step4-decode.md)