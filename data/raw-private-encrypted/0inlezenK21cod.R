install.packages("tidyverse")
install.packages("frequency")
install.packages("htmltools")
install.packages("janitor")
install.packages("rmarkdown")
install.packages("POSIXlt")  #voor data

library(tidyverse)
library(frequency)
library(htmltools)
library(dplyr)
library(janitor)
library(POSIXlt)

tidyverse_packages()

setwd("C:\\Users\\ahf600\\surfdrive\\K21_coderen\\R inlezen K21")
d <- read_csv2("NETcoderingenALLcontrole4.csv")

#checks
spec(d)
problems(d)
colnames(d)
length (d)
dim(d)

#check belangrijkste variabelen
d |> tabyl(sentence) #11 ontbrekende zinsnummers aangevuld in csv bestand
d |> tabyl(Satz)
d |> tabyl(type)
d |> tabyl(src)
d |> tabyl(subject)
d |> tabyl(object)
d |> tabyl(dir)
d |> tabyl(cod_id) #5 zinnen zonder waarde aangevuld in csv bestand
d |> tabyl(publisher)
d |> tabyl(date)
d |> tabyl(type, dir)

#controle missende waarden; aantal combinaties uitgeprobeerd. Verkeerd gecodeerde zinnen gecorrigeerd in csv bestand
d |> filter(type=="") |> filter(dir !="") |> tabyl (sentenceID) 

d=d |> mutate(quality=recode(dir,"n"="-1","o"="0","p"="1")) |> 
  mutate(quality=as.numeric(quality))

d |> tabyl(quality)

#test mean quality
d |> filter(!is.na(quality)) |> mutate(quality=as.numeric(quality)) |> 
  pull(quality) |>
  mean()

#select non-missing typ
e=d |> filter(!is.na(quality)) |> mutate(quality=as.numeric(quality))

dim(e)
#check op lege zinnen
e |> filter(subject=="") |> tabyl (sentenceID)
e |> filter(object=="") |> tabyl (sentenceID)
e |> filter(dir=="") |> tabyl (sentenceID)

#dim(d)
#dim(e)

#variabelen source, subject, object op overkoepelend niveau maken
e |> tabyl(src)

e=e |> mutate(src01 = case_when(
  src == "buitenland" ~ "politics",
  src == "EU" ~ "politics",
  src == "land" ~ "politics",
  src == "international" ~ "politics",
  src == "Israel" ~ "politics",
  src == "Myanmar" ~ "politics",
  src == "Rusland" ~ "politics",
  src == "VK" ~ "politics",
  src == "VS" ~ "politics", 
  src == "government" ~ "politics", 
  src == "parlement" ~ "politics",
  src == "adviesorganen" ~ "politics", 
  src == "koningshuis" ~ "politics", 
  src == "judiciary" ~ "society", 
  src == "advocaat" ~ "society", 
  src == "procureur-generaal" ~ "society", 
  src == "rechter" ~ "society", 
  src == "kabinet" ~ "politics", 
  src == "Parlement" ~ "politics", 
  src == "semiOverheid" ~ "politics", 
  src == "lagereOverheid" ~ "politics", 
  src == "media" ~ "media", 
  src == "journalist" ~ "media", 
  src == "persmedia" ~ "media", 
  src == "rtv" ~ "media", 
  src == "webmedia" ~ "media", 
  src == "party" ~ "party", 
  src == "50Plus" ~ "party", 
  src == "BBB" ~ "party", 
  src == "BIJ1" ~ "party", 
  src == "Blank7" ~ "party", 
  src == "CDA" ~ "party", 
  src == "ChristelijkePartij" ~ "party", 
  src == "CodeOranje" ~ "party", 
  src == "CU" ~ "party", 
  src == "D66" ~ "party", 
  src == "DeGroenen" ~ "party", 
  src == "DENK" ~ "party", 
  src == "Feestpartij" ~ "party", 
  src == "FvD" ~ "party", 
  src == "GroenLinks" ~ "party", 
  src == "Ja21" ~ "party", 
  src == "JA21" ~ "party", 
  src == "JezusLeeft" ~ "party", 
  src == "JONG" ~ "party", 
  src == "LibertaireP" ~ "party", 
  src == "linksePartijen" ~ "party", 
  src == "LKrol" ~ "party", 
  src == "middenPartij" ~ "party", 
  src == "ModernNL" ~ "party", 
  src == "NIDA" ~ "party", 
  src == "Nlbeter" ~ "party", 
  src == "Oprecht" ~ "party", 
  src == "PartijEenheid" ~ "party", 
  src == "partijRepubliek" ~ "party", 
  src == "Piratenpartij" ~ "party", 
  src == "populistischePartijen" ~ "party", 
  src == "PvdA" ~ "party", 
  src == "PvdD" ~ "party", 
  src == "PVV" ~ "party", 
  src == "rechtsePartijen" ~ "party", 
  src == "SGP" ~ "party", 
  src == "SP" ~ "party", 
  src == "Splinter" ~ "party", 
  src == "TrotsOpNL" ~ "party", 
  src == "Ubuntu" ~ "party", 
  src == "VOLT" ~ "party", 
  src == "VrijSoc" ~ "party", 
  src == "VVD" ~ "party", 
  src == "WijzijnNl" ~ "party", 
  src == "society" ~ "society", 
  src == "bedrijven" ~ "society", 
  src == "belangengroep" ~ "society", 
  src == "burgers" ~ "society", 
  src == "expert" ~ "society", 
    TRUE ~ src)) 

