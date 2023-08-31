# uitschrijven basale bestanden voor koppeling
library(tidyverse)
library(frequency)
library(htmltools)
library(dplyr)
library(janitor)

#onderstaande bestanden overgenomen uit publieksbestanden, mediavariabelen
lbl_I1 = tibble(value = c(1:9),
                label = c("Television", "Newspapers or opinion magazines (paper or online)", "Radio (including podcast and online)", "Online news sites (such as nu.nl) or blogs", "Social media (such as Facebook, Twitter)", "Messaging apps (such as Whatsapp, messenger)", "(Offline) conversations with people", "News apps or push messages on your phone", "Search engines (such as Google or Bing)"),
                wording = c("Televisie", "Kranten of opiniebladen (op papier of online)", "Radio (inclusief podcast en online)", "Online nieuwssites (zoals nu.nl) of blogs", "Social media (bijvoorbeeld Facebook, Twitter)", "Messaging apps (bijvoorbeeld Whatsapp, messenger)", "(Offline) gesprekken met mensen", "Nieuwsapps of pushberichten op uw telefoon", "Zoekmachines (zoals Google of Bing)"))

lbl_I2 = tibble(value = c(1:13) +200, 
                label = c("de Telegraaf", "NRC Handelsblad", "Nrc.Next", "Algemeen Dagblad (AD)", "Trouw", "de Volkskrant", "Metro", "A regional or local newspaper", "De Groene Amsterdammer", "HP/de Tijd", "Elsevier", "Vrij Nederland", "Other, namely:"), 
                wording = c("de Telegraaf", "NRC Handelsblad", "Nrc.Next", "Algemeen Dagblad (AD)", "Trouw", "de Volkskrant", "Metro", "Een regionale of lokale krant", "De Groene Amsterdammer", "HP/de Tijd", "Elsevier", "Vrij Nederland", "Anders, namelijk:"))

lbl_I3 = tibble(value = c(1:16)+300, 
                label = c("Press comnference of Rutte and De Jonge", "NOS Journaal", "RTL Nieuws", "Hart van Nederland", "De Vooravond", "M", "Nieuwsuur", "EenVandaag", "Op Eén", "Jinek", "Beau", "WNL Opiniemakers", "Zondag met Lubach", "Dit was het nieuws", "Own channels of politicians and opinion makers", "Other, namely:"), 
                wording = c("Persconferentie Rutte en De Jonge", "NOS Journaal", "RTL Nieuws", "Hart van Nederland", "De Vooravond", "M", "Nieuwsuur", "EenVandaag", "Op Eén", "Jinek", "Beau", "WNL Opiniemakers", "Zondag met Lubach", "Dit was het nieuws", "Eigen kanalen van politici en opiniemakers", "Anders, namelijk:"))

lbl_I4 = tibble(value = c(1:9) +400, 
                label = c("Nu.nl", "Geenstijl.nl", "GoogleNews", "Blendle.com", "Decorrespondent.nl",  "Tpo.nl", "Joop.nl", "Political blogs, namely:", "Other, namely:"), 
                wording = c("Nu.nl", "Geenstijl.nl", "GoogleNews", "Blendle.com", "Decorrespondent.nl",  "Tpo.nl", "Joop.nl", "Politieke blogs, namelijk:", "Anders, namelijk:"))

lbl_I5 = tibble(value = c(1:11) +500, 
                label = c("Twitter", "Facebook", "Youtube", "Instagram", "Snapchat", "Viber", "Telegram", "Google Hangouts", "Tumblr", "Reddit", "Other, namely:"), 
                wording = c("Twitter", "Facebook", "Youtube", "Instagram", "Snapchat", "Viber", "Telegram", "Google Hangouts", "Tumblr", "Reddit", "Anders, namelijk:"))

lbl_I6 = tibble(value = c(1:6) +600, 
                label = c("Whatsapp", "Viber", "Telegram", "Signal", "Google Hangouts", "Other, namely:"), 
                wording = c("Whatsapp", "Viber", "Telegram", "Signal", "Google Hangouts", "Anders, namelijk:"))

