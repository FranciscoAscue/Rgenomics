# Package R dependencies
if( !is.element("devtools",rownames(installed.packages() ) ) ){
  install.packages("devtools")
  install.packages("BiocManager")
  
}

library(devtools)

################################################################################

# Install missing packages

missingPackages <- function(pkg){
  if( !is.element(pkg,rownames(installed.packages() ) ) ){
    message(pkg, "-----> Package is not installed ")
    BiocManager::install(pkg)
  }
}

dependencies <- c("dada2","Rbowtie2", "Rsamtools","ape","rjson", 
                  "dplyr","foreach", "doParallel", "tidyr","Biostrings",
                  "fastqcr","ShortRead","ape","ggplot2")

for(i in dependencies){
  missingPackages(i)
  library(i, character.only = TRUE)
}
################################################################################
