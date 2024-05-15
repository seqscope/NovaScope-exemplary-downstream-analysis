library(Seurat)
library(ggplot2)
library(patchwork)
library(dplyr)
library(tidyverse)
library(stringr)
library(cowplot)
library(optparse)
library(grDevices)
library(RColorBrewer)

# Define the command line options
option_list <- list(
  make_option(c("-i", "--input_dir"), type = "character", default = "", help = "Input directory, which should contains the non-overlapping hexagon files.", metavar = "DIR"),
  make_option(c("-o", "--output_dir"), type = "character", default = "", help = "Output directory.", metavar = "DIR"),
  make_option(c("-u", "--unit_id"), type = "character", default = "", help = "The unique identifier of the dataset.", metavar = "STRING"),
  make_option(c("-t", "--test_mode"), action = "store_true", default = FALSE, help = "Enable the mode to test different cutoff values for nFeature_RNA, including 50,100,200,300,400,500,750,1000. Default: FALSE."),
  make_option(c("-c", "--nFeature_RNA_cutoff"), type = "numeric", default = 300, help = "Cutoff value for filtering hexagons by nFeature_RNA. Default: 300. ", metavar = "VALUE"),
  make_option("--split_str", type = "character", default = "_",  help = "To extract X and Y coordinates from hexagon ID, i.e., the barcode ID, specifiy the split character in the hexagon ID. Default: _", metavar = "VALUE"),
  make_option("--X_col", type = "numeric", default = 3,  help = "Which column in the hexagon ID is X? Please count the column from 1. Default: 3.", metavar = "VALUE"),
  make_option("--Y_col", type = "numeric", default = 4,  help = "Which column in the hexagon ID is Y? Please count the column from 1. Default: 4.", metavar = "VALUE"),
  make_option("--Y_min", type = "numeric", default = NA,  help = "Cutoff min value for Y. Default: NA.", metavar = "VALUE"),
  make_option("--X_min", type = "numeric", default = NA, help = "Cutoff min value for X. Default: NA.", metavar = "VALUE"),
  make_option("--Y_max", type = "numeric", default = NA, help = "Cutoff max value for Y. Default: NA.", metavar = "VALUE"),
  make_option("--X_max", type = "numeric", default = NA, help = "Cutoff max value for X. Default: NA.", metavar = "VALUE")

)

opt_parser <- OptionParser(option_list = option_list,
                           usage = "Usage: %prog [options]",
                           description = paste(
                             "Load R if needed:",
                             "  module load R/4.2.0",
                             "First use --test_mode to test different cut off on nFeature_RNA by:",
                             "  Rscript seurat_analysis.R --input_dir /nfs/turbo/umms-leeju/v5/ldaAR/N3-B08C_mouse_default_QCraret1v4/segment/gn/d_24/raw_1 --output_dir /nfs/turbo/umms-leeju/v5/ldaAR/N3-B08C_mouse_default_QCraret1v4/segment/gn/d_24/raw_1/Seurat_wc_test --test_mode --unit_id B08C_t1v4",
                             "Then identify the right cutoff and coordinates limits from the density plot and use it to filter the hexagons by:",
                             "  Rscript seurat_analysis.R --input_dir /nfs/turbo/umms-leeju/v5/ldaAR/N3-B08C_mouse_default_QCraret1v4/segment/gn/d_24/raw_1 --output_dir /nfs/turbo/umms-leeju/v5/ldaAR/N3-B08C_mouse_default_QCraret1v4/segment/gn/d_24/raw_1/Seurat_wc --unit_id B08C_t1v4 --nFeature_RNA_cutoff 300 --X_min 2e+06 --X_max 8e+06 --Y_min 1e+06  --Y_max 6e+06",
                             sep = "\n")
)
opts = parse_args(opt_parser)

