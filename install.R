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

dependencies <- c("dada2","Rbowtie2", "Rsamtools","vcfR","ape","rjson", "dplyr",
                  "foreach", "doParallel", "tidyr","Biostrings","gmapR", "VariantTools")

for(i in dependencies){
  missingPackages(i)
  library(i, character.only = TRUE)
}

if( !is.element("GEOquery",rownames(installed.packages() ) ) ){
   devtools::install_github('seandavi/GEOquery')
  
}
if( !is.element("radiator",rownames(installed.packages() ) ) ){
  devtools::install_github("thierrygosselin/radiator")
  
}
library(radiator)
################################################################################
