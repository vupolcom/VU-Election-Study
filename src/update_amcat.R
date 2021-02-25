library(amcatr)
library(glue)
library(here)
library(tidyverse)

partijen = read_csv(here("data/raw/partijen.csv")) %>% mutate(across(everything(), clean))
sets = read_csv(here("data/raw/amcat_sets.csv"))

#' Add articles from fromset matching query to toset that are not yet present
update_set = function(conn, query, fromproject, fromset, 
                      toset, toproject=69, startdate = "2021-01-01") {
  ids = amcat.articles(conn, toproject, toset, columns = NULL)$id
  h = amcat.hits(conn,  sets=fromset, project=fromproject, 
                 queries=query, labels="relevant", start_date="2021-01-01")
  to_add = setdiff(h$id, ids)
  amcat.add.articles.to.set(conn, toproject, articleset=toset, articles=to_add)
}


### Build query from partijen.csv
clean = function(x) x %>% str_replace_all("[“”]", '"')
partijen = p %>% pull(zoekterm) %>% na.omit() %>% tolower() %>% str_c(collapse = " ")
alias = p %>% pull(alias) %>% na.omit() %>% tolower() %>% str_c(collapse = " ")
lijsttrekkers =p %>% pull(lijsttrekker) %>% na.omit() %>% tolower() %>% str_c('"', ., '"', collapse = " ") 

cat(glue("({functies}) NOT ({lijsttrekkers} {alias} {partijen})"))
query = str_c(lijsttrekkers, alias, partijen, sep = " ")

library(amcatr)
conn = amcat.connect("http://vu.amcat.nl")

update_set(conn, query, 2, 1340, 2562)

for (i in 1:nrow(sets)) {
  s = sets[i, ]
  message(glue("[{s$label}] Updating set {s$toset} from {s$fromproject}:{s$fromset}"))
  update_set(conn, query, s$fromproject, s$fromset, s$toset)
}