# Script Test
script_test <- FALSE
if (script_test){
  opts$input_dir <-  "/nfs/turbo/umms-leeju/v5/ldaAR/N3-B08C_mouse_default_QCraret1v4/segment/gn/d_24/raw_1" 
  opts$output_dir <- "/nfs/turbo/umms-leeju/v5/ldaAR/N3-B08C_mouse_default_QCraret1v4/segment/gn/d_24/raw_1/Seurat_wc"
  opts$test_mode <- FALSE
  opts$unit_id<-"B08C_t1v4"
  opts$nFeature_RNA_cutoff<-300
  opts$X_min<-2e+06
  opts$X_max<-8e+06
  opts$Y_min<-1e+06
  opts$Y_max<-6e+06
}

# Input/Output directory
if (is.null(opts$input_dir)) {
  stop("Input directory not specified. Use --input_dir to specify it.", call. = FALSE)
}

if (is.null(opts$output_dir)) {
  if (opts$test_mode) {
    opts$output_dir <- paste0(opts$input_dir, "/Seurat_test")
  } else {
    opts$output_dir <- paste0(opts$input_dir, "/Seurat")
  }
}

if (!dir.exists(opts$output_dir)) {
  dir.create(opts$output_dir, recursive = TRUE)
}

# Log the input parameters
message("=========================================")
message(paste0("Date: ", date()))
message(paste0("Input dataset: ", opts$unit_id))
message(paste0("Input directory: ", opts$input_dir))
message(paste0("Output directory: ", opts$output))
message(paste0("Test mode: ", opts$test_mode))
if (opts$test_mode) {
  message(" The script will test different cutoff values for nFeature_RNA, from 50,100,200,300,400,500,750,1000.")
} else {
  message(paste0(" nFeature_RNA_cutoff: ", opts$nFeature_RNA_cutoff))
}
message(paste0("X range: [",opts$X_min,", ", opts$X_max,"]"))
message(paste0("Y range: [",opts$Y_min,", ", opts$Y_max,"]"))

#===============================================================================
#
# General functions for visualization in R.
#
#===============================================================================

# Custom theme for ggplot2
theme_wc <- function(base_size = 14) {
  theme_bw(base_size = base_size) %+replace%
    theme(
      plot.title = element_text(size = rel(1), margin = margin(0,0,5,0), hjust = 0.5),
      plot.subtitle = element_text(size = rel(0.70), hjust = 0.5),
      #axis
      axis.title = element_text(size = rel(0.85)),
      axis.text = element_text(size = rel(0.70)),
      #legend
      legend.title = element_text(size = rel(0.85)),
      legend.text = element_text(size = rel(0.70)),
      legend.key = element_rect(fill = "transparent", colour = NA),
      legend.key.size = unit(1.5, "lines"),
      legend.background = element_rect(fill = "transparent", colour = NA),
      #text
      text=element_text(family="DejaVu Sans", colour = "black")
    )
}


# Function to prep color palette for a large number of colors
extend_palette <- function(num_colors, color_space = "Lab") {
  palette_max_colors <- c(Set3 = 12, Set1 = 9, Dark2 = 8, Paired = 12)
  combined_palette <- c()
  for (palette_name in names(palette_max_colors)) {
    if (num_colors > length(combined_palette)) {
      n_colors <- min(num_colors, palette_max_colors[palette_name])
      combined_palette <- c(combined_palette, brewer.pal(n_colors, palette_name))
      combined_palette <- unique(combined_palette)
    }
  }
  if (num_colors > length(combined_palette)) {
    additional_colors_needed <- num_colors - length(combined_palette)
    color_ends <- if (color_space == "Lab") { c("red", "blue", "green", "yellow") } else {c("red", "blue") }
    color_generator <- colorRampPalette(color_ends, space = color_space)
    additional_colors <- color_generator(additional_colors_needed)
    combined_palette <- c(combined_palette, additional_colors)
  }
  return(combined_palette[1:num_colors])
}

#==============================================================================
#
# 1. Read in the expression matrix
#
#==============================================================================
message("=========================================")
message("1. Reading the raw input data...")
expression_matrix <- Read10X(data.dir = opts$input_dir)
adata <- CreateSeuratObject(counts = expression_matrix)
message(paste0(" - Number of features: ",adata@assays$RNA@counts %>% nrow()))
message(paste0(" - Number of hexagons: ",adata@assays$RNA@counts %>% ncol()))

