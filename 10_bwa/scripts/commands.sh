
### Get reference genome assembly
ln -s ../01_genomes/ZRIMU1702DQ_brasiliense.fasta .

### Get sequence reads
ln -s ../07_trimmed/PRT5_1_val_1.fq.gz  ../07_trimmed/PRT5_2_val_2.fq.gz .



conda create -n bwa_env
conda activate bwa_env
conda install bioconda::bwa
conda list -n bwa_env > bwa_env_packages.txt
conda env export > bwa_env.yaml

bwa index ZRIMU1702DQ_brasiliense.fasta

bwa mem ZRIMU1702DQ_brasiliense.fasta PRT5_1_val_1.fq.gz PRT5_2_val_2.fq.gz > PRT5-versus-ZRIMU1702DQ.sam


samtools view -bS PRT5-versus-ZRIMU1702DQ.sam -o PRT5-versus-ZRIMU1702DQ.bam

samtools sort PRT5-versus-ZRIMU1702DQ.bam -o PRT5-versus-ZRIMU1702DQ.sorted.bam
   
samtools rmdup PRT5-versus-ZRIMU1702DQ.sorted.bam PRT5-versus-ZRIMU1702DQ.sorted.rmdup.bam

samtools index PRT5-versus-ZRIMU1702DQ.sorted.rmdup.bam

rm PRT5-versus-ZRIMU1702DQ.sam PRT5-versus-ZRIMU1702DQ.bam PRT5-versus-ZRIMU1702DQ.sorted.bam





