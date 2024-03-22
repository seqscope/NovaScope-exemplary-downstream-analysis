# Introduction

This tutorial provides an step-by-step instruction of running NovaScope-exemplary-downstream-analysis (NEDA) for each analytical strategy.

Before kicking off the analysis, please first [install NEDA in your computing environment](../installation/installation.md), [download the example datasets](../prep_input/access_data.md), and [prepare your job configuration file](../prep_input/job_config.md).

Next, start with [this](./step1-preprocess.md) to set up your computing environment and preprocess the input spatial digital gene expression (SGE) matrix, ensuring it's ready for analysis.

Finally, select the analytical strategy that best suits your needs or interests from Latent Dirichlet Allocation (LDA) + FICTURE, and Seurat + FICTURE. For implementing LDA analysis, refer to [this instruction](./LDA/step2a-LDA.md). If you wish to conduct Seurat analysis, begin with [this step](./Seurat/step2b-seurat.md). Each step's instructions cover:

* The **purpose** of the step;
* The **execution command**;
* The necessary **input and output files**, enhancing clarity;
* Definitions of auxiliary parameters are outlined in the script for each step, as applicable.