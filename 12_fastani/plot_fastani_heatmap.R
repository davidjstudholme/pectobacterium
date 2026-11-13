#!/usr/bin/env Rscript
# Clustered all-versus-all FastANI heatmap (FastANI --matrix format)
# Requires: install.packages('pheatmap')

suppressPackageStartupMessages(library(pheatmap))

input_file <- 'pectobacterium-fastANI.short.out.matrix'
if (!file.exists(input_file)) stop('Input file not found: ', input_file)
lines <- readLines(input_file, warn = FALSE)
n <- suppressWarnings(as.integer(trimws(lines[1])))
if (is.na(n) || n < 2L || length(lines) != n + 1L)
  stop('Unexpected FastANI matrix header or row count.')

ani <- matrix(NA_real_, n, n)
genomes <- character(n)
for (i in seq_len(n)) {
  fields <- strsplit(trimws(lines[i + 1L]), '[[:space:]]+')[[1]]
  if (length(fields) != i)
    stop(sprintf('Row %d has %d fields; expected %d.', i, length(fields), i))
  genomes[i] <- basename(fields[1])
  if (i > 1L) {
    vals <- suppressWarnings(as.numeric(fields[-1L]))
    ani[i, seq_len(i - 1L)] <- vals
  }
}
if (anyDuplicated(genomes)) stop('Duplicate genome basenames detected; use unique labels.')
ani[upper.tri(ani)] <- t(ani)[upper.tri(ani)]
diag(ani) <- 100
rownames(ani) <- colnames(ani) <- genomes

values <- ani[lower.tri(ani)]
cat('Genomes:', n, '\n')
cat('Unique pairwise comparisons:', length(values), '\n')
cat('Missing pairwise comparisons:', sum(is.na(values)), '\n')
cat('ANI summary (nonmissing comparisons):\n')
print(summary(values))
cat('ANI quantiles:\n')
print(quantile(values, c(0, .01, .05, .25, .5, .75, .95, .99, 1), na.rm = TRUE))

if (anyNA(ani)) {
  missing <- which(is.na(ani) & lower.tri(ani), arr.ind = TRUE)
  write.table(data.frame(genome_1 = genomes[missing[,1]],
                         genome_2 = genomes[missing[,2]]),
              'pectobacterium_missing_ANI_pairs.tsv', sep = '\t',
              row.names = FALSE, quote = FALSE)
  stop('Missing ANI values: see pectobacterium_missing_ANI_pairs.tsv. ',
       'Do not replace missing values with arbitrary ANI estimates.')
}
if (any(!is.finite(ani)) || any(ani < 0 | ani > 100))
  stop('Invalid ANI values detected.')

hc <- hclust(as.dist(100 - ani), method = 'average')

# Automatically use the observed minimum to avoid clipping values below 95%.
low <- floor(min(values) * 10) / 10
if (low >= 100) low <- 99.9
breaks <- seq(low, 100, length.out = 101)
colors <- colorRampPalette(c('#f7fbff', '#c6dbef', '#6baed6',
                             '#2171b5', '#08306b'))(100)

pdf('pectobacterium_ANI_heatmap.pdf', width = 10, height = 10,
    useDingbats = FALSE)
pheatmap(ani, color = colors, breaks = breaks,
         cluster_rows = hc, cluster_cols = hc,
         show_rownames = FALSE, show_colnames = FALSE,
         border_color = NA, treeheight_row = 55, treeheight_col = 55,
         main = sprintf('All-versus-all ANI (%d genomes)', n),
         legend_breaks = pretty(c(low, 100), n = 6),
         legend_labels = as.character(pretty(c(low, 100), n = 6)))
dev.off()

pdf('pectobacterium_ANI_dendrogram.pdf', width = 14, height = 7,
    useDingbats = FALSE)
plot(hc, labels = FALSE, main = 'ANI-based hierarchical clustering',
     xlab = '', sub = '', ylab = '100 - ANI (percentage points)')
dev.off()

write.csv(ani, 'pectobacterium_ANI_matrix.csv')
write.table(data.frame(cluster_order = seq_len(n),
                       genome = genomes[hc$order]),
            'pectobacterium_ANI_cluster_order.tsv',
            sep = '\t', row.names = FALSE, quote = FALSE)
cat('Saved heatmap, dendrogram, ANI matrix, and cluster order.\n')
