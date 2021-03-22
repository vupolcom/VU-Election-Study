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

## Query definitions

parties= read_csv(here("data/raw/partijen.csv")) %>% mutate(across(everything(), clean))
issues = readxl::read_xlsx(here("data/raw/210320_v20.xlsx"), sheet="issue") 

## Build queries

queries = bind_rows(
  parties %>% mutate(cat="actor", subcat=partij, query=query_party(partij, alias)) %>% select(cat, subcat, label=partij, query),
  parties %>% mutate(cat="actor", subcat=partij, query=query_lijsttrekker(lijsttrekker, partij)) %>% select(cat, subcat, label=lijsttrekker, query),
  issues %>% select(cat=gparentI, subcat=parentI, label=queryIssue, query=queryIssue)
)

## Get hits

conn = amcatr::amcat.connect("https://vu.amcat.nl")

h = amcat.hits(conn, project=69, sets=c(2562, 2564, 2579), queries=queries$query, labels = queries$label) 

query_brieven = '(title:brieven title:bbc title:"geachte redactie" title:"geachte lezer" title:lezersbrieven title:lezersreacties title:kruiswoord* title:"tv-ladder" tite:correctie)'



meta_print = amcat.articles(conn, project=69, articleset=2562, columns = c("date", "publisher")) %>%
  as_tibble() %>%  add_column(mtype="Newspapers")
meta_online = amcat.articles(conn, project=69, articleset=2564, columns = c("date", "publisher")) %>%
  as_tibble() %>%  add_column(mtype="Online (nos.nl/nu.nl)") %>% filter(publisher %in% c("NOS nieuws", "NU.nl"))
meta_tv = amcat.articles(conn, project=69, articleset=2579, columns = c("date", "publisher")) %>% 
  as_tibble() %>% add_column(mtype="TV")
meta = bind_rows(meta_print, meta_online, meta_tv) %>%
  mutate(id=as.numeric(id)) %>%
  filter(date < "2021-03-18", date >= "2021-01-01")


write_rds(meta, tmp)
}
tmp = here("data/tmp/wave2_media_visibility.rmd")
if (file.exists(tmp)) {
  d = read_rds(tmp)
} else {
  conn = amcat.connect("https://vu.amcat.nl")
  h = amcat.hits(conn, project=69, sets=c(2562, 2564, 2579), queries=queries$query, labels = queries$partij) %>% 
    as_tibble() %>% rename(party=query)
  d = left_join(h, meta)
  write_rds(d, tmp)
}

totals = meta %>% group_by(period, mtype) %>% summarize(ntot=n())
parties = d %>% group_by(party) %>% summarize(n=n()) %>% arrange(-n) %>% pull(party)