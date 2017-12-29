#!/usr/bin/env Rscript
require("officer")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")

# there is an error in the officer package which causes loops to break if trying to read any other than "pptx", like i.e. outdated "ppt"
# apparently, it cannot be skipped in tryCatch, that's why it has to be handled beforehand
files_path <- list.files(path = "/Users/timkettenacker/Downloads/GDSCDataSet/Presentations")
file_names <- grep("pptx", files_path, value = TRUE, fixed = TRUE)
didnt_read <- setdiff(files_path, file_names)
pptx_content <- as.data.frame(file_names, stringsAsFactors = FALSE)
pptx_content$content <- c("")
for(i in 1:length(pptx_content$file_names)){
  tryCatch(
    slides <- data.frame(),
    slides <- slide_summary(read_pptx(paste0("/Users/timkettenacker/Downloads/GDSCDataSet/Presentations/", pptx_content$file_names[i]))),
    error=function(e){print(pptx_content$file_names[i])},
    pptx_content$content[i] <- paste0(slides$text, collapse = " ")
  )
}