# Extract X and Y coordinates from row names
# - TODO: allow the users to input 
message(" - Extracting coordinates...")
message(paste0("   An example of hexagon ID:", rownames(adata@meta.data)[1],".\n",
               "   We will use col ", opts$X_col ," as X and col ", opts$Y_col ," as Y."))

hexagonID_ncol <- length(str_split(rownames(adata@meta.data)[1], opts$split_str)[[1]])
coords <- str_split_fixed(rownames(adata@meta.data), opts$split_str, hexagonID_ncol)
adata$X <- as.numeric(coords[, opts$X_col])
adata$Y <- as.numeric(coords[, opts$Y_col])

##===============================================================================
##
# 2. Preprocess the data
##
##===============================================================================
message("=========================================")
message("2. Preprocessing...")

# 2.1 Filter mitochondrial and hypothetical genes
message("2.1 Filtering mitochondrial and hypothetical genes...")
message(paste0(" - Remove mitochondrial genes: N=", sum(grepl("^mt-|^MT-", rownames(adata)))))
message(paste0(" - Remove hypothetical genes:  N=", sum(grepl("^Gm-", rownames(adata)))))

adata <- subset(adata,features = rownames(adata)[!grepl("^Gm-|^mt-|^MT-", rownames(adata))] )

# 2.2 Filter hexagon with low quality
message("2.2 Explore Ncount and Nfeature...")
message(" - nCount_RNA:")
message(paste0("     - Mean:", mean(adata$nCount_RNA)))
message(paste0("     - Total:", length(adata$nCount_RNA)))

# 2.2.1 Plot the distribution of nFeature_RNA in seurat object
message(paste0(" - Drawing a distribution plot of nFeature_RNA into: ", opts$output_dir, "/nFeature_RNA_dist.png"))
binwidth = 100 
total_obs = nrow(adata@meta.data) 

dist_nFeature_RNA <- ggplot(adata@meta.data, aes(x = nFeature_RNA)) +
  geom_histogram(aes(y = ..count.. / total_obs * 100), binwidth = binwidth, fill = "skyblue", color = "black") +
  geom_text(stat = 'bin', aes(y = (..count../total_obs)*100, label = sprintf("%.2f%%", (..count../total_obs)*100)),
            vjust = -0.5, hjust = 0, angle = 20, binwidth = binwidth, color = "black", size = 3) +
  theme_wc() +
  ylab("Percentage of Total") + 
  xlab("nFeature_RNA per hexagon") +
  #scale_y_continuous(labels = percent_format(accuracy = 1)) +
  ggtitle("nFeature_RNA Distribution")

ggsave(filename = paste0(opts$output_dir, "/nFeature_RNA_dist.png"), plot = dist_nFeature_RNA, width = 10, height = 5)

# 2.2.2 Plot the volin plots of nFeature_RNA and nCount_RNA
message(paste0(" - Drawing a Vln of nFeature_RNA and nCount_RNA in ", opts$output_dir, "/Ncount_Nfeature_vln.png"))
vln_nFeature <- VlnPlot(adata, features = 'nFeature_RNA', pt.size = 0) + 
  ggtitle("nFeature_RNA")+ 
  theme(legend.position = "none") 

vln_nCount <- VlnPlot(adata, features = 'nCount_RNA', pt.size = 0) + 
  ggtitle("nCount_RNA")+ 
  theme(legend.position = "none") 

vln_plot <- cowplot::plot_grid(vln_nFeature, vln_nCount, ncol = 2)

ggsave(filename = paste0(opts$output_dir, "/Ncount_Nfeature_vln.png"), plot = vln_plot, width = 10, height = 10)

# 2.2.3 Density plot of nFeature_RNA and nCount_RNA
message(paste0(" - Drawing a density plot of nFeature_RNA and nCount_RNA in ", opts$output_dir, "/Nfeature_density_cutoff*.png"))

# Function to calculate plot dimensions based on spatial data ranges
calculate_plot_dimensions <- function(adata) {
  x_range <- range(adata@meta.data$X, na.rm = TRUE)
  y_range <- range(adata@meta.data$Y, na.rm = TRUE)
  aspect_ratio <- (x_range[2] - x_range[1]) / (y_range[2] - y_range[1])
  return(aspect_ratio)
}

