
library(tidyverse)
library(frequency)
library(htmltools)
library(dplyr)
library(janitor)

#install.packages("gmodels")
#library(gmodels)


setwd("C:\\Users\\ahf600\\surfdrive\\K21_coderen\\R inlezen K21")
d=readRDS("NETcodering")

#check op fout gecodeerde zinnen
d |>
  tabyl(subject01, object01, type)
d |>
  tabyl(type)

#CAU foute zinnen
#alles waar subject=/issue
CAU <- filter(d, type=="CAU")
CAUwr <- CAU |> 
  filter(subject01 !="issue") |> 
  select(sentenceID, doc_id, txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="CAUwr") #1 zin handhaaf ik 3753 (was 100 zinnen)

##CC foute zinnen
#S: issue | ?realityUD?
CC <- filter(d, type=="CC")
CCwro <- CC |> 
  filter(subject01 =="issue" | subject01 =="?realityUD?" | subject01 =="media" | subject01=="society") |> 
  select(sentenceID, doc_id, txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="CCwro") #0 zinnen (was 123 zinnen)
#actor actor zinnen anders dan party party
CCact <- CC |> 
  filter(subject01 =="media" | subject01 =="society" | subject01=="party" | subject01=="politics") |> 
  select(sentenceID, doc_id, txt, type, src, subject, object, src01, subject01,object01)
CCwrcs <- CCact |>
  filter((subject01 =="party" |subject01=="politics") & (object01 !="party" & object01 != "politics")) |>
  add_column(fout="CCwrcs") #0 zinnen (was 85 zinnen)

##CS foute zinnen
#S: issue | ?realityUD? | ?realitySF?
CS <- filter(d, type=="CS")
CSwrs <- CS |> 
  filter(subject01 =="issue" | subject01 =="?realityUD?" | subject01 =="?realitySF?") |> 
  select(sentenceID, doc_id, txt, type, src, subject, object, src01, subject01, object01) |>
  add_column(fout="CSwrs") #0 zinnen (was 10 zinnen)
CSwro <- CS |> 
  filter(object01=="?ideal?" | object01=="issue") |> 
  select(sentenceID, doc_id, txt, type, src, subject, object, src01, subject01, object01) |>
  add_column(fout="CSwro") #0 zinnen (was 63 zinnen)
#actor actor zinnen anders dan party party
CScc <- CS |> 
  filter((subject01 =="party" |subject01=="politics") & (object01 =="party" | object01 == "politics")) |>
  select(sentenceID, doc_id, txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="CScc") #0 zinnen (was 43 zinnen)

#EVA foute zinnen
#alles waar object=/issue
EVA <- filter(d, type=="EVA")
EVAwr <- EVA |> 
  filter(object01 !="?ideal?") |> 
  select(sentenceID,doc_id, txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="EVAwr") #0 zinnen (was 41 zinnen)
EVAiss <- EVA |> 
  filter((subject01 == "?realityUD?" | subject01 =="issue") & object01 =="?ideal?") |> 
  select(sentenceID, doc_id, txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="EVAiss") #0 zinnen (was 25 zinnen)

#IP foute zinnen
#alles waar subject = reality, issue
IP <- filter(d, type=="IP")
IPwr <- IP |> 
  filter(subject01 =="?realitySF?" | subject01=="?realityUD?" | subject01=="issue") |> 
  select(sentenceID, doc_id,txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="IPwr") #0 zinnen (was 54 zinnen)
IPiss <- IP |> 
  filter(subject01 == "media" | subject01 =="party" | subject01 =="politics" | subject01=="society") |> 
  filter(object01!="issue") |>
  select(sentenceID, doc_id,txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="IPiss") #0 zinnen (was 208 zinnen)

#IVA foute zinnen
#alles waar niet subject = issue en object /= ideal
IVA <- filter(d, type=="IVA")
IVAwr <- IVA |> 
  filter(subject01 !="issue") |>
  select(sentenceID, doc_id,txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="IVAwr") # 1 zin accepteer ik, 1953 (was 62 zinnen)
IVAiss <- IVA |> 
  filter(subject01=="issue" & (object01 !="?ideal?")) |>
  select(sentenceID, txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="IVAiss") #0 zinnen (was 9 zinnen)

#REA foute zinnen
#alles waar niet subject = realityUD en object /= issue
REA <- filter(d, type=="REA")
REAwr <- REA |> 
  filter(subject01 !="?realityUD?") |>
  select(sentenceID, doc_id,txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="REAwr") #0 zinnen (was 72 zinnen)
REAac <- REA |> 
  filter(subject01=="?realityUD?" & (object01 !="issue")) |>
  select(sentenceID, doc_id,txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="REAac") #0 zinnen (EU buitenland) (was 121 zinnen)

#SF foute zinnen
#alles waar niet subject = realitySF en object = issue
SF <- filter(d, type=="SF")
SFwr <- SF |> 
  filter(subject01 !="?realitySF?") |>
  select(sentenceID, doc_id,txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="SFwr") #0 zinnen (was 35 zinnen)
SFiss <- SF |> 
  filter(subject01=="?realitySF?" & (object01 =="issue")) |>
  select(sentenceID, doc_id,txt, type, src, subject, object, src01, subject01,object01) |>
  add_column(fout="SFiss") #51 zinnen bedrijven (was 33 zinnen)

#alle zinnen staan er nu goed in
#onderstaande syntax kan achterwege blijven
FOUT <- full_join(CAUwr, CCwro)
FOUT <- full_join(FOUT, CCwrcs)
FOUT <- full_join(FOUT, CSwrs)
FOUT <- full_join(FOUT, CSwro)
FOUT <- full_join(FOUT, CScc)
FOUT <- full_join(FOUT, EVAwr)
FOUT <- full_join(FOUT, EVAiss)
FOUT <- full_join(FOUT, IPwr)
FOUT <- full_join(FOUT, IPiss)
FOUT <- full_join(FOUT, IVAwr)
FOUT <- full_join(FOUT, IVAiss)
FOUT <- full_join(FOUT, REAwr)
FOUT <- full_join(FOUT, REAac)
FOUT <- full_join(FOUT, SFwr)
FOUT <- full_join(FOUT, SFiss)

#write.csv2(FOUT, file="verkeerd gecodeerde type.csv")
write.csv2(FOUT, file="verkeerd gecodeerde type2.csv")

#=================

#er staan nog een aantal dubbel gecodeerde artikelen in
nart <- tabyl(d, doc_id) |>
  select(n>"6")
dub 
tabyl(d, cod_id)
tabyl(d, doc_id)
dub <- spread(d, doc_id, cod_id)

dub <- d[, c("sentenceID", "doc_id", "cod_id", "date", "title")]
tabyl(dub, doc_id, cod_id)

dubc <- dub |>
  filter(doc_id =="3289259" & doc_id=="3289260")

d <- d |>
  add_column(dc="")|>
  mutate_if(doc_id==any(3289264, 3289265, 3289266, 3289267, 3289268, 3296018, 3296019, 3296020, 3296347, 3296351, 3296359, 3296519, 3296521, 3296522, 3296523, 3296980, 3296981, 3296982, 3297270, 3297271, 3297272, 3297808, 3297842, 3297846, 3288092, 3288094), replace(dc ~"1")) 

