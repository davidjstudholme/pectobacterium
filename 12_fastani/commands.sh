### PRepare lists of query and reference genomes
ls ../01_genomes/*brasiliense.fasta  ../01_genomes/*jejuense.fasta  ../08_unicycler/PRT5.unicycler.assembly.fasta > ref_list.txt
ls ../01_genomes/*brasiliense.fasta  ../01_genomes/*jejuense.fasta  ../08_unicycler/PRT5.unicycler.assembly.fasta > query_list.txt

### FastANI has already been installed via Conda
conda activate fastani_env
conda list -n fastani_env > fastani_env_packages.txt
conda env export > fastani_env.yaml

fastANI --ql query_list.txt --rl ref_list.txt -o Xeu-fastANI.short.out -t 6 --visualize --matrix