# Function to create a faceted density plot for raw and QCed data
create_faceted_density_plot <- function(adata_raw, adata_QCed, x_var, y_var, QC_var, QC_cutoff, output_dir,color_var=NA, width=15, height=15, dpi=300){
  adata_raw@meta.data[["Status"]] <- "Raw"
  adata_QCed@meta.data[["Status"]]  <- "QCed"
  adata_combined <- rbind(adata_raw@meta.data, adata_QCed@meta.data)
  if (is.na(color_var)){
    color_var <- QC_var
  }

  p <- ggplot(adata_combined, aes_string(x = x_var, y = y_var, color = color_var)) +
    geom_point(size = 0.01) +
    scale_color_gradient(low = "grey90", high = "black") +
    facet_wrap(~ Status, scales = "fixed") + 
    theme_wc() +
    xlab(x_var) + ylab(y_var) +
    ggtitle(paste("Density plot of", QC_var, "with cutoff at", QC_cutoff)) +
    theme(legend.position = "right") +
    coord_fixed()

  output_filename<-file.path(output_dir, paste0("",QC_var,"_cutoff",QC_cutoff,".png"))
  ggsave(filename = output_filename,
         plot = p,
         width = width,
         height = height,
         dpi = dpi)
}

# Density plot depending on the test mode
if (opts$test_mode) {
  message(" - Testing different cutoff values for nFeature_RNA...")
  for (nFeature_RNA_cutoff in c(50,100,200,300,400,500,750,1000)) {
    adata_QCed <- subset(adata, subset = nFeature_RNA > nFeature_RNA_cutoff)
    create_faceted_density_plot(adata_raw=adata,
                                adata_QCed=adata_QCed,
                                x_var="Y",
                                y_var="X",
                                QC_var="nFeature_RNA",
                                QC_cutoff=nFeature_RNA_cutoff,
                                output_dir=opts$output_dir,
                                color_var="nFeature_RNA",
                                width=12,
                                height=12,
                                dpi=300)
  }
  message("==> End the execution of the script since --test_mode is enabled.")
  #quit(save = "no", status = 1)
  quit(save = "no", status = 0)  # Exiting with status 0 for successful test completion
}else{
  nFeature_RNA_cutoff=opts$nFeature_RNA_cutoff
  adata_QCed <- subset(adata, subset = nFeature_RNA > nFeature_RNA_cutoff)
  message(paste0(" - Filter adata by nFeature_RNA > ", nFeature_RNA_cutoff))
  create_faceted_density_plot(adata_raw=adata,
                              adata_QCed=adata_QCed,
                              x_var="Y",
                              y_var="X",
                              QC_var="nFeature_RNA",
                              QC_cutoff=nFeature_RNA_cutoff,
                              output_dir=opts$output_dir,
                              color_var="nFeature_RNA",
                              width=12,
                              height=12,
                              dpi=300)
                              
  message(" - The density plot of nFeature_RNA and nCount_RNA in ", opts$output_dir, "/Nfeature_density_cutoff*.png")
  adata <- adata_QCed
}

#2.4 Filter hexagons by X and Y
if (!is.na(opts$Y_min) | !is.na(opts$X_min) | !is.na(opts$Y_max) | !is.na(opts$X_max)) {
  message(paste0(" - Filter adata by X_min=", opts$X_min, ", X_max=", opts$X_max, ", Y_min=", opts$Y_min, ", Y_max=", opts$Y_max))

  if (!is.na(opts$Y_min)) {
    adata=subset(adata, Y > opts$Y_min)
  }
  if (!is.na(opts$X_min)) {
    adata=subset(adata, X > opts$X_min)
  }
  if (!is.na(opts$Y_max)) {
    adata=subset(adata, Y < opts$Y_max)
  }
  if (!is.na(opts$X_max)) {
    adata=subset(adata, X < opts$X_max)
  }
}else {
   message(" - No filtering by X and Y.")
}

#===============================================================================
#
# 3. SCTransform, RunPCA, RunUMAP, and FindNeighbors
#
#===============================================================================

