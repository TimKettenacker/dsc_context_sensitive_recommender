#!/usr/bin/env Rscript
require("officer")
require("quanteda")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")

# split document title and enrich it
enrich_doc_title <- function(title){
  enriched_doc_title <- ""
  file_name_split <- unlist(strsplit(title, "(?<=[a-z])(?=[A-Z])|_|\\.", perl = TRUE))
  for(title in file_name_split){
    company <- tryCatch(check4company(title), error=function(e){})
    if(is.null(company) == FALSE){
      tryCatch(
        title_company <- get_wikipedia_data(company),
        enriched_doc_title <- append(find_enrichment_category4industry(title_company), enriched_doc_title),
        enriched_doc_title <- append(find_enrichment_category4products(title_company), enriched_doc_title),
        error=function(e){}
      )
          }
  }
  enriched_doc_title <- append(file_name_split, enriched_doc_title)
  enriched_doc_title <- dfm(paste0(enriched_doc_title, collapse = " "), remove = stopwords("english"), remove_punct = TRUE, tolower = TRUE)
  enriched_doc_title <- featnames(enriched_doc_title)
  return(enriched_doc_title)
}

# there is an error in the officer package which causes loops to break if trying to read any other than "pptx", like i.e. outdated "ppt"
# apparently, it cannot be skipped in tryCatch, that's why it has to be handled beforehand

path <- "/Users/timkettenacker/Downloads/GDSCDataSet"
# extract PowerPoint slides
files_path_pptx <- list.files(path = path, pattern = ".pptx", full.names = TRUE, include.dirs = FALSE, recursive = TRUE)
file_names <- grep("pptx", files_path_pptx, value = TRUE, fixed = TRUE)
pptx_content <- as.data.frame(file_names, stringsAsFactors = FALSE)
pptx_content$content <- c("")
pptx_content$title_enriched <- c("")
for(i in 1:length(pptx_content$file_names)){
  tryCatch(
    slides <- data.frame(),
    slides <- slide_summary(read_pptx(file_names[i])),
    error=function(e){},
    pptx_content$content[i] <- paste0(slides$text, collapse = " "),
    pptx_content$title_enriched[i] <- paste0(enrich_doc_title(pptx_content$file_names[i]), collapse = " ")
  )
}
# extract Word docs
files_path_docx <- list.files(path = path, pattern = ".docx", full.names = TRUE, include.dirs = FALSE, recursive = TRUE)
file_names <- grep("docx", files_path_docx, value = TRUE, fixed = TRUE)
docx_content <- as.data.frame(file_names, stringsAsFactors = FALSE)
docx_content$content <- c("")
docx_content$title_enriched <- c("")
for(i in 1:length(docx_content$file_names)){
  tryCatch(
    docs <- data.frame(),
    docs <- docx_summary(read_docx(file_names[i])),
    error=function(e){},
    docx_content$content[i] <- paste0(docs$text, collapse = " "),
    docx_content$title_enriched[i] <- paste0(enrich_doc_title(docx_content$file_names[i]), collapse = " ")
  )
}

df_content <- rbind(pptx_content, docx_content)
df_content <- unite(df_content, corpus, content, title_enriched, sep = " ", remove = FALSE)

source("build_model.R")

