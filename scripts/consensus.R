
consensus_parallel <- function(sup, inf=1, ex, depth=0, freq_threshold = 0.6, 
                               mltcore, fastafile = NULL){
  
  nucl_string <-function(num, ex,depth,freq_threshold ){
    ## exist position 
    if(nrow(ex[which(ex$pos == num), ]) == 0){
      return <- "N"
    }else{
      tmp <- ex[which(ex$pos ==num), ]
      ## depth >= threshold
      if(sum(tmp$count) >= depth){
        tmp <- tmp %>% dplyr::mutate(Percentage = count/sum(count))
        ### most frequency nucl >= threshold 
        if(max(tmp$Percentage) >= freq_threshold){
          tmp <- as.character(tmp[which(tmp$Percentage == max(tmp$Percentage)),3])
          return <- tmp
          ### most frequency nucl < threshold 
        }else{
          
          ## capture two more frequency nucl 
          abg <- as.character(tmp[which(tmp$Percentage >= freq_threshold/2),3])
          abg_rev <- rev(abg)
          ## make a string normal and rev
          abg <-  paste(abg, collapse = "")
          abg_rev <- paste(abg_rev, collapse = "")
          
          ## identify IUPAC code 
          result = switch(  
            abg,  
            "AG"= "R",  
            "CT"= "Y",  
            "GC"= "S",  
            "AT"= "W",  
            "GT"= "K",  
            "AC"= "M"
          )  
          
          result_rev = switch(  
            abg_rev,  
            "AG"= "R",  
            "CT"= "Y",  
            "GC"= "S",  
            "AT"= "W",  
            "GT"= "K",  
            "AC"= "M"
          )  
          
          ## assign code to vector consensus
          if(is.null(result_rev) && is.null(result)){
            return <-  "N"
          }else{
            r <- c(result,result_rev)
            return <-  r
          }
          
        }
        
        ## depth <= threshold   
      }else{
        return <-  "N"
      }
    }
  }
  
  # dna_vector <- c()
  
  my.cluster <- parallel::makeCluster(
    mltcore, 
    type = "PSOCK"
  )
  
  doParallel::registerDoParallel(cl = my.cluster)
  foreach::getDoParRegistered()
  foreach::getDoParWorkers()
  
  x <- foreach(i = 1:sup, .combine = 'c',.packages='dplyr')%dopar%{
    nucl_string(num = i, ex = ex,depth = depth,
                freq_threshold = freq_threshold )
  }
  
  #make string of vector consensus
  dna_string <- paste(x, collapse = "")
  parallel::stopCluster(cl = my.cluster)
  
  if(!is.null(fastafile)){
    fileConn<-file(fastafile)
    writeLines(c(paste0(">",as.character(res$seqnames[1]),
                        "_",format(inf,scientific=FALSE),
                        ":",format(sup,scientific=FALSE)),
                 dna_string), fileConn)
    close(fileConn)
  }
  return(x)
}



# 
# 
# 
# consensus_no_parallel <- function(ex, depth=0, freq_threshold = 0.6){
#   
#   nucl_string <-function(num, ex,depth,freq_threshold ){
#     ## exist position 
#     library(dplyr)
#     if(nrow(ex[which(ex$pos == num), ]) == 0){
#       return <- "N"
#     }else{
#       tmp <- ex[which(ex$pos ==num), ]
#       ## depth >= threshold
#       if(sum(tmp$count) >= depth){
#         tmp <- tmp %>% dplyr::mutate(Percentage = count/sum(count))
#         ### most frequency nucl >= threshold 
#         if(max(tmp$Percentage) >= freq_threshold){
#           tmp <- as.character(tmp[which(tmp$Percentage == max(tmp$Percentage)),3])
#           return <- tmp
#           ### most frequency nucl < threshold 
#         }else{
#           
#           ## capture two more frequency nucl 
#           abg <- as.character(tmp[which(tmp$Percentage >= freq_threshold/2),3])
#           abg_rev <- rev(abg)
#           ## make a string normal and rev
#           abg <-  paste(abg, collapse = "")
#           abg_rev <- paste(abg_rev, collapse = "")
#           
#           ## identify IUPAC code 
#           result = switch(  
#             abg,  
#             "AG"= "R",  
#             "CT"= "Y",  
#             "GC"= "S",  
#             "AT"= "W",  
#             "GT"= "K",  
#             "AC"= "M"
#           )  
#           
#           result_rev = switch(  
#             abg_rev,  
#             "AG"= "R",  
#             "CT"= "Y",  
#             "GC"= "S",  
#             "AT"= "W",  
#             "GT"= "K",  
#             "AC"= "M"
#           )  
#           
#           ## assign code to vector consensus
#           if(is.null(result_rev) && is.null(result)){
#             return <-  "N"
#           }else{
#             r <- c(result,result_rev)
#             return <-  r
#           }
#           
#         }
#         
#         ## depth <= threshold   
#       }else{
#         return <-  "N"
#       }
#     }
#   }
#   
#   dna_vector <- c()
#   
#   sup <- tail(ex,1)$pos
#   
#   for(i in 1:sup){
#     tmp <- nucl_string(num = i, ex = ex,depth = depth,
#                        freq_threshold = freq_threshold )
#     dna_vector <- append(dna_vector, tmp)
#   }
#   
#   #make string of vector consensus
#   dna_string <- paste(dna_vector, collapse = "")
#   return(dna_string)
# }



