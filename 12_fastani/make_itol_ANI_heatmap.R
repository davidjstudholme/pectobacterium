#!/usr/bin/env Rscript
# Create an iTOL DATASET_HEATMAP showing ANI to two type strains.
# Run in the directory containing the ANI CSV and PhaME Newick tree.
# Usage: Rscript make_itol_ANI_heatmap.R pectobacterium_ANI_matrix.csv PhaME_tree.nwk

args <- commandArgs(trailingOnly = TRUE)
ani_file <- if (length(args) >= 1) args[1] else "pectobacterium_ANI_matrix.csv"
tree_file <- if (length(args) >= 2) args[2] else "pectobacterium_brasiliense_fastree_all.fasttree"
out_file <- if (length(args) >= 3) args[3] else "itol_ANI_type_strains.txt"

if (!requireNamespace("ape", quietly = TRUE)) {
  stop("Install the ape package first: install.packages('ape')")
}

brasiliense <- "GCA_016950255.1"
nicotianae <- "GCA_023272715.1"

# Accept GCA_123456789.1, GCA_123456789_1, and GCF equivalents.
# Extract the accession only, ignoring any subsequent strain-name suffix.
get_accession <- function(x) {
  x <- basename(x)
  pattern <- "GC[AF]_[0-9]+[._][0-9]+"
  m <- regexpr(pattern, x, perl = TRUE)
  result <- rep(NA_character_, length(x))
  found <- m > 0
  result[found] <- regmatches(x, m)[seq_len(sum(found))]
  sub("_([0-9]+)$", ".\\1", result)
}

if (!file.exists(ani_file)) stop("ANI CSV not found: ", ani_file)
if (!file.exists(tree_file)) stop("Newick tree not found: ", tree_file)

ani <- as.matrix(read.csv(ani_file, row.names = 1, check.names = FALSE))
suppressWarnings(storage.mode(ani) <- "numeric")
if (nrow(ani) != ncol(ani)) stop("ANI matrix is not square")
if (anyNA(ani)) stop("ANI matrix contains missing/non-numeric values")

racc <- get_accession(rownames(ani))
cacc <- get_accession(colnames(ani))
if (anyNA(racc) || anyNA(cacc)) stop("Cannot extract all ANI matrix accessions")
if (anyDuplicated(racc) || anyDuplicated(cacc)) stop("Duplicate ANI accessions detected")
if (!setequal(racc, cacc)) stop("ANI row and column accession sets differ")
rownames(ani) <- racc
colnames(ani) <- cacc
ani <- ani[racc, racc, drop = FALSE]
if (!all(c(brasiliense, nicotianae) %in% colnames(ani))) {
  stop("Missing type-strain accession(s): ", paste(setdiff(c(brasiliense, nicotianae), colnames(ani)), collapse = ", "))
}

tree <- ape::read.tree(tree_file)
tips <- tree$tip.label
tacc <- get_accession(tips)
if (anyNA(tacc)) stop("Cannot extract accessions from these tree tips: ", paste(tips[is.na(tacc)], collapse = ", "))
if (anyDuplicated(tacc)) stop("Duplicate tree-tip accessions detected")
if (!setequal(tacc, racc)) {
  stop("Tree and ANI matrix differ. Missing from ANI: ", paste(setdiff(tacc, racc), collapse = ", "),
       "; missing from tree: ", paste(setdiff(racc, tacc), collapse = ", "))
}

values <- data.frame(
  ID = tips,
  ANI_brasiliense = ani[tacc, brasiliense],
  ANI_nicotianae = ani[tacc, nicotianae],
  check.names = FALSE
)
if (anyNA(values)) stop("Missing type-strain ANI values")

# iTOL requires exact original tip identifiers, not display labels.
header <- c(
  "DATASET_HEATMAP",
  "SEPARATOR COMMA",
  "DATASET_LABEL,ANI to type strains",
  "COLOR,#0072B2",
  "FIELD_LABELS,P. brasiliense type,P. nicotianae type",
  "COLOR_MIN,#FFF7EC",
  "COLOR_MAX,#08519C",
  "USER_MIN_VALUE,93",
  "USER_MAX_VALUE,100",
  "DATA"
)

con <- file(out_file, open = "wt")
writeLines(header, con)
write.table(values, con, sep = ",", row.names = FALSE, col.names = FALSE,
            quote = FALSE, na = "X")
close(con)

cat("Wrote:", out_file, "\n")
cat("Tree tips:", length(tips), "\n")
cat("ANI range:", paste(round(range(as.matrix(values[, 2:3])), 4), collapse = " to "), "\n")
cat("Missing values:", sum(is.na(values[, 2:3])), "\n")
cat("Type strains:", brasiliense, "and", nicotianae, "\n")
