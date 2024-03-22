# Welcome to NovaScope Exemplary Downstream Analysis (NEDA) documentation

## Introduction
This is an exemplary downstream analysis for spatial transcriptomics data from [NovaScope](https://github.com/seqscope/NovaScope/tree/main). 

Currently, the NovaScope Exemplary Downstream Analysis (NEDA) is designed to provide two strategies to analyze the spatial digital gene expression (SGE) matrix, including:

1) **Latent Dirichlet Allocation (LDA) + FICTURE**:  
    This strategy utilizes Latent Dirichlet Allocation (LDA) to identify spatial factors. Subsequently, [FICTURE](https://github.com/seqscope/ficture) is employed to map these identified factors onto a histological space with pixel-level resolution.

2) **Seurat + FICTURE**: 
    In this strategy, multi-dimensional clustering via [Seurat](https://satijalab.org/seurat/) is applied to explore cell type clusters. These clusters are then projected into a histological space, achieving pixel-level resolution through the use of FICTURE.

## A Brief Overview
![overview_brief](./NEDA_overview_brief.jpg)
**Figure 1: A Brief overview of the inputs, outputs, and process steps in NovaScope Exemplary Downstream Analysis (NEDA).**
The strategies "Latent Dirichlet allocation (LDA) + FICTURE" and "Seurat + FICTURE" share the scripts of step1.preprocessing step3.transform, and step4.pixel-level decoding. Their differences lie in two main areas: the configuration file used for input; and the procedures and output files in the second step. Details for each step are provided in the [Starting Downstream Analysis](./analysis/intro.md). SGE: spatial digital gene expression. 