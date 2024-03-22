# Welcome to NovaScope Exemplary Downstream Analysis (NEDA) documentation

## Introduction
This is an exemplary downstream analysis for Spatial Transcriptomics data from [NovaScope](https://github.com/seqscope/NovaScope/tree/main). 

Currently, the NovaScope Exemplary Downstream Analysis (NEDA) is design to provide two analytical strategies to analyze the spatial digital gene expression (SGE) matrix, including:

1) **Latent Dirichlet allocation (LDA) + FICTURE**:  
    This strategy utilizes LDA for the identification of spatial factors. Subsequently, [FICTURE](https://github.com/seqscope/ficture) is employed to map these identified factors onto a histological space with pixel-level resolution.

2) **Seurat + FICTURE**: 
    In this strategy, multi-dimensional clustering via Seurat is applied to explore cell type clusters. These clusters are then projected into a histological space, achieving pixel-level resolution through the use of FICTURE.

## A Brief Overview
![overview_brief](./NEDA_overview_brief.jpg)
**Figure 1: A Brief overview of the inputs, outputs, and process steps in NovaScope Exemplary Downstream Analysis (NEDA).**
The strategies "Latent Dirichlet allocation (LDA) + FICTURE" and "Seurat + FICTURE" share the scripts of step1.preprocessing step3.transform, and step4.pixel-level decoding. Their differences lie in two main areas: 1) the configuration file used for input; and 2) the procedures and output files in the second step. Details for each step are provided in the [Starting Downstream Analysis](./analysis/intro.md). SGE: spatial digital gene expression. 