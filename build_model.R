#!/usr/bin/env Rscript
require("quanteda")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")

dict <- dictionary(list(search_term = c("Solvay", "Chemicals and plastics","Chemical industry|Chemicals")))

build_dfm <- function(content){
  dfm <- dfm(corpus(content), remove = stopwords("english"), remove_punct = TRUE)
  #dfm <- dfm_lookup(dfm, dictionary = dict, valuetype = c("glob"))
  return(dfm)
}

for(c in 1:length(pptx_content$content)){
  tryCatch(build_dfm(pptx_content$content[c]),
           error=function(e){print(pptx_content$file_names[c])})
}

#kwic(myCorpus, "BI")#performs a search for a word and allows us to view the contexts
# for more than one dfm
# byQueryTokenDfm <- dfm(dall_mydfm, groups = "BI", remove = stopwords("english"), remove_punct = TRUE)
# dfm_lookup(mydfm, dictionary(list(business = c("BI"))), valuetype = c("glob"))
# tfidf(mydfm)
# dfm_select(mydfm, dictionary)
# textstat_dist(mydfm)