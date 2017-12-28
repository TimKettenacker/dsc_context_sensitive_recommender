#!/usr/bin/env Rscript
install.packages("officer")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")
library(officer)

file_name <- list.files(path = "/Users/timkettenacker/Downloads/GDSCDataSet/Presentations")
pptx_content <- as.data.frame(file_name, stringsAsFactors = FALSE)
pptx_content$content <- c("")
for(i in 1:length(file_name)){
  tryCatch(
    slides <- data.frame(),
    slides <- slide_summary(read_pptx(paste0("/Users/timkettenacker/Downloads/GDSCDataSet/Presentations/", file_name[i]))),
    error=function(e){print(file_name[i])},
    pptx_content$content[i] <- paste0(slides$text, collapse = " ")
  )
}