lbl_I7 <- tibble(value = c(1:2,11,3:10) +700, 
                 label= c("Nu", "NOS", "Teletekst", "Telegraaf", "AD", "NRC", "Volkskrant", "News aggregator like feedly or flipboard", "Apple News", "Google News", "Other, namely:"), 
                 wording = c("Nu", "NOS", "Teletekst", "Telegraaf", "AD", "NRC", "Volkskrant", "News aggregator zoals feedly of flipboard", "Apple News", "Google News",  "Anders, namelijk:"))

lbl_I8 = tibble(value=c(1:13) +800,
                label = c("NOS journaal", "RTL nieuws", "SBS (Hart van Nederland)", "Zondag met Lubach", "NU.nl", "Algemeen Dagblad", "De Telegraaf", "De Volkskrant", "NRC",	"GeenStijl", "De Correspondent", "Twitter", "Facebook"),
                wording = c("NOS journaal", "RTL nieuws", "SBS (Hart van Nederland)", "Zondag met Lubach", "NU.nl", "Algemeen Dagblad", "De Telegraaf", "De Volkskrant", "NRC",	"GeenStijl", "De Correspondent", "Twitter", "Facebook"))

#creatie mediavariabelen vergelijkbaar met variabelen in publieksbestand, met in kolom media de media die gecodeerd zijn
lbl_L = lbl_I1 |>
  bind_rows(list (lbl_I2, lbl_I3, lbl_I4, lbl_I5, lbl_I6, lbl_I7, lbl_I8)) |>
  mutate(media=case_when(value %in% c(201,202,204,205,206,302,303,307,401,702,703,704,705,706,801,802,805,807,808,809) ~value)) |>
  rename(pmedia = value)
tabyl(lbl_L$pmedia)


d=readRDS("NETcodering")

#in effectanalyse willen we waarden government en kabinet vervangen door CDA, VVD, D66 en CU

e = d|>
  filter(src=="kabinet" | src =="government" | subject=="kabinet" | subject =="government" | object=="kabinet" | object =="government") |> #704 zinnen met kabinet of government in bron, subject of object
  select(sentenceID:sentence, type:dir, quality:object01) #comment, txt en automatische variabelen eruit om het bestand wat overzichtelijk te houden
f = d|>
  filter(src=="linksePartijen" | subject=="linksePartijen" | object=="linksePartijen")|> #67 zinnen met kabinet of government in bron, subject of object
  select(sentenceID:sentence, type:dir, quality:object01) #comment, txt en automatische variabelen eruit om het bestand wat overzichtelijk te houden
g = d|>
  filter(src=="ChristelijkePartij" | subject=="ChristelijkePartij" | object=="ChristelijkePartij")|> #67 zinnen met kabinet of government in bron, subject of object
  select(sentenceID:sentence, type:dir, quality:object01) #comment, txt en automatische variabelen eruit om het bestand wat overzichtelijk te houden
h = d|>
  filter(src=="rechtsePartijen" | subject=="rechtsePartijen" | object=="rechtsePartijen")|> #67 zinnen met kabinet of government in bron, subject of object
  select(sentenceID:sentence, type:dir, quality:object01) #comment, txt en automatische variabelen eruit om het bestand wat overzichtelijk te houden

#kenobject middenPartijen komt twee keer voor op object positie. hercoderen tot CDA
tabyl(d$object) #CDA: 444, middenPartijen: 2
#middenpartij hercoderen naar CDA en kolom kg toevoegen voor te splitsen variabelen
d = d |>
  select(sentenceID:sentence, type:dir, quality:object01) |> #comment, txt en automatische variabelen eruit om het bestand wat overzichtelijk te houden
  add_column("kg"=0) |>
  mutate(object = recode(object,"middenPartijen"="CDA")) |>
  mutate(kg=as.numeric(kg)) |> 
  mutate(kg = case_when(src == "kabinet" ~ 1,
                        src == "government" ~ 1,
                        subject == "kabinet" ~ 1,
                        subject== "government" ~ 1,
                        object == "kabinet" ~ 1,
                        object =="government" ~ 1,
                        src=="linksePartijen" ~ 2,
                        subject=="linksePartijen" ~ 2,
                        object=="linksePartijen" ~ 2,
                        src=="ChristelijkePartij" ~ 3,
                        subject=="ChristelijkePartij" ~ 3,
                        object=="ChristelijkePartij" ~ 3,
                        src=="rechtsePartijen" ~ 4,
                        subject=="rechtsePartijen" ~ 4,
                        object=="rechtsePartijen" ~ 4))

