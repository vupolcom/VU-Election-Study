#! /usr/bin/env Rscript
#DESCRIPTION: AmCAT issue and party counts
#AUTHOR: Wouter van Atteveldt
#DEPENDS: data/raw/partijen.csv data/raw/210320_v20.xlsx
#CREATES: data/intermediate/VUElectionPanel2021_wave4.csv


library(tidyverse)
library(here)
library(glue)
library(amcatr)

query_party = function(partij, alias) {
  partij = tolower(partij)
  alias = tolower(alias)
  case_when(partij == "denk" ~ alias,
            !is.na(alias) ~ str_c(partij, " OR ", alias),
            T ~ partij) 
}
query_lijsttrekker = function(naam, partij) {
  naam = tolower(naam)
  partij = tolower(partij)
  an = rsplit(naam)
  functie_zoek=case_when(an == "hoekstra" ~ "bewinds* OR minister*",
                         an == "rutte"  ~ "premier* OR bewinds* OR minister*",
                         T ~ "kamerl* OR parlement*")
  alias = case_when(partij == "cu" ~ " OR christenunie",
                    partij == "fvd" ~ " OR forum",
                    partij == "gl" ~ " OR groenlinks",
                    partij == "pvdd" ~ " OR dieren",
                    T ~ "")
  glue('"{naam}" OR "{an} ({functie_zoek} OR lijsttrek* OR partijleid* OR {partij}{alias})"~10') 
}
clean = function(x) x %>% str_replace_all("[“”]", '"')
rsplit = function(x) str_match(x, ".* (.*)")[,2]

## Sets

sets = c(Newspapers=2562, Online=2564, TV=2579)

## Metadata
meta = purrr::map(sets, function(set) amcat.articles(conn, project=69, articleset=set, columns = c("date", "publisher"))) %>% 
  bind_rows(.id="mtype") %>% 
  as_tibble() %>%
  mutate(id=as.numeric(id))%>% 
  filter(date < "2021-03-18", date >= "2021-01-01") %>%
  anti_join(brieven)



## Build queries

parties= read_csv(here("data/raw/partijen.csv")) %>% mutate(across(everything(), clean))
issues = readxl::read_xlsx(here("data/raw/210320_v20.xlsx"), sheet="issue") 
queries = bind_rows(
  parties %>% mutate(cat="actor", subcat=partij, query=query_party(partij, alias)) %>% select(cat, subcat, label=partij, query),
  parties %>% mutate(cat="actor", subcat=partij, query=query_lijsttrekker(lijsttrekker, partij)) %>% select(cat, subcat, label=lijsttrekker, query),
  issues %>% select(cat=gparentI, subcat=parentI, label=queryIssue, query=queryIssue)
)

## Get hits

conn = amcatr::amcat.connect("https://vu.amcat.nl")

h = amcat.hits(conn, project=69, sets=c(2562, 2564, 2579), queries=queries$query, labels = queries$label)


