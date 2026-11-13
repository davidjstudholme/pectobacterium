# Run: Rscript plot_type_strain_ANI.R pectobacterium_ANI_matrix.csv 'itol_selected_leaf_labels_corrected(3).txt'
args <- commandArgs(trailingOnly=TRUE)
if (length(args)<2) stop('Provide ANI matrix CSV and corrected iTOL labels file')
ani <- as.matrix(read.csv(args[1], row.names=1, check.names=FALSE))
stopifnot(nrow(ani)==ncol(ani), identical(rownames(ani),colnames(ani)))
accession <- function(x) {
  z <- regmatches(x, regexpr('GCA_[0-9]+[._][0-9]+', x))
  sub('_([0-9]+)$', '.\\1', z)
}
ids <- accession(rownames(ani))
stopifnot(!anyDuplicated(ids))
lines <- readLines(args[2]); lines <- lines[grepl('^GCA_[0-9]+_', lines)]
fields <- strsplit(lines, '\t', fixed=TRUE)
selected <- data.frame(accession=vapply(fields, function(x) accession(x[1]), ''), label=vapply(fields, function(x) x[2], ''), stringsAsFactors=FALSE)
stopifnot(!anyDuplicated(selected$accession))
selected$genome <- rownames(ani)[match(selected$accession,ids)]
if(anyNA(selected$genome)) stop('Unmatched selected accession(s): ',paste(selected$accession[is.na(selected$genome)],collapse=', '))
br <- 'GCA_016950255.1'; ni <- 'GCA_023272715.1'; je <- 'GCA_026800125.1'
stopifnot(all(c(br,ni,je) %in% ids), !anyNA(ani))
result <- data.frame(accession=ids,genome=rownames(ani),label=selected$label[match(ids,selected$accession)],
  ani_brasiliense=ani[,match(br,ids)],ani_nicotianae=ani[,match(ni,ids)],stringsAsFactors=FALSE)
result$delta_nicotianae_minus_brasiliense <- result$ani_nicotianae-result$ani_brasiliense
result$category <- ifelse(result$accession==je,'P. jejuense outgroup',ifelse(result$accession==br,'P. brasiliense type',ifelse(result$accession==ni,'P. nicotianae type',ifelse(result$label %in% c('PP1','PP2','PP5'),'Serbian isolates',ifelse(grepl('^P\\. nicotianae',result$label),'Other proposed P. nicotianae','Other genomes')))))
write.csv(result,'pectobacterium_type_strain_ANI_comparison.csv',row.names=FALSE,na='')
cols <- c('Other genomes'='#A9B4BD','Other proposed P. nicotianae'='#D28A3A','Serbian isolates'='#D94848','P. brasiliense type'='#3268B0','P. nicotianae type'='#7E55A8','P. jejuense outgroup'='#444444')
pdf('pectobacterium_type_strain_ANI_scatter.pdf',width=8.5,height=7.5,useDingbats=FALSE)
par(mar=c(5,5,2,2))
lims <- range(c(result$ani_brasiliense,result$ani_nicotianae)); lims <- c(floor(lims[1]*2)/2,ceiling(lims[2]*2)/2)
plot(result$ani_brasiliense,result$ani_nicotianae,type='n',xlim=lims,ylim=lims,asp=1,xlab='ANI to P. brasiliense CFBP 6617 type strain (%)',ylab='ANI to proposed P. nicotianae 21LCBS03 type strain (%)')
abline(0,1,lty=2,col='grey50'); abline(h=95,v=95,lty=3,col='grey75')
for(cat in names(cols)) { ix <- which(result$category==cat); points(result$ani_brasiliense[ix],result$ani_nicotianae[ix],pch=if(cat=='Other genomes')16 else 21,cex=if(cat=='Other genomes')0.65 else 1.35,col=if(cat=='Other genomes')adjustcolor(cols[cat],alpha.f=.6) else 'black',bg=cols[cat],lwd=.7) }
focus <- which(result$category %in% c('Serbian isolates','P. brasiliense type','P. nicotianae type'))
text(result$ani_brasiliense[focus],result$ani_nicotianae[focus],labels=ifelse(is.na(result$label[focus]),'',result$label[focus]),pos=4,cex=.65,offset=.45)
legend('bottomright',legend=names(cols),pch=c(16,rep(21,5)),col=c(cols[1],rep('black',5)),pt.bg=cols,cex=.72,bty='n')
dev.off()
cat('Matched selected strains:',nrow(selected),'\n')
cat('Type strain ANI:',ani[match(br,ids),match(ni,ids)],'\n')
cat('Outputs: pectobacterium_type_strain_ANI_scatter.pdf and pectobacterium_type_strain_ANI_comparison.csv\n')
