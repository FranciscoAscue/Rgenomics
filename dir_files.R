dir.create(paste0(getwd(), "/data"))
           dir.create(paste0(getwd(), "/data/reference"))
           dir.create(paste0(getwd(), "/data/reference/index"))
                      url_download <- "https://raw.githubusercontent.com/FranciscoAscue/Rgenomics/master/data/reference/ref.json"
                      download.file(url_download,paste0(getwd(),"/data/reference/ref.json"))
           dir.create(paste0(getwd(), "/data/rawdata"))
           dir.create(paste0(getwd(), "/data/processed_data"))
dir.create(paste0(getwd(), "/scripts"))
dir.create(paste0(getwd(), "/results"))
                      
url_download <- "https://raw.githubusercontent.com/FranciscoAscue/Rgenomics/master/install.R"
download.file(url_download,paste0(getwd(),"/install.R"))
url_download <- "https://raw.githubusercontent.com/FranciscoAscue/Rgenomics/master/main.R"
download.file(url_download,paste0(getwd(),"/main.R"))

url_download <- "https://raw.githubusercontent.com/FranciscoAscue/Rgenomics/master/scripts/sratoolkit.R"
download.file(url_download,paste0(getwd(),"/scripts/sratoolkit.R"))
url_download <- "https://raw.githubusercontent.com/FranciscoAscue/Rgenomics/master/scripts/listfastq.R"
download.file(url_download,paste0(getwd(),"/scripts/listfastq.R"))
url_download <- "https://raw.githubusercontent.com/FranciscoAscue/Rgenomics/master/scripts/filtereads.R"
download.file(url_download,paste0(getwd(),"/scripts/filtereads.R"))
url_download <- "https://raw.githubusercontent.com/FranciscoAscue/Rgenomics/master/scripts/consensus.R"
download.file(url_download,paste0(getwd(),"/scripts/consensus.R"))
