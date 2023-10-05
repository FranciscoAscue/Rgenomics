######################################################################
######################## GENOMICS WITH R  ############################
######################################################################

############### Install and load library's ###############
##########################################################

source("install.R", local = TRUE)

# Source scripts

source("scripts/sratoolkit.R", local = TRUE)
source("scripts/listfastq.R", local = TRUE)
source("scripts/filtereads.R", local = TRUE) 
source("scripts/consensus.R", local = TRUE) 

############### Download genomes from NCBI ###############
##########################################################

url <- fromJSON(file = "data/reference/ref.json")
filename <- "GCF_000085865.1_ASM8586v1_genomic.fna.gz"
download_genome(url$urlref,filename, "data/reference/" )

############### Download files from SRA - NCBI ###############
##############################################################

download_sra_files(id = "SRR15616380")
download_sra_files(id = "SRR15616379")

############### Quality of fastq ###############
################################################

lecturas <- list_fastq(pattern = c("SRR15616379_1.fastq.gz","SRR15616379_2.fastq.gz"))
plotQualityProfile(c(lecturas$lf,lecturas$lr))

############### Filter reads from fastq files ###############
#############################################################

log_filter <- filter_reads(name = lecturas$name, lf = lecturas$lf, 
             lr = lecturas$lr, trunc = 250)


############### Assembly genomes ###############
################################################

# uncompressed reference genome 
gunzip("data/reference/GCF_000085865.1_ASM8586v1_genomic.fna.gz")

# reference genome bowtie2 index 
bowtie2_build("data/reference/GCF_000085865.1_ASM8586v1_genomic.fna",
              bt2Index = "data/reference/index/myco" , overwrite = TRUE)

# aling fastq files to reference 

bowtie2(bt2Index = "data/reference/index/myco", 
        samOutput = "results/SRR15616379.sam", 
        seq1 = "data/processed_data/filtered_F/SRR15616379_filt_1.fastq", 
        seq2 = "data/processed_data/filtered_R/SRR15616379_filt_2.fastq", 
        "--threads=3")

############### Alignment files manipulation ###############
############################################################

# Convert to BAM files

asBam("results/SRR15616379.sam")

# Read BAM file

bamFile <- BamFile("results/SRR15616379.bam")

# Statistics of alignment  

bam <- countBam(bamFile)
quickBamFlagSummary(bamFile)
seqinfo(bamFile)

# Open large size of BAM files 

yieldSize(bamFile) <- 1
open(bamFile)
scanBam(bamFile)[[1]]$seq
close(bamFile)
yieldSize(bamFile) <- NA

############### Genome consensus with Rsamtools ###############
##############################################################

# count position of alignment 
res <- pileup(bamFile)

head(res)

table(res$strand, res$nucleotide)

# coverage plot

cover <- res[,c("pos","count")]

plot(count ~ pos, cover , pch =".")


# Parameters to genome consensus

p_param <- PileupParam(distinguish_strands = FALSE, 
                       distinguish_nucleotides = TRUE,
                       min_mapq = 10,
                       min_nucleotide_depth = 5,
                       min_base_quality = 10,
                       min_minor_allele_depth = 0)

res <- pileup(bamFile, pileupParam = p_param)
ex <- head(res,20000)

## consensus fasta of range intervals of genome

cons2  <- consensus_parallel(sup = 9000, ex = res, depth = 1, 
                                    freq_threshold = 0.6, mltcore = 7, 
                             fastafile = "results/consensus.fasta")

################# Annotación de genomas bacterianos ###################
#######################################################################


library(dplyr)
library(ape)

df <- read.table("data/annotation/annotation.tsv", sep = "\t", header = TRUE)
df <- df %>% dplyr::filter(ftype %in% c("CDS","rRNA","tRNA"))
gfff <- read.gff("data/annotation/annotation.gff")  
gfff$attributes <- gsub("ID=","",gfff$attributes,fixed = TRUE)
gfff$attributes <- gsub("_gene","",gfff$attributes,fixed = TRUE)
gffCDS <- gfff %>% dplyr::filter(type %in% c("CDS","rRNA","tRNA"))
tmp <- merge(x = df, y =gffCDS , by.y = "attributes", by.x = "locus_tag", all = TRUE)

length(unique(tmp$locus_tag))


genes_annot <- tmp %>% dplyr::filter(gene != "hypothetical" ) %>% head(20)
colnames(genes_annot) <- c("locus","ftype","width", "gene", "seqid", "source", "type",
                           "start","end","score","strand","phase")

variantes <- read.table("data/gen.tsv", sep = "\t", header = TRUE)

library(circlize)
library(viridisLite)
library(viridis)
set.seed(999)

# Crear un dataframe con los datos de anotación
df <- data.frame(
  name  = genes_annot$gene,
  start = genes_annot$start,
  end   = genes_annot$end)

circos.genomicInitialize(df)

# Configurar una pista en el gráfico circular
circos.track(
  ylim = c(0, 1),  # Rango de valores en el eje Y
  bg.col = viridis(20),  # Colores de fondo de las regiones
  bg.border = NA,  # Sin borde en las regiones
  track.height = 0.05  # Altura de la pista
)


