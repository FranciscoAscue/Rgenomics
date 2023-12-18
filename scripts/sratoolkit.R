library(devtools)
library(dplyr)
library(R.utils)

switch(Sys.info()[['sysname']],
       Windows= {
         url_sratoolkit <- "https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.7/sratoolkit.3.0.7-win64.zip"
         dir_base <- paste0(getwd(),"/",strsplit(url_sratoolkit,"/")[[1]][7])
         tmp_dir <- paste0(gsub(".zip","", strsplit(url_sratoolkit,"/")[[1]][7], fixed = TRUE),"/bin/")
         if(!file.exists(dir_base)  && !file.exists(tmp_dir)){
            download.file(url_sratoolkit,dir_base)
            unzip(dir_base, exdir = getwd())
            bin <<- tmp_dir
         }
         bin <<- tmp_dir
         
         setClass("sratoolkit", 
                  slots = list(dest="character", sraid="character"))
         
         setGeneric("downloadsra", function(obj){
           standardGeneric("downloadsra")
         })
         
         setGeneric("fastqdump", function(obj, output){
           standardGeneric("fastqdump")
         })
         
         setMethod("downloadsra", "sratoolkit",
                   function(obj){
                     cat("Sra files download :: ",obj@dest, "\n")
                     cmd <- paste0(bin,"prefetch.exe ","-O ",obj@dest," ",obj@sraid)
                     system(cmd)
                   }
         )
         
         setMethod("fastqdump", "sratoolkit",
                   function(obj, output){
                     cat("Sra files split in fastq :: ",obj@dest, "\n")
                     cmd <- paste0(bin,"fastq-dump-orig.exe ","--split-files ",
                                   "-O ",output," ",obj@dest,obj@sraid,"/",obj@sraid,".sra")
                     system(cmd)
                   }
         )
       },
       Linux  = {
         url_sratoolkit <- "https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.2/sratoolkit.3.0.2-ubuntu64.tar.gz"
         dir_base <- paste0(getwd(),"/",strsplit(url_sratoolkit,"/")[[1]][7])
         tmp_dir <- paste0(gsub(".tar.gz","", strsplit(url_sratoolkit,"/")[[1]][7], fixed = TRUE),"/bin/")
         if(!file.exists(dir_base) && !file.exists(tmp_dir)){
           download.file(url_sratoolkit,dir_base)
           gunzip(dir_base)
           tar_file <- gsub(".gz","", strsplit(url_sratoolkit,"/")[[1]][7], fixed = TRUE)
           dir_base_gunzip <- paste0(getwd(),"/",tar_file)
           untar(dir_base_gunzip)
           bin <<- tmp_dir
         }
         bin <<- tmp_dir
         
         setClass("sratoolkit", 
                  slots = list(dest="character", sraid="character"))
         
         setGeneric("downloadsra", function(obj){
           standardGeneric("downloadsra")
         })
         
         setGeneric("fastqdump", function(obj, output){
           standardGeneric("fastqdump")
         })
         
         setMethod("downloadsra", "sratoolkit",
                   function(obj){
                     cat("Sra files download :: ",obj@dest, "\n")
                     cmd <- paste0(bin,"prefetch ","-O ",obj@dest," ",obj@sraid)
                     system(cmd)
                   }
         )
         
         setMethod("fastqdump", "sratoolkit",
                   function(obj, output){
                     cat("Sra files split in fastq :: ",obj@dest, "\n")
                     cmd <- paste0(bin,"fastq-dump ","--split-files ",
                                   "-O ",output," ",obj@dest,obj@sraid,"/",obj@sraid,".sra")
                     system(cmd)
                   }
         )
})

download_genome <- function(url_base,filename, dest){
  url_download <-paste0(url_base,filename)
  download.file(url_download,paste0(dest,filename))
}

download_sra_files <- function(id, output = paste0(getwd(),"/data/rawdata/")){
  tmp <- new("sratoolkit",dest = output, sraid=id)
  downloadsra(tmp)
  fastqdump(tmp, output)
}
