Nout <- which(cons2 == "N")

cons2[Nout] 

data <- readDNAStringSet('data/reference/GCF_000085865.1_ASM8586v1_genomic.fasta')

# write(cons2, "file.txt")

data <- data$`NC_013511.1 Metamycoplasma hominis ATCC 23114, complete sequence`

# sequence <- paste0(data)
sequence <- as.character(as.vector(data))
cons2[Nout] <- sequence[Nout] 

class(sequence)
result <- (cons2 == sequence[1:9000]) 

var <- which(result == FALSE)

sequence[var]
cons2[var]

t <- data.frame(CHROM = rep("NC_013511.1", length(var)), 
                POS = var , 
                ID = rep('.', length(var)),
                REF = sequence[var],
                ALT = cons2[var],
                QUAL = rep('.', length(var)),
                FILTER <- rep('.',length(var)),
                INFO <- rep('.',length(var))
)


colnames(t) <- c('#CHROM',  'POS',  'ID',   'REF',  'ALT',  'QUAL', 
                 'FILTER',   'INFO')
df <- t %>% 
  unpack(where(is.data.frame)) %>%
  unnest(where(is.list))

write_vcf(
  t,
  pop.info = FALSE,
  filename = NULL,
  source = NULL,
  empty = FALSE
)
tidy_wide(df, import.metadata = FALSE)



# 
# 
# 
# 
# if (requireNamespace("gmapR", quietly=TRUE)) {
#   
#   tally.param <- TallyVariantsParam(gmapR::TP53Genome(),
#                                     high_base_quality = 23L,
#                                     which = range(p53) + 5e4,
#                                     indels = TRUE, read_length = 75L)
#   called.variants <- callVariants(bam, tally.param)
# } else {
#   data(vignette)
#   called.variants <- callVariants(tallies_H1993)
# }
# 
# 
# gmapGenomeDirectory <- GmapGenomeDirectory("data/reference/", create = TRUE)
# gmapGenomeDirectory
# 
# gmapGenome <- GmapGenome(genome="GCF_000085865.1_ASM8586v1_genomic.fasta",
#                          directory=gmapGenomeDirectory,
#                          name="myco",
#                          create=TRUE,
#                          k = 12L)