tabyl(d$kg) #check: 704 cases kabinet/government; 67 cases linksePartijen; 8 cases ChristelijkePartijen; 21 cases rechtsePartijen (want 6 zinnen met combinatie linksePartijen-rechtsePartijen)
tabyl(d$object)  #CDA: 446, middenPartijen: 0

#populistischePartijen komt een keer voor op subjectpositie (populistische partijen kunnen het goed vinden met Christelijke partijen)
#bestand zonder zinnen met kabinet, government, linksePartijen, ChristelijkePartijen, rechtsePartijen: 9526 zinnen
i = d |>
  filter(is.na(kg)) |>
  add_column("weight"=1) |>
  select(sentenceID:object01, weight) #verwijder overbodige tussenvariabelen kg


#zinnen met kabinet en govenment naar lang formaat en src, subject, object en src01, subject01 en object01 vervangen door VVD, CDA, CU, D66
e=e |>
  add_column("kgVVD" = "VVD") |>
  add_column("kgCDA" = "CDA") |>
  add_column("kgD66" = "D66") |>
  add_column("kgCU" = "CU") |>
  pivot_longer(cols = starts_with("kg"), names_to = "KG", values_to = "kgparty") |> #lang formaat: 2816 zinnen
  mutate(src = if_else((src =="kabinet" | src =="government"), kgparty, src)) |>
  mutate(subject = if_else((subject =="kabinet" | subject =="government"), kgparty, subject)) |>
  mutate(object = if_else((object =="kabinet" | object =="government"), kgparty, object)) |>
  mutate(src01 = if_else((src =="kabinet" | src =="government"), "party", src01)) |>
  mutate(subject01 = if_else((subject =="kabinet" | subject =="government"), "party", subject01)) |>
  mutate(object01 = if_else((object =="kabinet" | object =="government"), "party", object01)) |>
  add_column("weight" = 1/4) |>
  mutate(sentenceID = case_when(kgparty == "VVD" ~ (sentenceID + 1000000),
                                  kgparty == "CDA" ~ (sentenceID + 2000000),
                                  kgparty == "D66" ~ (sentenceID + 3000000),
                                  kgparty == "CU" ~(sentenceID + 4000000))) |> #creert een uniek id voor sentence, dat nog verwijst naar oude id
  select(sentenceID:object01, weight) #verwijder overbodige tussenvariabelen KG, kgparty

#zinnen met linksePartijen naar lang formaat en src, subject, object en src01, subject01 en object01 vervangen door VVD, CDA, CU, D66
f=f |>
  add_column("lpPvdA" = "PvdA") |>
  add_column("lpGL" = "GroenLinks") |>
  add_column("lpPvdD" = "PvdD") |>
  add_column("lpSP" = "SP") |>
  pivot_longer(cols = starts_with("lp"), names_to = "LP", values_to = "lpparty")|> #lang formaat: 268 zinnen
  mutate(src = if_else((src =="linksePartijen"), lpparty, src)) |>
  mutate(subject = if_else((subject =="linksePartijen"), lpparty, subject)) |>
  mutate(object = if_else((object =="linksePartijen"), lpparty, object)) |>
  mutate(src01 = if_else((src =="linksePartijen"), "party", src01)) |>
  mutate(subject01 = if_else((subject =="linksePartijen"), "party", subject01)) |>
  mutate(object01 = if_else((object =="linksePartijen"), "party", object01))|>
  add_column("weight" = 1/4) |>
  mutate(sentenceID = case_when(lpparty == "PvdA" ~ (sentenceID + 5000000),
                                lpparty == "GroenLinks" ~ (sentenceID + 6000000),
                                lpparty == "PvdD" ~ (sentenceID + 7000000),
                                lpparty == "SP" ~(sentenceID + 8000000))) |> #creert een uniek id voor sentence, dat nog verwijst naar oude id
  select(sentenceID:object01, weight) #verwijder overbodige tussenvariabelen LP, lpparty

