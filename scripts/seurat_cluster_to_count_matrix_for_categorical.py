import sys, os, gzip,  argparse
import numpy as np
import pandas as pd
from scipy.sparse import *

parser = argparse.ArgumentParser()
parser.add_argument('--input_csv', type=str, help='')
parser.add_argument('--dge_path', type=str, help='')
parser.add_argument('--output', type=str, help='')
parser.add_argument('--key', type=str, default='gn', help='')
parser.add_argument('--cluster', type=str, default=None, help='')
parser.add_argument('--x_col', type=int, default=None, help='')
parser.add_argument('--y_col', type=int, default=None, help='')
args = parser.parse_args()

'''
args.input_csv="/nfs/turbo/umms-leeju/v5/ldaAR/N3-B08C_mouse_default_QCraret1v4i/segment/gn/d_18/raw_1/Seurat_wc/N3-B08C_mouse_default_QCraret1v4i_cutoff500_metadata.csv"
args.dge_path="/nfs/turbo/umms-leeju/v5/ldaAR/N3-B08C_mouse_default_QCraret1v4i/segment/gn/d_18/raw_1"
args.output="/nfs/turbo/sph-hmkang/index/data/weiqiuc/jobs/N3-B08C_mouse_default_QCraret1v4i___Seurat/N3-B08C_mouse_default_QCraret1v4i_cutoff500_clusterbyres1_test.tsv.gz"
args.cluster="SCT_snn_res.1"
args.key="gn"
args.x_col=2
args.y_col=3
'''


key=args.key
df=pd.read_csv(args.input_csv,header=0,index_col=0)

f=args.dge_path+"/barcodes.tsv.gz"
with gzip.open(f, 'rt') as rf:
    brc_id = [x.strip() for x in rf.readlines()]

brc_id = {x:i for i,x in enumerate(brc_id)}
N = len(brc_id)
r_indx = df.index.map(brc_id).values


# Categorical clustering
if not args.cluster in df.columns:
    sys.exit("Error: specified cluster column not found in input CSV")

cluster_names = sorted(list(df[args.cluster].unique() ) )
cluster_names = [str(x) for x in cluster_names]     # make sure each item in cluster names is a string
cluster_names = [x.replace(' ','_') for x in cluster_names]
K = len(cluster_names)
cluster_id = {x:i for i,x in enumerate(cluster_names)}
df[args.cluster] = df[args.cluster].astype(str) # make sure df[args.cluster] is strings
cmtx = coo_array((np.ones(len(r_indx),dtype=int), (r_indx, df[args.cluster].map(cluster_id).values) ), shape=(N,K)).tocsr()
print(f"Categorical input with {K} categories:")
print(cluster_names)


#with gzip.open(f, 'rt') as rf:
#    brc_id2 = [x.strip() for x in rf.readlines()]
#brc_id2 = {x:i for i,x in enumerate(brc_id2)}
assert args.x_col is not None and args.y_col is not None, "Error: x_col and y_col must be specified"

brc = pd.read_csv(f, sep='_', usecols=[0,args.x_col,args.y_col], names=['j','X','Y'], dtype={'j':int,'X':float,'Y':float})
brc.index = brc.j.values

f=args.dge_path+"/features.tsv.gz"
feature = pd.read_csv(f, sep='\t', usecols=[1], names=['gene'], dtype=str)
feature['i'] = range(1,feature.shape[0]+1)
feature.index = feature.i.values
M = feature.shape[0]

f=args.dge_path+"/matrix.mtx.gz"
reader = pd.read_csv(f,sep=' ',skiprows=3,names=['i','j',key],dtype=int, chunksize=100000)

post_ct = np.zeros((K,M))
for mtx in reader:
    dge = coo_array((mtx[key].values,(mtx.j.values-1, mtx.i.values-1)), shape=(N,M), dtype=int).tocsr()
    post_ct += cmtx.T @ dge

post_sum = post_ct.sum()
post_ct = pd.DataFrame(post_ct.T, columns = cluster_names)
post_ct['gene'] = feature.gene.values
post_ct_refine = post_ct[['gene']+cluster_names]

# remove the rows that have zero counts in all clusters
post_ct_nozero = post_ct_refine.loc[post_ct_refine[cluster_names].sum(axis=1)>0,:]  
post_ct_nozero.to_csv(args.output, sep='\t', index=False, header=True, float_format="%.2f")