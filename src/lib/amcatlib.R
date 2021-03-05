
library(tidyverse)
library(here)
library(glue)

query_party = function(partij, alias) {
  case_when(partij == "Denk" ~ alias,
            !is.na(alias) ~ str_c(partij, " OR ", alias),
            T ~ partij) %>% tolower()
}
query_lijsttrekker = function(naam, partij) {
  an = rsplit(naam)
  functie_zoek=case_when(an == "Hoekstra" ~ "bewinds* OR minister*",
                         an == "Rutte"  ~ "premier* OR bewinds* OR minister*",
                         T ~ "kamerl* OR parlement*")
  alias = case_when(partij == "CU" ~ " OR christenunie",
                    partij == "FvD" ~ " OR forum",
                    partij == "GL" ~ " OR groenlinks",
                    partij == "PvdD" ~ " OR dieren",
                    T ~ "")
  glue('"{naam}" OR "{an} ({functie_zoek} OR lijsttrek* OR partijleid* OR {partij}{alias})"~10') %>% tolower()
}
clean = function(x) x %>% str_replace_all("[“”]", '"')

rsplit = function(x) str_match(x, ".* (.*)")[,2]


get_party_queries = function() {
  read_csv(here("data/raw/partijen.csv")) %>% mutate(across(everything(), clean)) %>%
   mutate(leader_query = query_lijsttrekker(lijsttrekker, partij),
             party_query = query_party(partij, alias),
             query=glue("{party_query} OR {leader_query}"))
}
