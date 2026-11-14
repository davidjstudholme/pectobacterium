
# Work in a screen session
screen

# Install GTDB-Tk
conda create -n gtdbtk -c conda-forge -c bioconda gtdbtk=2.8.0
conda activate gtdbtk
download-db.sh

# Get the input genome files
ln -s ../01_genomes/*.fna .
for i in *.fna; do
    printf '%s\t%s\n' "$i" "${i%_genomic.fna}"
done > genomes.tsv

mkdir -p /data/djs217/gtdbtk_scratch

# Run the job
gtdbtk classify_wf \
    --batchfile genomes.tsv \
    --out_dir gtdbtk_results_retry \
    --cpus 12 \
    --pplacer_cpus 1 \
    --scratch_dir /data/djs217/gtdbtk_scratch

# Generate annotation for iTOL
awk -F '\t' '
BEGIN {
    print "DATASET_COLORSTRIP"
    print "SEPARATOR TAB"
    print "DATASET_LABEL\tGTDB-Tk classification"
    print "COLOR\t#A7A7A7"
    print "STRIP_WIDTH\t25"
    print "MARGIN\t5"
    print "LEGEND_TITLE\tGTDB-Tk species (R232)"
    print "LEGEND_SHAPES\t1\t1\t1"
    print "LEGEND_COLORS\t#A7A7A7\t#D55E00\t#0072B2"
    print "LEGEND_LABELS\tP. brasiliense\tP. brasiliense_A\tP. jejuense"
    print "DATA"
}
NR > 1 {
    id = $1

    # Match accessions despite version and filename differences
    if (id ~ /^GC[AF]_[0-9]+\./) {
        sub(/\..*$/, "", id)
        id = "CONTAINS==" id
    }

    n = split($2, ranks, ";")
    species = ranks[n]

    if (species == "s__Pectobacterium brasiliense") {
        color = "#A7A7A7"
        label = "P. brasiliense"
    }
    else if (species == "s__Pectobacterium brasiliense_A") {
        color = "#D55E00"
        label = "P. brasiliense_A"
    }
    else if (species == "s__Pectobacterium jejuense") {
        color = "#0072B2"
        label = "P. jejuense"
    }
    else {
        print "Unexpected classification: " species > "/dev/stderr"
        next
    }

    print id "\t" color "\t" label
}
' gtdbtk_results_retry/gtdbtk.bac120.summary.tsv \
    > itol_gtdb_colorstrip.txt

