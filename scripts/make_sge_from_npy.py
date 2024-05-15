import argparse
import numpy as np
import pandas as pd
from scipy.io import mmread, mmwrite
from scipy.sparse import csr_matrix
import gzip, os

# load 
def load_segmentation(input, approach):
    if approach == "Watershed":
        segmentation = np.load(input)
    elif approach == "Cellpose":
        data = np.load(input, allow_pickle=True)
        cellpose_data = data.item()
        segmentation = cellpose_data['masks']
    return segmentation

def load_barcodes(sge_dir, x_col, y_col, count_col, mu_scale, segmentation):
    # Construct full paths for the data files
    bcd_path = f"{sge_dir}/barcodes.tsv.gz" 
    with gzip.open(bcd_path, 'rt') as f:
        barcodes = pd.read_csv(f, delimiter='\t', header=None)
    # Assume the columns are named appropriately based on your data
    barcodes = barcodes.iloc[:, [0, x_col-1, y_col-1, count_col-1]]
    barcodes.columns = ['Barcode', 'X', 'Y', 'Counts']
    # Convert coordinates to segmentation scale
    barcodes['Segment_X'] = barcodes['X'] // mu_scale
    barcodes['Segment_Y'] = barcodes['Y'] // mu_scale
    # Map each barcode to a segment
    barcodes['Segment_ID'] = segmentation[barcodes['Segment_Y'], barcodes['Segment_X']]
    return barcodes

# aggregate
def aggregate_expression_data_optimized(barcodes, matrix):
    # Aggregate expression data by segment
    aggregated_data = []
    for segment_id in np.unique(barcodes['Segment_ID']):
        if segment_id == 0:
            continue
        mask = barcodes['Segment_ID'] == segment_id
        segment_barcodes = barcodes[mask]
        segment_expression = matrix[:, mask].sum(axis=1)
        x_avg = int(segment_barcodes['X'].mean())
        y_avg = int(segment_barcodes['Y'].mean())
        new_barcode = f'{x_avg}_{y_avg}'
        aggregated_data.append((new_barcode, segment_expression))
    return aggregated_data

# output
def write_barcodes_from_aggregate(aggregated_data, output_dir):
    barcodes = [x[0] for x in aggregated_data]
    barcodes_output_path = f"{output_dir}/barcodes.tsv.gz"
    with gzip.open(barcodes_output_path, 'wt') as f:
        for barcode in barcodes:
            f.write(barcode + '\n')

def write_matrix_from_aggregate(aggregated_data, output_dir):
    expressions_new = csr_matrix(np.hstack([x[1] for x in aggregated_data]))
    matrix_output_path = f"{output_dir}/matrix.mtx.gz"
    with gzip.open(matrix_output_path, 'wb') as f:
        mmwrite(f, expressions_new, field='integer', symmetry='general')

def link_features_from_input(input_dir, output_dir):
    input_path=os.path.join(input_dir, "features.tsv.gz")
    output_path=os.path.join(output_dir, "features.tsv.gz")
    # if the output_path does not exist, create a symlink
    if not os.path.exists(output_path):
        os.symlink(input_path, output_path)
        print(f"Created a symlink for features.tsv.gz: {input_path} -> {output_path}")
    else:
        print(f"The output directory already contains a features.tsv.gz file. No symlink created.")        

