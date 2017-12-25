#!/usr/bin/env Rscript
install.packages("WikidataR")
library("WikidataR")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")

args <- commandArgs(trailingOnly = TRUE)
#args will be a vector of type chr
#cat(str(args))

#example query:
args <- c("Solvay","AM","BI","Proposal")
# the items are already splitted
# remove "Capgemini" if included in the query
args <- args[args != "Capgemini"]

# start conditional enrichment of data
library("WikidataR")
item <- find_item("Solvay", limit = 20)

# checks if any returned item fits a company description
# and returns an integer item list number
check4company <- function(item){
  tryCatch(
    for(i in 1:length(item)){
      if((item[[i]]$description == "company")==TRUE){
        relevant_item_no_from_list <- i
      }
    },error=function(e){}
  )
  return(relevant_item_no_from_list)
}

item_no <- tryCatch(
  check4company(item)
  , error=function(e){print("No company name found. 
                            Should be handled more gracefully")})

company_data <- get_item(id = item[[item_no]]$id)

# from here, a multitude of information is accessible;
# company_data[[1]]$labels
# company_data[[1]]$descriptions
# company_data[[1]]$aliases
# company_data[[1]]$claims
# company_data[[1]]$sitelinks
# from which aliases makes the most sense as an enrichment
# try to add industry
# check out google knowledge graph search api
# check out quanteda package