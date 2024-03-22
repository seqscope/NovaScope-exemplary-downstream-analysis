# Introduction

This tutorial provides an instruction of running NovaScope-exemplary-downstream-analysis (NEDA) based on the example datasets provided with the published protocol.

Before kicking off the analysis, please first [install NEDA in your computing environment](../installation/installation.md), [download the example datasets](../prep_input/access_data.md), and [prepare your job configuration file](../prep_input/job_config.md).

Next, start with this  to set up your computing environment and preprocess the input spatial digital gene expression (SGE) matrix, ensuring it's ready for analysis.

Finally, select the analytical strategy that best suits your needs or interests from Latent Dirichlet Allocation (LDA) + FICTURE, and Seurat + FICTURE. For implementing LDA + FICTURE analysis, refer to [this instruction](./LDA/step2a-LDA.md). If you wish to conduct Seurat + FICTURE analysis, begin with [this step](./Seurat/step2b-seurat.md). For each step, the instructions include both the **purpose** and the **execution command**. To ensure clarity, the instructions specifically detail the required **input files and the output files** that will be generated. When applicable, **auxiliary parameters** are applied in the script file.