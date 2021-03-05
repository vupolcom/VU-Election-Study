#!/usr/bin/Rscript

library(amcatr)
library(glue)
library(here)
library(readr)
library(dplyr)

source(here("src/lib/amcatlib.R"))

sets = read_csv(here("data/raw/amcat_sets.csv"))

#' Add articles from fromset matching query to toset that are not yet present
update_set = function(conn, query, fromproject, fromset, 
                      toset, toproject=69, startdate = "2021-01-01") {
  ids = amcat.articles(conn, toproject, toset, columns = NULL)$id
  h = amcat.hits(conn,  sets=fromset, project=fromproject, 
                 queries=query, labels="relevant", start_date=startdate)
  if (nrow(h) == 0) return()
  to_add = setdiff(h$id, ids)
  amcat.add.articles.to.set(conn, toproject, articleset=toset, articles=to_add)
}

args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0) {
   startdate = Sys.Date() - days
} else {
   startdate = as.Date(args[1])
}

message(glue("Getting articles from {startdate}"))



parties = get_party_queries()
query = str_c(parties$party_query, ' OR "', parties$lijsttrekker, '"', collapse = " OR ")

conn = amcat.connect("https://vu.amcat.nl")

for (i in 1:nrow(sets)) {
  s = sets[i, ]
  message(glue("[{s$label}] Updating set {s$toset} from {s$fromproject}:{s$fromset}"))
  update_set(conn, query, s$fromproject, s$fromset, s$toset, startdate = startdate)
}