#zinnen met ChristelijkePartijen naar lang formaat en src, subject, object en src01, subject01 en object01 vervangen door CDA, CU, SGP
g=g |>
  add_column("cpCDA" = "CDA") |>
  add_column("cpCU" = "CU") |>
  add_column("cpSGP" = "SGP") |>
  pivot_longer(cols = starts_with("cp"), names_to = "CP", values_to = "cpparty")|> #lang formaat: 268 zinnen
  mutate(src = if_else((src =="ChristelijkePartijen"), cpparty, src)) |>
  mutate(subject = if_else((subject =="ChristelijkePartijen"), cpparty, subject)) |>
  mutate(object = if_else((object =="ChristelijkePartijen"), cpparty, object)) |>
  mutate(src01 = if_else((src =="ChristelijkePartijen"), "party", src01)) |>
  mutate(subject01 = if_else((subject =="ChristelijkePartijen"), "party", subject01)) |>
  mutate(object01 = if_else((object =="ChristelijkePartijen"), "party", object01))|>
  add_column("weight" = 1/3) |>
  mutate(sentenceID = case_when(cpparty == "CDA" ~ (sentenceID + 9000000),
                                cpparty == "CU" ~ (sentenceID + 10000000),
                                cpparty == "SGP" ~ (sentenceID + 11000000))) |> #creert een uniek id voor sentence, dat nog verwijst naar oude id
  select(sentenceID:object01, weight) #verwijder overbodige tussenvariabelen CP, cpparty

#zinnen met rechtsePartijen naar lang formaat en src, subject, object en src01, subject01 en object01 vervangen door CDA, CU, SGP
#eerst zes zinnen met linksePartijen|rechtsePartijen selecteren (oorspronkelijk ID 3325, 3326, 22083, 22084, 24143, 24144)
frp = f |>
  filter(subject == "rechtsePartijen" | object == "rechtsePartijen")
h=h |>
  filter(subject != "linksePartijen" & object !="linksePartijen")
#frp en h koppelen
h <- full_join(h, frp)
h = h |>
  add_column("rpVVD" = "VVD") |>
  add_column("rpPVV" = "PVV") |>
  add_column("rpJA21" = "JA21") |>
  add_column("rpFvD" = "FvD") |>
  pivot_longer(cols = starts_with("rp"), names_to = "RP", values_to = "rpparty")|> #lang formaat: 268 zinnen
  mutate(src = if_else((src =="rechtsePartijen"), rpparty, src)) |>
  mutate(subject = if_else((subject =="rechtsePartijen"), rpparty, subject)) |>
  mutate(object = if_else((object =="rechtsePartijen"), rpparty, object)) |>
  mutate(src01 = if_else((src =="rechtsePartijen"), "party", src01)) |>
  mutate(subject01 = if_else((subject =="rechtsePartijen"), "party", subject01)) |>
  mutate(object01 = if_else((object =="rechtsePartijen"), "party", object01))|>
  add_column("weight1" = 1/4) |>
  mutate(weight = replace_na(weight, 1)) |>
  mutate(weight = if_else((weight ==1/4), (weight * weight1), weight1)) |>
  mutate(sentenceID = case_when(rpparty == "VVD" ~ (sentenceID + 12000000),
                                rpparty == "PVV" ~ (sentenceID + 13000000),
                                rpparty == "JA21" ~ (sentenceID + 14000000),
                                rpparty == "FvD" ~ (sentenceID + 15000000))) 
h = h |>
  select(sentenceID:weight) #verwijder overbodige tussenvariabelen RP, rpparty, weight1