e |> tabyl(src01)

e=e |> mutate(subject01 = case_when(
subject == "?realitySF?" ~ "?realitySF?",
subject == "?realityUD?" ~ "?realityUD?",
subject == "50Plus" ~ "party",
subject == "adviesorganen" ~ "politics",
subject == "advocaat" ~ "society",
subject == "BBB" ~ "party",
subject == "bedrijven" ~ "society",
subject == "begrotingssaldo" ~ "issue",
subject == "belangengroep" ~ "society",
subject == "belastHeffing" ~ "issue",
subject == "bestrijdingCrim" ~ "issue",
subject == "bestVernieuw" ~ "issue",
subject == "BIJ1" ~ "party",
subject == "buitenland" ~ "politics",
subject == "burgers" ~ "society",
subject == "campagne" ~ "issue",
subject == "CDA" ~ "party",
subject == "ChristelijkePartij" ~ "party",
subject == "CodeOranje" ~ "party",
subject == "coronabestrijding" ~ "issue",
subject == "coronaverspreiding" ~ "issue",
subject == "CU" ~ "party",
subject == "D66" ~ "party",
subject == "DENK" ~ "party",
subject == "economie" ~ "issue",
subject == "EU" ~ "politics",
subject == "expert" ~ "society",
subject == "EuropeseUnie" ~ "issue",
subject == "Feestpartij" ~ "party",
subject == "FvD" ~ "party",
subject == "geZorg" ~ "issue",
subject == "government" ~ "politics",
subject == "GroenLinks" ~ "party",
subject == "infrastructuur" ~ "issue",
subject == "integratie" ~ "issue",
subject == "international" ~ "politics",
subject == "issue" ~ "issue",
subject == "JA21" ~ "party",
subject == "journalist" ~ "media",
subject == "judiciary" ~ "society",
subject == "kabinet" ~ "politics",
subject == "klimaatMilieu" ~ "issue",
subject == "koningshuis" ~ "politics",
subject == "lagereOverheid" ~ "politics",
subject == "land" ~ "society",
subject == "lijsttrekkers" ~ "politics",
subject == "linksePartijen" ~ "party",
subject == "LKrol" ~ "party",
subject == "media" ~ "media",
subject == "middenPartijen" ~ "party",
subject == "ModernNL" ~ "party",
subject == "Myanmar" ~ "politics",
subject == "NIDA" ~ "party",
subject == "normenWaarden" ~ "issue",
subject == "OenW" ~ "issue",
subject == "ondernemingsklimaat" ~ "issue",
subject == "ontwikHulp" ~ "issue",
subject == "ontwikkelingCrim" ~ "issue",
subject == "Oprecht" ~ "party",
subject == "parlement" ~ "politics",
subject == "partijRepubliek" ~ "politics",
subject == "party" ~ "politics",
subject == "persmedia" ~ "media",
subject == "Piratenpartij" ~ "party",
subject == "populistischePartijen" ~ "party", 
subject == "politiek" ~ "politics",
subject == "procureur-generaal" ~ "society",
subject == "PvdA" ~ "party",
subject == "PvdD" ~ "party",
subject == "PVV" ~ "party",
subject == "rechter" ~ "society",
subject == "rechtsePartijen" ~ "party",
subject == "rtv" ~ "media",
subject == "RutteIII" ~ "politics",
subject == "semiOverheid" ~ "politics",
subject == "SGP" ~ "party",
subject == "society" ~ "society",
subject == "SocZek" ~ "issue",
subject == "SP" ~ "party",
subject == "Splinter" ~ "party",
subject == "terreurbestrijding" ~ "issue",
subject == "Ubuntu" ~ "party",
subject == "VK" ~ "politics",
subject == "VN" ~ "politics",
subject == "VOLT" ~ "party",
subject == "vrijheidsrechten" ~ "issue",
subject == "VS" ~ "politics",
subject == "VVD" ~ "party",
subject == "webmedia" ~ "media",
subject == "werk" ~ "issue",
subject == "woning" ~ "issue",
TRUE ~ subject)) 

