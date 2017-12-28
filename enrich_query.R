#!/usr/bin/env Rscript
install.packages("WikidataR")
install.packages("stringr")
install.packages("jsonlite")
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
library(WikipediR)
library(WikidataR)
item <- find_item("Solvay", limit = 20)

# checks if any returned item fits a company description
# and returns the wikidata item
check4company <- function(item){
  tryCatch(
    for(i in 1:length(item)){
      if((item[[i]]$description == "company")==TRUE){
        company <- get_property(id = item[[i]]$id)
      }
    },error=function(e){}
  )
  return(company)
}

company_metadata <- tryCatch(
  check4company(item)
  , error=function(e){print("No company name found. 
                            Should be handled more gracefully")})

# from here, a multitude of information is accessible; most notably,
# company_metadata[[1]]$sitelinks
# containing the url to the company's wikipedia page
# check out quanteda package
wiki_content <- tryCatch(
  page_content("en", "wikipedia", page_name = company_metadata[[1]]$sitelinks$enwiki$title, as_wikitext = TRUE)
  , error=function(e){print("No sitelink found. Should be handled more gracefully.")})

# get the respective enrichment data from the english wikipedia page
# by preprocessing the text at first and subsequently
cleansed_content <- gsub("\\[|\\]|\\{|\\}", "", wiki_content$parse$wikitext$`*`) 

# extracting "industry" and either "product" or "service" as enrichment categories
library(stringr)
find_enrichment_category4industry <- function(cleansed_content){
  industry_value <- str_extract(cleansed_content, "industry = [:alpha:]+.{0,}")
  industry_value <- sub("industry = ", "", industry_value)
  return(industry_value)
}
find_enrichment_category4products <- function(cleansed_content){
  products_value <- str_extract(cleansed_content, "products = [:alpha:]+.{0,}")
  products_value <- sub("products = ", "", products_value)
  return(products_value)
}
industry <- find_enrichment_category4industry(cleansed_content)
products <- find_enrichment_category4products(cleansed_content)

# if no match to a business term on wikipedia could be made, look for related words
library(jsonlite)
api_link <- paste0("https://api.datamuse.com/words?rel_gen=", "Proposal", "&topics=company&max=3")
api_out <- fromJSON(api_link)

