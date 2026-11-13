#!/usr/bin/env python3
"""ANI heatmap with collision-free selected labels and leader lines.
Run alongside pectobacterium_ANI_matrix.csv and corrected iTOL labels.
Requires numpy, pandas, scipy, matplotlib.
"""
import re
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.cluster.hierarchy import linkage, dendrogram
from scipy.spatial.distance import squareform
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.gridspec import GridSpec
from matplotlib.transforms import blended_transform_factory

MATRIX='pectobacterium_ANI_matrix.csv'
LABELS='itol_selected_leaf_labels_corrected(3).txt'
ani=pd.read_csv(MATRIX,index_col=0)
assert ani.shape==(220,220) and list(ani.index)==list(ani.columns)
a=ani.to_numpy(float)
assert np.isfinite(a).all() and np.allclose(a,a.T,atol=1e-5)
ids=[re.search(r'GCA_\d+\.\d+',s).group(0) for s in ani.index]
with open(LABELS) as f: lines=f.read().splitlines()
start=next(i for i,s in enumerate(lines) if s.strip()=='DATA')
selected={}
for line in lines[start+1:]:
    p=line.split('\t')
    if len(p)<2: continue
    m=re.search(r'(GCA_\d+)_(\d+)',p[0])
    if m: selected[m.group(1)+'.'+m.group(2)]=p[1]
missing=set(selected)-set(ids)
if missing: raise ValueError('Missing accessions: '+str(missing))
if len(selected)!=24: raise ValueError(f'Expected 24 labels, got {len(selected)}')

Z=linkage(squareform(100-a,checks=False),method='average')
order=dendrogram(Z,no_plot=True)['leaves']
ordered=a[np.ix_(order,order)]
chosen=[(i,selected[ids[original]]) for i,original in enumerate(order) if ids[original] in selected]

# Position labels without overlap while retaining their original ordering.
def spread(positions, gap, lower, upper):
    target=np.array(positions,dtype=float)
    if len(target)<2: return target
    gap=min(gap,(upper-lower)/(len(target)-1))
    out=np.maximum(target,lower+np.arange(len(target))*gap)
    out[-1]=min(out[-1],upper)
    for i in range(len(out)-2,-1,-1): out[i]=min(out[i],out[i+1]-gap)
    if out[0]<lower: out+=lower-out[0]
    return out

# Wider output provides sufficient label space for the long type-strain names.
fig=plt.figure(figsize=(17,15.5))
gs=GridSpec(2,2,figure=fig,width_ratios=[1.1,12],height_ratios=[1.15,12],left=.055,right=.67,bottom=.22,top=.96,wspace=.015,hspace=.015)
ax_top=fig.add_subplot(gs[0,1]); ax_left=fig.add_subplot(gs[1,0]); ax=fig.add_subplot(gs[1,1])
dendrogram(Z,ax=ax_top,no_labels=True,color_threshold=0,above_threshold_color='#555555',link_color_func=lambda k:'#555555')
ax_top.set_xticks([]);ax_top.set_yticks([]);[s.set_visible(False) for s in ax_top.spines.values()]
dendrogram(Z,ax=ax_left,orientation='left',no_labels=True,color_threshold=0,above_threshold_color='#555555',link_color_func=lambda k:'#555555')
ax_left.set_xticks([]);ax_left.set_yticks([]);[s.set_visible(False) for s in ax_left.spines.values()]
# scipy dendrogram leaf coordinates: 5,15,...; imshow centers 0..n-1
ax_top.set_xlim(0,10*len(order)); ax_left.set_ylim(10*len(order),0)
colors=['#f7fbff','#c6dbef','#6baed6','#2171b5','#08306b']
cmap=LinearSegmentedColormap.from_list('ani',colors,N=256)
im=ax.imshow(ordered,cmap=cmap,vmin=np.floor(np.min(a)*10)/10,vmax=100,interpolation='nearest',aspect='equal',origin='upper')
ax.set_xlim(-.5,219.5);ax.set_ylim(219.5,-.5)
ax.set_xticks([]);ax.set_yticks([]);[s.set_visible(False) for s in ax.spines.values()]

# Right labels: positions are in data coordinates, leader lines start at true row centers.
pos=np.array([p for p,_ in chosen],dtype=float)
right_y=spread(pos,5.5,-.3,219.3)
for (p,name),y in zip(chosen,right_y):
    ax.plot([219.7,224,229],[p,p,y],color='#666666',lw=.48,clip_on=False)
    ax.text(230,y,name,fontsize=7.7,va='center',ha='left',clip_on=False)
# Bottom labels: same strategy, but 90-degree rotation for compact width.
bottom_x=spread(pos,5.6,-.3,219.3)
for (p,name),x in zip(chosen,bottom_x):
    ax.plot([p,p,x],[219.7,224,229],color='#666666',lw=.48,clip_on=False)
    ax.text(x,231,name,fontsize=7.7,rotation=90,va='top',ha='center',clip_on=False)
# Compact colourbar in the far right margin, away from the labels.
cax=fig.add_axes([.945,.64,.014,.23])
cb=fig.colorbar(im,cax=cax);cb.set_label('ANI (%)',fontsize=10)
cb.ax.tick_params(labelsize=9)
fig.savefig('pectobacterium_ANI_heatmap_spaced_labels.pdf',bbox_inches='tight',pad_inches=.3)
fig.savefig('pectobacterium_ANI_heatmap_spaced_labels.png',dpi=170,bbox_inches='tight',pad_inches=.3)
print(f'Saved heatmap with {len(chosen)} selected labels on both axes.')