#nu alle aangepaste bestanden weer onder elkaar zetten
z <- full_join(e, f)
z <- full_join(z, g)
z <- full_join(z, h)
z <- full_join(z, i)
#nu zitten 12 zinnen met rechtsePartijen op subject en 12 op object er dubbel in omdat dit linksePartijen-rechtsePartijen waren. De linksePartijen zijn bij f gedupliceerd, maar bij h nogmaals. Alleen die van h handhaven.
z = z |>
  mutate(dubbel = case_when(sentenceID == 5003325 ~1,
                            sentenceID == 6003325 ~1,
                            sentenceID == 7003325 ~1,
                            sentenceID == 8003325 ~1,
                            sentenceID == 5022084 ~1,
                            sentenceID == 6022084 ~1,
                            sentenceID == 7022084 ~1,
                            sentenceID == 8022084 ~1,
                            sentenceID == 5024144 ~1,
                            sentenceID == 6024144 ~1,
                            sentenceID == 7024144 ~1,
                            sentenceID == 8024144 ~1,
                            sentenceID == 5003326 ~1,
                            sentenceID == 6003326 ~1,
                            sentenceID == 7003326 ~1,
                            sentenceID == 8003326 ~1,
                            sentenceID == 5022083 ~1,
                            sentenceID == 6022083 ~1,
                            sentenceID == 7022083 ~1,
                            sentenceID == 8022083 ~1,
                            sentenceID == 5024143 ~1,
                            sentenceID == 6024143 ~1,
                            sentenceID == 7024143 ~1,
                            sentenceID == 8024143 ~1)) |>
  mutate(dubbel = if_else(is.na(dubbel), 0, dubbel)) |>  #verander NA in 0
    filter(dubbel==0) |>
  select(sentenceID:weight) #variabele dubbel weer verwijderen want nu niet meer nodig


#oordeel extrapolatie  
ox = z|>
  filter(type=="EVA" | type =="IVA") |>
  #  select(sentenceID:sentence, type:dir, quality:object01) |>
  mutate(src = if_else(is.na(src),"no", src)) |> #verander NA in no
  mutate(src01 = if_else(is.na(src01),"no", src01)) |>
  mutate(src = recode(src,"no"="media")) |>
  mutate(src01 = recode(src01,"no"="media")) |>
  mutate(objectOX = if_else(is.na(src), object, subject)) |>
  mutate(subjectOX = if_else(is.na(src), subject, src)) |>
  mutate(object01OX = if_else(is.na(src),object01,subject01)) |>
  mutate(subject01OX = if_else(is.na(src),subject01,src01))|>
  mutate(typeOX = type) |>
  mutate(typeOX = case_when(type=="IVA" ~ "IP",
                            ((subject01OX=="party" | subject01OX=="politics") & (object01OX=="party" | object01OX=="politics")) ~ "CC",
                            ((subject01OX=="society" | subject01OX=="media") | (object01OX=="society" | object01OX=="media")) ~ "CS"))

oxcau = z |>
  filter(type == "CAU") |>
  mutate(typeOX = case_when(object01 == "party" ~ "SF",
                            object01 == "issue" ~ "REA"))


#variabelen selecteren voor koppeling met publieksbestanden
#uit ox: bij IP zinnen als subject01=party -> object; 
#        bij CC zinnen als subject01=party & object01=government -> subject
#        bij CS zinnen als als object01=party -> object, als subject01 = party -> subject

ox |> tabyl(subject01OX, object01OX, typeOX)
oxcau |> tabyl(subject01, object01, typeOX) # 261 zinnen issue-issue geteld als rea; 34 zinnen issue-party geteld als SF; overige 183 zinnen NA
z |> tabyl(subject01, object01, type) # klopt (1 NA)

#nu uit de subbestanden de juiste zinnen meenemen die we in de analyse willen gebruiken
#ox1 -> IP zinnen na oordeelextrapolatie van IVA; nemen alleen zinnen mee met party als subject mee (48 cases + 1 fout)
ox1 = ox |> #IVA zinnen die na oordeelextrapolatie IP zinnen geworden
  filter(typeOX == "IP" & subject01OX == "party") |> 
  select(sentenceID:sentence, quality, weight:typeOX) |>
  rename(object = objectOX, subject = subjectOX, object01=object01OX, subject01=subject01OX, type=typeOX) 
