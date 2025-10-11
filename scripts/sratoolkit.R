library(devtools)
library(dplyr)
library(R.utils)



download_genome <- function(url_base,filename, dest){
  url_download <-paste0(url_base,filename)
  download.file(url_download,paste0(dest,filename))
}

