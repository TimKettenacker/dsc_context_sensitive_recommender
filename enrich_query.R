#!/usr/bin/env Rscript
require("WikipediR")
require("WikidataR")
require("stringr")
require("jsonlite")
setwd("/Users/timkettenacker/dsproj_repos/R/dsc_context_sensitive_recommender")

args <- commandArgs(trailingOnly = TRUE)
#args is a vector of type chr: cat(str(args))
industry <- ""
products <- ""
related_terms <- ""

#example query:
args <- c("BMW","Strategy","BI","Proposal")
# the items are already splitted
# remove "Capgemini" if included in the query
args <- args[args != "Capgemini"]

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
  print(arg)
  item <- tryCatch(check4company(arg), error=function(e){})
  # check if any returned item fits a company description and if so, subsequently add enriching features
  if(is.null(item) == FALSE){
    wiki_content <- get_wikipedia_data(item)
    industry <- find_enrichment_category4industry(wiki_content)
    products <- find_enrichment_category4products(wiki_content)
    print(industry)
    print(products)
  } # if no match to a business term on wikipedia could be made, look for related words
  else{
    related_terms <- search_related_terms(arg)
    print(related_terms)
  }
}

buffed_args <- paste(c(args, industry, products, related_terms))