ox2a = ox |> #EVA zinnen die na oordeelextrapolatie CC zinnen zijn geworden, met subject=party en object=party worden dit PP zinnen (151 cases)
  filter(typeOX == "CC" & (subject01OX=="party" & object01OX =="party")) |> #nemen alleen party zinnen mee op object, politics verdwijnt: 251 zinnen over
  select(sentenceID:sentence, quality, weight:typeOX) |>
  mutate(typeOX = recode(typeOX, "CC"="PP")) |>
  rename(object = objectOX, subject = subjectOX, object01=object01OX, subject01=subject01OX, type=typeOX)
ox2b = ox |> #EVA zinnen die na oordeelextrapolatie CC zinnen zijn geworden, met subject=party en object=politics worden dit CP zinnen (241 cases)
  filter(typeOX == "CC" & (subject01OX == "party"& object01OX=="politics" )) |> #nemen alleen party zinnen mee op subject en politics op object: 90 zinnen over
  select(sentenceID:sentence, quality, weight:typeOX) |>
  mutate(typeOX = recode(typeOX, "CC"="PC")) |>
  rename(object = objectOX, subject = subjectOX, object01=object01OX, subject01=subject01OX, type=typeOX) 
ox2c = ox |> #EVA zinnen die na oordeelextrapolatie CC zinnen zijn geworden, met subject=politics en object=party worden dit CP zinnen (241 cases)
  filter(typeOX == "CC" & (subject01OX == "politics" & object01OX=="party")) |> #nemen alleen politics=subject en party=object: 2 zinnen over
  select(sentenceID:sentence, quality, weight:typeOX) |>
  mutate(typeOX = recode(typeOX, "CC"="PC")) |>
  rename(object = objectOX, subject = subjectOX, object01=object01OX, subject01=subject01OX, type=typeOX)
ox3a = ox |> #EVA zinnen die na oordeelextrapolatie CS zinnen zijn geworden
  filter(typeOX == "CS" & (object01OX =="party" & subject01OX=="society")) |> #nemen alleen CS zinnen mee met party op object en society op subject, media en society-society verdwijnt, 45 zinnen over
  select(sentenceID:sentence, quality, weight:typeOX) |>
  mutate(typeOX = recode(typeOX, "CS"="SP")) |>
  rename(object = objectOX, subject = subjectOX, object01=object01OX, subject01=subject01OX, type=typeOX)
ox3b = ox |> #EVA zinnen die na oordeelextrapolatie CS zinnen zijn geworden
  filter(typeOX == "CS" & (subject01OX == "party" & object01OX=="society")) |> #nemen alleen CS zinnen mee met party op subject en society op object, media en society-society verdwijnt, 20 zinnen
  select(sentenceID:sentence, quality, weight:typeOX) |>
  mutate(typeOX = recode(typeOX, "CS"="PS")) |>
  rename(object = objectOX, subject = subjectOX, object01=object01OX, subject01=subject01OX, type=typeOX)
ox3c = ox |> #EVA zinnen die na oordeelextrapolatie CS zinnen zijn geworden
  filter(typeOX == "CS" & (object01OX =="party" & subject01OX =="media")) |> #nemen alleen CS zinnen mee met party op object, society-society of media-media verdwijnt, 507 zinnen over
  select(sentenceID:sentence, quality, weight:typeOX) |>
  mutate(typeOX = recode(typeOX, "CS"="MP")) |>
  rename(object = objectOX, subject = subjectOX, object01=object01OX, subject01=subject01OX, type=typeOX)
ox3d = ox |> #EVA zinnen die na oordeelextrapolatie CS zinnen zijn geworden
  filter(typeOX == "CS" & (subject01OX =="party" & object01OX =="media")) |> #nemen alleen CS zinnen mee met party op object, society-society of media-media verdwijnt, 12 zinnen over
  select(sentenceID:sentence, quality, weight:typeOX) |>
  mutate(typeOX = recode(typeOX, "CS"="PM")) |>
  rename(object = objectOX, subject = subjectOX, object01=object01OX, subject01=subject01OX, type=typeOX)
