#!/usr/bin/env Rscript
require("quanteda")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")

dict <- dictionary(list(search_term = c("BI", "Automotive","Automobiles", "Commercial vehicles")))
dfm <- dfm(pptx_content$content, remove = stopwords("english"), remove_punct = TRUE, tolower = TRUE)
lookup <- dfm_lookup(dfm, dict, valuetype = "glob", exclusive = FALSE)

# calculate text distances afterwards
