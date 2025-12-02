
### Trim and filter the reads
for i in 41 P2 PRT5; do echo $i; trim_galore -q 30 --paired $i"_1.fastq.gz" $i"_2.fastq.gz" ; done

conda activate unicycler_env

for i in  41 P2 PRT5; do echo $i;  unicycler -1 $i"_1_val_1.fq.gz"  -2 $i"_2_val_2.fq.gz" -o $i.unicycler; done

ln -s 41.unicycler/assembly.fasta 41.unicycler.assembly.fasta
ln -s P2.unicycler/assembly.fasta P2.unicycler.assembly.fasta
ln -s PRT5.unicycler/assembly.fasta PRT5.unicycler.assembly.fasta