ox4 = oxcau |> #CAU zinnen die na oordeelextrapolatie SF of REA zijn geworden; 296 zinnen over
  filter(typeOX == "REA" | typeOX =="SF") |>
  select(sentenceID:sentence, subject, object, quality, subject01:typeOX) |>
  rename(type=typeOX) |>
  mutate(subject01 = case_when(type == "REA" ~ "?realityUD?", # de gedupliceerde zinnen waarde 1/4 geven
                             type== "SF" ~"?realitySF?"))
ox5a = z |> #uit z bestand, normale (voor oordeelextrapolatie) CC zinnen
  filter(type == "CC" & (subject01 =="party" & object01 =="party")) |> #CC zinnen over met party op subject en object: van 1586 naar 1174
  select(sentenceID:type, subject, object, quality, subject01:weight) |>
  mutate(type = recode(type, "CC"="PP"))
ox5b = z |> #uit f bestand, normale (voor oordeelextrapolatie) CC zinnen
  filter(type == "CC" & (subject01 == "party" & object01 =="politics")) |> #CC zinnen over met subject=party en object=politics: van 1586 naar 274
  select(sentenceID:type, subject, object, quality, subject01:weight) |>
  mutate(type = recode(type, "CC"="PC"))
ox5c = z |> #uit f bestand, normale (voor oordeelextrapolatie) CC zinnen
  filter(type == "CC" & (subject01 == "politics" & object01 =="party")) |> #CC zinnen over met subject=politics en object=party: van 1586 naar 134
  select(sentenceID:type, subject, object, quality, subject01:weight) |>
  mutate(type = recode(type, "CC"="CP"))
ox6a = z |> #uit f bestand, normale (voor oordeelextrapolatie) CS zinnen
  filter(type == "CS" & (object01 =="party" & subject01=="society")) |> #nemen alleen CS zinnen mee met party op object en society op subject, zinnen met media en society-society verwijderen: van 1265 naar 1083 = -182
  select(sentenceID:type, subject, object, quality, subject01:weight) |>
  mutate(type = recode(type, "CS"="SP")) 
ox6b = z |> #uit f bestand, normale (voor oordeelextrapolatie) CS zinnen
  filter(type == "CS" & (subject01 == "party" & object01=="society")) |> #nemen alleen CS zinnen mee met party op subject, CS zinnen met society/media-society/media verwijderen: van 1265 naar 1083 = -182
  select(sentenceID:type, subject, object, quality, subject01:weight) |>
  mutate(type = recode(type, "CS"="PS"))
ox6c = z |> #uit f bestand, normale (voor oordeelextrapolatie) CS zinnen
  filter(type == "CS" & (object01 =="party" & subject01=="media")) |> #nemen alleen CS zinnen mee met party op object, zinnen met society/media-society/media verwijderen: van 1265 naar 1083 = -182
  select(sentenceID:type, subject, object, quality, subject01:weight) |>
  mutate(type = recode(type, "CS"="MP"))
ox6d = z |> #uit f bestand, normale (voor oordeelextrapolatie) CS zinnen
  filter(type == "CS" & (subject01 == "party" & object01=="media")) |> #nemen alleen CS zinnen mee met party op subject, CS zinnen met society/media-society/media verwijderen: van 1265 naar 1083 = -182
  select(sentenceID:type, subject, object, quality, subject01:weight) |>
  mutate(type = recode(type, "CS"="PM"))
ox7 = z |> #uit f bestand alle rea zinnen
  filter(type == "REA") |>
  select(sentenceID:type, subject, object, quality, subject01:weight)
ox8 = z |> #uit f bestand SF zinnen met party in object
  filter(type == "SF" & object01 == "party")|> #SF zinnen met politics verdwijnen: van 2371 maar 2021 =-350
  select(sentenceID:type, subject, object, quality, subject01:weight)
ox9 = z |> #uit f bestand IP zinnen met party in subject
  filter(type == "IP" & (object01 == "issue" & subject01=="party")) |> #alle ander actoren dan party met issue posities verdwijnen: van 3676 naar 1774=-1902
  select(sentenceID:type, subject, object, quality, subject01:weight)


