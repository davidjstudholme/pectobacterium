
# Get protein sequence
efetch -db protein \
  -id MHG0286679.1 \
  -format fasta > MHG0286679.1.faa


# Copy genomes
cd genomes
ln -s ../../../01_genomes/*.fna .
cd -

# Run the pipeline
python3 pectobacterium_tblastn_itol.py \
  --genomes genomes/ \
  --protein MHG0286679.1.faa \
  --outdir MHG0286679_results \
  --threads 12