def write_feature_from_input(input_dir, output_dir):
    input_path=os.path.join(input_dir, "features.tsv.gz")
    with gzip.open(input_path, 'rt') as f:
        features = pd.read_csv(f, delimiter='\t', header=None)
    output_path=os.path.join(output_dir, "features.tsv.gz")
    # write down only the first two columns as a zipped tsv file
    features.iloc[:, :2].to_csv(output_path, sep='\t', header=False, index=False, compression='gzip')
    


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process segmentation data into aggregated expression matrices.")
    parser.add_argument('--input', type=str, required=True, help='Path to the input numpy array file.')
    parser.add_argument('--approach', type=str, required=True, choices=["Watershed", "Cellpose"], help='The tool that creates the input file.')
    parser.add_argument('--sge_dir', type=str, required=True, help='Directory path containing input spatial gene expression matrix, which should have barcodes.tsv.gz and matrix.mtx.gz files.')
    parser.add_argument('--output_dir', type=str, required=True, help='Output directory where the results will be saved.')
    parser.add_argument('--mu_scale', type=int, default=1000, help='Scaling factor for coordinate conversion.')
    parser.add_argument('--x_col', type=int, default=6, help='Which column in the input barcode file is X? Default: 5.')
    parser.add_argument('--y_col', type=int, default=7, help='Which column in the input barcode file is Y? Default: 6.')
    parser.add_argument('--count_col', type=int, default=8, help='Which column in the input barcode file is count information? Default: 7.')
    args = parser.parse_args()
   
    # test
    #args.input="/nfs/turbo/umms-leeju/Jun-Hee/Segmentation/Watershed_seg.npy"
    #args.approach="Watershed"
    #args.sge_dir="/nfs/turbo/umms-leeju/nova/v2/align/N3-HG5MC/B08C/n3-hg5mc-b08c-mouse-a6bbf/sge"
    #args.output_dir="/nfs/turbo/umms-leeju/nova/v2/analysis/n3-hg5mc-b08c-mouse-a6bbf/n3-hg5mc-b08c-mouse-a6bbf-default/cell_segment/watershed/n3-hg5mc-b08c-mouse-a6bbf-default-watershed_seg_rep_w_same_readbcd"
    #args.mu_scale=1000
    #args.x_col=6
    #args.y_col=7
    #args.count_col=8

    # sanity check: 
    # 1) sge_dir exists
    assert os.path.exists(args.sge_dir), f"Error: sge_dir does not exist: {args.sge_dir} "
    # 2) sge_dir should also have the following three files: barcodes.tsv.gz  features.tsv.gz  matrix.mtx.gz
    assert os.path.exists(f"{args.sge_dir}/barcodes.tsv.gz"), f"Error: {args.sge_dir}/barcodes.tsv.gz does not exist."
    assert os.path.exists(f"{args.sge_dir}/features.tsv.gz"), f"Error: {args.sge_dir}/features.tsv.gz does not exist."
    assert os.path.exists(f"{args.sge_dir}/matrix.mtx.gz"), f"Error: {args.sge_dir}/matrix.mtx.gz does not exist."
    # 3) input file exists
    assert os.path.exists(args.input), f"Error: input file does not exist: {args.input} "
    # 4）output dir
    if os.path.exists(args.output_dir):
        print(f"Warning: output directory already exists. This may overwrite the existing files in {args.output_dir}.")
    else:
        os.makedirs(args.output_dir)

    # Read input
    print("Reading segmentation data...")
    segmentation = load_segmentation(args.input, args.approach)
    print("Reading barcodes...")
    barcodes     = load_barcodes(args.sge_dir, args.x_col, args.y_col, args.count_col, args.mu_scale, segmentation)
    print("Reading expression matrix...")
    matrix       = mmread(f"{args.sge_dir}/matrix.mtx.gz").tocsc()

    # Aggregate expression data
    print("Aggregating expression data...")
    aggregated_data = aggregate_expression_data_optimized(barcodes, matrix)

    # Convert aggregated data to DataFrame (or any format compatible with your downstream tools)
    #aggregated_df = pd.DataFrame({
    #    'Barcode': [x[0] for x in aggregated_data],
    #    'Expression': [x[1] for x in aggregated_data]
    #})

    # output
    print("Writing output files...")
    write_barcodes_from_aggregate(aggregated_data, args.output_dir)
    write_matrix_from_aggregate(aggregated_data, args.output_dir)
    #link_features_from_input(args.sge_dir, args.output_dir)
    write_feature_from_input(args.sge_dir, args.output_dir)
