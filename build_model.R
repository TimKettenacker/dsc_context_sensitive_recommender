#!/usr/bin/env Rscript
require("quanteda")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")

dict <- dictionary(list(search_term = buffed_args))
dfm <- dfm(df_content$corpus, remove = stopwords("english"), remove_punct = TRUE, tolower = TRUE)
lookup <- dfm_lookup(dfm, dict, valuetype = "glob", exclusive = FALSE)
result_matrix <- as.matrix(lookup)
result_matrix <- result_matrix[order(result_matrix[,1], decreasing = TRUE),]

# calculate text distances afterwards or just return ordered list
top7 <- result_matrix[1:7, 1]
top7 <- sub("[a-z]+", "", names(top7))
print(pptx_content$file_names[as.integer(top7)])