message("=========================================")
message("3. Running SCTransform, RunPCA, RunUMAP, and FindNeighbors...")
adata <- SCTransform(adata)
adata <- RunPCA(adata)
adata <- RunUMAP(adata, dims = 1:30)
adata <- FindNeighbors(adata, dims = 1:30)

# Add UMAP1 and UMAP2 to metadata
adata$UMAP1 <- adata@reductions$umap@cell.embeddings[,1]
adata$UMAP2 <- adata@reductions$umap@cell.embeddings[,2]

#===============================================================================
#
# 4. Clustering and imaging
#
#===============================================================================

message("=========================================")
message("4. Clustering and imaging...")

output_prefix=paste0(opts$output_dir, "/", opts$unit_id, "_cutoff", as.character(nFeature_RNA_cutoff))

# function to perform clustering and imaging at a given resolution
clustering_by_resolution <- function(adata, resolution, output_prefix,base_size=10) {
  # Basic settings
  aspect_ratio <- calculate_plot_dimensions(adata)
  base_filename <- paste0(output_prefix, "_res", resolution)

  # Clustering
  adata <- FindClusters(adata, resolution = resolution)
  
  # DE markers
  de_markers <- FindAllMarkers(adata, only.pos = TRUE)
  write.csv(de_markers, paste0(base_filename, "_DE.csv"))
  
  # Prep color palette
  Ncluster=length(summary(adata@meta.data$seurat_clusters))  
  my_color_palette <- extend_palette(Ncluster, "Lab")
  
  # Dimension Plot
  dim_panel <- DimPlot(adata, label = TRUE) + ggtitle(paste("Dim Plot, Resolution:", resolution))+ 
    theme_wc() +
    scale_color_manual(values = my_color_palette, name="Seurat clusters") +  
    guides(color = guide_legend(override.aes = list(size = 5))) 
  
  # Spatial Plot
  spatial_panel <- ggplot(adata@meta.data, aes(x = Y, y = X, col = as.factor(seurat_clusters))) + 
    geom_point(size = .1) + 
    theme_wc() + 
    coord_fixed() +  # Ensure 1:1 aspect ratio
    scale_color_manual(values = my_color_palette, name="Seurat clusters") + 
    guides(color = guide_legend(override.aes = list(size = 5))) +
    ggtitle(paste0("Spatial plot, Resolution: ", resolution))
  
  # Combine plots
  combined_plot <- plot_grid(
    dim_panel + theme(legend.position = "none"), 
    spatial_panel + theme(legend.position = "none"), 
    get_legend(dim_panel),
    ncol = 3,
    rel_widths = c(1, 1/aspect_ratio, 0.2)
  )
  
  # Add a white background
  final_plot <- ggdraw() + 
    draw_plot(combined_plot, 0, 0, 1, 1) + 
    theme(plot.background = element_rect(fill = "white", colour = NA))
  
  ggsave(paste0(base_filename, "_DimSpatial.png"), 
         plot = final_plot, 
         width = base_size * (1.2 + aspect_ratio),
         height = base_size, units="in",
         dpi = 300)
  return(adata)
}

# Loop over resolutions
for (resolution in c(0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75)) {
  message(paste0(" - Clustering and imaging at resolution ", resolution))
  adata <- clustering_by_resolution(adata, resolution, output_prefix,base_size=7)
}

# 5. Save the data
message("=========================================")
message("5. Saving the data...")
message(paste0(" - Saving the Seurat object to ", output_prefix, "_SCT.RDS"))
message(paste0(" - Saving the metadata to ", output_prefix, "_metadata.csv"))

saveRDS(adata, file=paste0(output_prefix, "_SCT.RDS"))

adata@meta.data %>% select(X, Y,
                           nCount_RNA, nFeature_RNA,
                           nCount_SCT, nFeature_SCT, UMAP1, UMAP2, 
                           SCT_snn_res.0.25, SCT_snn_res.0.5, SCT_snn_res.0.75,
                           SCT_snn_res.1, SCT_snn_res.1.5, SCT_snn_res.1.75,
)%>%
  write.csv(.,paste0(output_prefix, "_metadata.csv"))
