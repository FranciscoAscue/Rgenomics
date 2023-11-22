mutation_by_gene <- function(mutation_tsv, filter = 200){
  library(ggplot2)
  library(dplyr)
  
  aasustitutions <- c()
  for(i in mutation_tsv$aaSubstitutions){
    aasustitutions <- c(aasustitutions,i)
  }
  aasustitutions <- paste(aasustitutions, collapse = "")
  
  Mutaciones <- strsplit(aasustitutions, split = ",")
  freq <- as.data.frame(table(Mutaciones))
  freq_edit <- freq %>% mutate(Frecuencia = round(Freq/nrow(mutation_tsv)*100, 2))
  genes <- strsplit(as.vector(freq_edit$Mutaciones), split = ':', fixed = TRUE)
  tmp <- c()
  for( i in genes ){
    tmp <- append(tmp,i[1])
  }
  freq_edit$Gene <- tmp
  
  freq_filter <- freq_edit %>% filter(Freq > filter)
  
  plotg <- freq_filter %>% ggplot(aes(x=Mutaciones,y=Frecuencia, fill=Gene)) +
    geom_bar(stat = "identity") + 
    geom_text(aes(label = Frecuencia), vjust = -0.2, size = 3)+
    scale_x_discrete(guide = guide_axis(angle = 90)) + 
    scale_fill_brewer(palette="Dark2") +
    theme_light()
  
  return(list(plotg = plotg, freqtable = freq_edit))
}
