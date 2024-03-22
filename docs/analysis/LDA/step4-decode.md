# Latent Dirichlet Allocation (LDA) + FICTURE analytical strategy

## Step 4 Pixel-level Decoding

**Prefix**:

The decode_prefix will be automatically defined as below.
```
decode_prefix="${train_prefix}.decode.prj_${pw}.r_${ar}_${nr}"
```

* `nr`: represents neighbor_radius. By default, `nr=ar+1`.


### step 4.1 Pixel-level Decoding. 
Decoding the model matrix on individual pixels, which returns a tab-delimited file of the posterior count of factors on individual pixels.

Input & Output
```
# Input:
${output_dir}/${prefix}.coordinate_minmax.tsv
${output_dir}/${prefix}.batched.matrix.tsv.gz
${output_dir}/${prefix}.QCed.matrix.tsv.gz
${model_dir}/${tranform_prefix}.model.p         # The format of the model file varies between LDA and Seurat.
${model_dir}/${tranform_prefix}.fit_result.tsv.gz

#Output: 
${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz
```

Command:
```
$neda_dir/steps/step4.1-pixel-level-decode.sh $input_configfile
```

### step 4.2 Visualizing Pixel-Level Decoding and Generating Marker Gene Reports
Identifying marker genes for each factor/cluster, and generating a report html file that summarizes individual factors and marker genes. In addition, this step creates a high-resolution image of cell type factors for individual pixels.

Input & Output
```
#Input:
${model_dir}/${decode_prefix}.posterior.count.tsv.gz
${model_dir}/${tranform_prefix}.rgb.tsv

#Output: 
${model_dir}/${decode_prefix}.bulk_chisq.tsv
${model_dir}/${decode_prefix}.factor.info.html
${model_dir}/${decode_prefix}.pixel.png
```

Command:
```
$neda_dir/steps/step4.2-pixel-level-visualization-and-report.sh $input_configfile
```