# Pixel-level Analysis

This section provides an example of how to identify spatial factors at pixel-level resolution in spatial transcriptomics data.

## Analytical Strategies

NEDA currently offers two analytical strategies:

1) **Latent Dirichlet Allocation (LDA) + FICTURE**:
This strategy utilizes Latent Dirichlet Allocation (LDA) to identify spatial factors, and then uses [FICTURE](https://github.com/seqscope/ficture) to map these factors onto a histological space with pixel-level resolution.

2) **Seurat + FICTURE**: 
This strategy uses multi-dimensional clustering via [Seurat](https://satijalab.org/seurat/) to explore cell type clusters and then projects those clusters into a histological space using [FICTURE](https://github.com/seqscope/ficture), achieving pixel-level resolution.

## A Step-by-Step Procedure

Before beginning the analysis, ensure that NEDA and its dependencies are [installed](../../installation/installation.md) properly. Then, follow these steps as outlined:

1. Prepare your [input dataset](./prepare_data.md) and its corresponding [input configuration file](./job_config.md).

2. [Set up your computing environment](./step1-preprocess.md), and create minibatches for subsequent analysis.

3. Choose the analytical strategy that best suits your project, either [LDA](./step2a-LDA.md) or [Seurat](./step2b-seurat.md), to yield clusters or factors from your dataset.

4. [Transform](./step3-transform.md) and [decode](./step4-decode.md) these clusters or factors on your input data at pixel-level resolution.

Each step contains detailed instructions for:

* the **purpose** of each step;
* the **execution commands**;
* necessary **input and output files**;
* definitions of **auxiliary parameters**, as outlined in the scripts for each step.

## An Overview
![overview_brief](./ST_overview.png)
**Figure 1: A Brief Overview of the Inputs, Outputs, and Process Steps for Pixel-level Analysis.** 
