#!/usr/bin/env Rscript
require("WikipediR")
require("WikidataR")
require("stringr")
require("jsonlite")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")

# command line input is already splitted into tokens
# remove "Capgemini" if included in the query
args <- commandArgs(trailingOnly = TRUE)
args <- args[args != "Capgemini"]

industry <- ""
products <- ""
related_terms <- ""

# checks if any returned item fits a company description
# and returns the wikidata item
check4company <- function(arg){
  item <- find_item(arg, limit = 10)
  id <- grep("company|manufacturer|corporation", item)
  company <- get_property(id = item[[id]]$id)
  return(company)
}

get_wikipedia_data <- function(item){
  wiki_content <- page_content("en", "wikipedia", page_name = item[[1]]$sitelinks$enwiki$title, as_wikitext = TRUE)
  wiki_content <- gsub("\\[|\\]|\\{|\\}", "", wiki_content$parse$wikitext$`*`) 
  return(wiki_content)
}

# extracting "industry" and "products" as enrichment categories
find_enrichment_category4industry <- function(wiki_content){
  industry_value <- str_extract(wiki_content, "industry\\s+= [:alpha:]+.{0,}")
  industry_value <- sub("industry\\s+=", "", industry_value)
  return(industry_value)
}

find_enrichment_category4products <- function(wiki_content){
  products_value <- str_extract(wiki_content, "products\\s+= [:alpha:]+.{0,}")
  products_value <- sub("products\\s+=", "", products_value)
  return(products_value)
}

search_related_terms <- function(arg){
  api_link <- paste0("https://api.datamuse.com/words?rel_gen=", arg, "&topics=company&max=3")
  api_out <- fromJSON(api_link)
  return(api_out$word)
}

# start conditional enrichment on user input data
for(arg in args){
  item <- tryCatch(check4company(arg), error=function(e){})
  # check if any returned item fits a company description and if so, subsequently add enriching features
  if(is.null(item) == FALSE){
    wiki_content <- get_wikipedia_data(item)
    industry <- append(find_enrichment_category4industry(wiki_content), industry)
    products <- append(find_enrichment_category4products(wiki_content), products)
  } # if no match to a business term on wikipedia could be made, look for related words
  else{
    related_terms <- append(search_related_terms(arg), related_terms)
  }
}

buffed_args <- paste(c(args, industry, products, related_terms))
buffed_args <- buffed_args[buffed_args != ""] 
source("extract_pptx.R")
