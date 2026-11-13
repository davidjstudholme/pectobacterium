#!/usr/bin/env Rscript
# Create an iTOL heatmap and categorical colour strip from type-strain ANI.
# Run in the directory containing the ANI CSV and PhaME Newick tree.
# Usage: Rscript make_itol_ANI_heatmap.R pectobacterium_ANI_matrix.csv PhaME_tree.nwk

args <- commandArgs(trailingOnly = TRUE)
ani_file <- if (length(args) >= 1) args[1] else "pectobacterium_ANI_matrix.csv"
tree_file <- if (length(args) >= 2) args[2] else "pectobacterium_brasiliense_fastree_all.fasttree"
out_file <- if (length(args) >= 3) args[3] else "itol_ANI_type_strains.txt"
strip_file <- if (length(args) >= 4) args[4] else "itol_ANI_closest_type_strain.txt"

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
  "COLOR,#6A3D9A",
  "FIELD_LABELS,P. brasiliense type,P. nicotianae type",
  "COLOR_MIN,#FDE725",
  "COLOR_MAX,#440154",
  "USER_MIN_VALUE,94.5",
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

# A separate categorical colour strip: which type-strain genome has higher ANI?
# This is NOT a species classification.
delta <- values$ANI_nicotianae - values$ANI_brasiliense
category <- ifelse(delta > 0, "Higher ANI to proposed P. nicotianae type",
                   ifelse(delta < 0, "Higher ANI to P. brasiliense type", "Equal ANI"))
strip_colours <- ifelse(delta > 0, "#CC79A7",
                        ifelse(delta < 0, "#009E73", "#999999"))
strip_header <- c(
  "DATASET_COLORSTRIP",
  "SEPARATOR COMMA",
  "DATASET_LABEL,Higher ANI to type strain",
  "COLOR,#009E73",
  "STRIP_WIDTH,35",
  "MARGIN,5",
  "SHOW_INTERNAL,0",
  "LEGEND_TITLE,Higher ANI to type strain",
  "LEGEND_SHAPES,1,1,1",
  "LEGEND_COLORS,#009E73,#CC79A7,#999999",
  "LEGEND_LABELS,P. brasiliense,proposed P. nicotianae,equal ANI",
  "DATA"
)
con2 <- file(strip_file, open = "wt")
writeLines(strip_header, con2)
write.table(data.frame(ID = tips, colour = strip_colours, label = category),
            con2, sep = ",", row.names = FALSE, col.names = FALSE, quote = FALSE)
close(con2)
cat("Wrote:", strip_file, "\n")
cat("Higher ANI to P. brasiliense:", sum(delta < 0), "\n")
cat("Higher ANI to proposed P. nicotianae:", sum(delta > 0), "\n")
cat("Equal ANI:", sum(delta == 0), "\n")
