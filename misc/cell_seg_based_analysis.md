
1. Watershed
```bash
neda=/nfs/turbo/sph-hmkang/index/data/weiqiuc/NovaScope_local/NovaScope-exemplary-downstream-analysis
sge_dir=/nfs/turbo/umms-leeju/nova/v2/analysis/n3-hg5mc-b08c-mouse-a6bbf/n3-hg5mc-b08c-mouse-a6bbf-default/sgeAR
output_dir=/nfs/turbo/umms-leeju/nova/v2/analysis/n3-hg5mc-b08c-mouse-a6bbf/n3-hg5mc-b08c-mouse-a6bbf-default/cell_segment

# get the watershed cell segment
#python $neda/scripts/make_segmask.py \
#   --input /nfs/turbo/umms-leeju/Jun-Hee/Segmentation/10XN3-B08C-BW2-cropped-Segmented-Processed.tif \
#   --outpref $output_dir/watershed/n3-hg5mc-b08c-mouse-a6bbf-default-watershed 

# get create the watershed cell segment-based SGE
#python ${neda}/scripts/make_sge_from_npy.py \
#   --input $output_dir/watershed/n3-hg5mc-b08c-mouse-a6bbf-default-watershed_seg.npy \
#   --approach Watershed \
#   --sge_dir $sge_dir \
#   --output_dir $output_dir/watershed/n3-hg5mc-b08c-mouse-a6bbf-default-watershed_seg 

# Seurat test mode
#module load R/4.2.0
#Rscript ${neda}/scripts/seurat_analysis.R \
#    --input_dir $output_dir/watershed/n3-hg5mc-b08c-mouse-a6bbf-default-watershed_seg  \
#    --output_dir $output_dir/watershed/n3-hg5mc-b08c-mouse-a6bbf-default-watershed_seg \
#    --unit_id n3-hg5mc-b08c-mouse-a6bbf-default-watershed \
#    --test_mode --X_col 1 --Y_col 2

```


2. Cellpose
```bash
neda=/nfs/turbo/sph-hmkang/index/data/weiqiuc/NovaScope_local/NovaScope-exemplary-downstream-analysis
sge_dir=/nfs/turbo/umms-leeju/nova/v2/analysis/n3-hg5mc-b08c-mouse-a6bbf/n3-hg5mc-b08c-mouse-a6bbf-default/sgeAR
output_dir=/nfs/turbo/umms-leeju/nova/v2/analysis/n3-hg5mc-b08c-mouse-a6bbf/n3-hg5mc-b08c-mouse-a6bbf-default/cell_segment

# get create the cellpose cell segment-based SGE
#python ${neda}/scripts/make_sge_from_npy.py \
#   --input /nfs/turbo/umms-leeju/Jun-Hee/Segmentation/10XN3-B08C-mouse-hne-fit_seg.npy \
#   --approach Cellpose \
#   --sge_dir $sge_dir \
#   --output_dir $output_dir/cellpose/n3-hg5mc-b08c-mouse-a6bbf-default-cellpose_seg 

# Seurat analysis
module load R/4.2.0
Rscript ${neda}/scripts/seurat_analysis.R \
    --input_dir $output_dir/cellpose/n3-hg5mc-b08c-mouse-a6bbf-default-cellpose_seg  \
    --output_dir $output_dir/cellpose/Seurat  \
    --unit_id n3-hg5mc-b08c-mouse-a6bbf-default-cellpose \
    --nFeature_RNA_cutoff 0 \
    --X_col 1 --Y_col 2
```