e |> tabyl(subject01)

e=e |> mutate(object01 = case_when(
  object == "?realitySF?" ~ "?realitySF?",
  object == "?realityUD?" ~ "?realityUD?",
  object == "50Plus" ~ "party",
  object == "adviesorganen" ~ "politics",
  object == "advocaat" ~ "society",
  object == "BBB" ~ "party",
  object == "bedrijven" ~ "society",
  object == "begrotingssaldo" ~ "issue",
  object == "belangengroep" ~ "society",
  object == "belastHeffing" ~ "issue",
  object == "bestrijdingCrim" ~ "issue",
  object == "bestVernieuw" ~ "issue",
  object == "BIJ1" ~ "party",
  object == "buitenland" ~ "politics",
  object == "burgers" ~ "society",
  object == "campagne" ~ "issue",
  object == "CDA" ~ "party",
  object == "ChristelijkePartij" ~ "party",
  object == "CodeOranje" ~ "party",
  object == "coronabestrijding" ~ "issue",
  object == "coronaverspreiding" ~ "issue",
  object == "CU" ~ "party",
  object == "D66" ~ "party",
  object == "DENK" ~ "party",
  object == "economie" ~ "issue",
  object == "EU" ~ "politics",
  object == "EuropeseUnie" ~ "issue",
  object == "expert" ~ "society",
  object == "Feestpartij" ~ "party",
  object == "FvD" ~ "party",
  object == "geZorg" ~ "issue",
  object == "government" ~ "politics",
  object == "GroenLinks" ~ "party",
  object == "infrastructuur" ~ "issue",
  object == "integratie" ~ "issue",
  object == "international" ~ "politics",
  object == "issue" ~ "issue",
  object == "JA21" ~ "party",
  object == "journalist" ~ "media",
  object == "judiciary" ~ "society",
  object == "kabinet" ~ "politics",
  object == "klimaatMilieu" ~ "issue",
  object == "koningshuis" ~ "politics",
  object == "lagereOverheid" ~ "politics",
  object == "land" ~ "society",
  object == "lijsttrekkers" ~ "politics",
  object == "linksePartijen" ~ "party",
  object == "LKrol" ~ "party",
  object == "media" ~ "media",
  object == "middenPartijen" ~ "party",
  object == "ModernNL" ~ "party",
  object == "Myanmar" ~ "politics",
  object == "NIDA" ~ "party",
  object == "normenWaarden" ~ "issue",
  object == "OenW" ~ "issue",
  object == "ondernemingsklimaat" ~ "issue",
  object == "ontwikHulp" ~ "issue",
  object == "ontwikkelingCrim" ~ "issue",
  object == "parlement" ~ "politics",
  object == "partijRepubliek" ~ "politics",
  object == "party" ~ "politics",
  object == "persmedia" ~ "media",
  object == "Piratenpartij" ~ "party",
  object == "politiek" ~ "politics",
  object == "procureur-generaal" ~ "society",
  object == "PvdA" ~ "party",
  object == "PvdD" ~ "party",
  object == "PVV" ~ "party",
  object == "rechter" ~ "society",
  object == "rechtsePartijen" ~ "party",
  object == "rtv" ~ "media",
  object == "RutteIII" ~ "politics",
  object == "Rusland" ~ "politics",
  object == "semiOverheid" ~ "politics",
  object == "SGP" ~ "party",
  object == "society" ~ "society",
  object == "SocZek" ~ "issue",
  object == "SP" ~ "party",
  object == "Splinter" ~ "party",
  object == "terreurbestrijding" ~ "issue",
  object == "Ubuntu" ~ "party",
  object == "VK" ~ "politics",
  object == "VN" ~ "politics",
  object == "VOLT" ~ "party",
  object == "vrijheidsrechten" ~ "issue",
  object == "VS" ~ "politics",
  object == "VVD" ~ "party",
  object == "webmedia" ~ "media",
  object == "werk" ~ "issue",
  object == "woning" ~ "issue",
  TRUE ~ object)) 

e |> tabyl(object01)

saveRDS(e, file="NETcodering")