#nu ox1 t/m ox9 koppelen
sum <- full_join(ox1, ox2a)
sum <- full_join(sum, ox2b)
sum <- full_join(sum, ox2c)
sum <- full_join(sum, ox3a)
sum <- full_join(sum, ox3b)
sum <- full_join(sum, ox3c)
sum <- full_join(sum, ox3d)
sum <- full_join(sum, ox4)
sum <- full_join(sum, ox5a)
sum <- full_join(sum, ox5b)
sum <- full_join(sum, ox5c)
sum <- full_join(sum, ox6a)
sum <- full_join(sum, ox6b)
sum <- full_join(sum, ox6c)
sum <- full_join(sum, ox6d)
sum <- full_join(sum, ox7)
sum <- full_join(sum, ox8)
sum <- full_join(sum, ox9)


#vergelijking van type voor en na oordeelextrapolatie en voor en na duplicatie zinnen van kabinet en government
tabyl(d$type)
tabyl(sum$type)
tabyl(z$type)
tabyl(ox$type)
tabyl(oxcau$type)

#ter controle
sum |> tabyl(subject01, object01, type)
sum |> tabyl(subject01, object01)
sum |> tabyl(type)
sum|>
  filter(subject01=="party") |>
    tabyl(subject)  # er staan nog 3 populistische in
sum|>
  filter(object01=="party") |>
  tabyl(object) #er staan nog 12 rechtse partijen in
ox3a |>
  tabyl(subject)
ox3b |>
  tabyl(object)


#geaggregeerd bestand van alle zinnen die meegenomen moeten worden in de koppeling aan publieksbestand
#via unite een variabele maken van gewenste subject-object combinatie
#voor de typen CP, IP, MP, SP, REA en SF is dat subject01-object
UitS01 = sum |>
  filter(type =="CP" | type=="IP"| type=="MP"| type=="SP"| type== "REA"| type=="SF")|>
  unite("XY", subject01, object) |>
  mutate(wqual=weight*quality) |>
  arrange(publisher, date, type, XY) |>
  group_by(publisher, date, type, XY)|>
  summarise(wqual=sum(wqual), qual=mean(quality), freq=sum(weight))
#voor de typen CP, IP, MP, SP is dat subject-object01
UitO01 = sum |>
  filter(type =="PC" | type=="PM"| type=="PS")|>
  unite("XY", subject, object01) |>
  mutate(wqual=weight*quality) |>
  arrange(publisher, date, type, XY) |>
  group_by(publisher, date, type, XY)|>
  summarise(wqual=sum(wqual), qual=mean(quality), freq=sum(weight))
#voor de typen PP, subject-object
UitOS = sum |>
  filter(type =="PP")|>
  unite("XY", subject, object) |>
  mutate(wqual=weight*quality) |>
  arrange(publisher, date, type, XY) |>
  group_by(publisher, date, type, XY)|>
  summarise(wqual=sum(wqual), qual=mean(quality), freq=sum(weight))

#drie bestanden samenvoegen
Uit <- full_join(UitS01, UitO01)
Uit <- full_join(Uit, UitOS)


#tot hier

# 1. dit werkt. Kunnen we hier case_when van maken
# 2. beginnen met een bestand met datums en daar deze gegevens aan gekoppeld worden (misschien nog een keer long gemaakt)
# 3. exponentieel verval na een week of twee weken?


ggplot(data=Uit, aes(fill=wqual, x="", y=object)) +
  geom_tile() +
  ggthemes::theme_hc() + ylab(NULL) + ylab("party") + 
  scale_fill_gradient2(low=scales::muted("red"), mid="#F2F2F2",midpoint=0, high=scales::muted("green"), guide=F) 

ggplot(data=Uit, aes(x=subject, y=object, fill=wqual)) +
  geom_tile() +
  geom_text(aes(label = wqual), color ="black", size=1) +
  coord_fixed() +
  ggthemes::theme_hc() + ylab("object") + xlab("subject") + 
  scale_fill_gradient2(low=scales::muted("red"), mid="#F2F2F2",midpoint=0, high=scales::muted("green"), guide="none") +
  theme(axis.text.x = element_text(angle = 45, vjust=1, hjust=1))

#tot hier
