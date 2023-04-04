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

############## Call Variants with VariantTools and GmapR ##############
#######################################################################

# GmapGenome reference

genome <- url$pathGenome
faindex <- url$pathGenomeIndex
gmapGenomeDirectory <- url$GenomeDirectory

gmapGenome <- GmapGenome(genome = genome,
                         directory=gmapGenomeDirectory,
                         create = TRUE,name="myco")

# Variant call parameters

tally.param <- TallyVariantsParam(gmapGenome,
                                  high_base_quality = 23L,
                                  # which = range(p53) + 5e4,
                                  indels = TRUE, read_length = 75L)

tallies <- tallyVariants(bamFile, tally.param)

variantSummary(tallies)

# Call variants

called.variants <- callVariants(bamFile, tally.param)

# Save vcf files 

sampleNames(called.variants) <- "SRR15616379"

vcf <- asVCF(called.variants)

writeVcf(vcf, "results/SRR15616379.vcf", index = TRUE)


