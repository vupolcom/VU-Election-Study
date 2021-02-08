library(glue)
library(tidyverse)
lbl = list()

lbl$age = tibble(value = 1:6, 
                 label = c("<24", "25-34",  "35-44",  "45-54",  "55-64", ">64"), 
                 wording = c("18 - 110", " ", " ", " ", " ", " "))

lbl$education = tibble(value = c(1:3,999), 
                       label = c("High", "Medium",  "Low",  "Don't know"), 
                        wording = c("WO-doctoraal of master of HBO-master, postdoctoraal; HBO of WO propedeuse, HBO (behalve HBO-master), WO-kandidaats of WO-bachelor", "HAVO of VWO bovenbouw, HBS,  MMS; MBO 2, 3, 4 of MBO oude structuur voor 1998", "MAVO, HAVO of VWO (eerste drie jaar), ULO, MULO, VMBO (theoretisch of gemengd), voortgezet speciaal onderwijs; LBO, VBO, VMBO (kader- of beroepsgericht), MBO 1; Geen onderwijs, basisonderwijs, cursus inburgering, cursus Nederlandse taal", "Weet niet, Geen opgave"))

lbl$job <- tibble(value = c(1:8), 
                  label = c("Full-time employed", "Part-time employed", "Entrepreneur", "Unemployed and searching for a job", "Unemployed and not searching for a job or incapacitated", "Housewife/Househusband or else", "Retired", "Student or full-time education"), 
                  wording = c("Fulltime werkzaam", "Parttime werkzaam", "Werkzaam als zelfstandig ondernemer", "Werkloos en werkzoekend", "Werkloos en niet-werkzoekend /Arbeidsongeschikt", "Huisvrouw/huisman of anders", "Gepensioneerd of VUT", "Student/Leerling/Fulltime opleiding"))

lbl$gender <- tibble(value = c(0, 1), 
                     label = c("Male", "Female"), 
                     wording = c("Man", "Vrouw"))

lbl$region <- tibble(value = c(1:5),
                     label = c("Three big cities (Amsterdam, Rotterdam, The Hague)", "West of the country", "North  of the country", "East  of the country", "South  of the country"), 
                     wording = c("Een van de 3 grote steden of randgemeenten: Amsterdam (plus Diemen, Ouder-Amstel, Landsmeer, Amstelveen); Rotterdam (plus Schiedam, Capelle aan den IJssel, Krimpen aan den IJssel, Nederlek, Ridderkerk, Barendrecht, Albrandswaard; Den Haag (plus Leidschendam, Voorburg, Rijswijk, Wassenaar, Wateringen)", "Het westen:  Noord-Holland, Zuid-Holland en Utrecht (exclusief een van de 3 grote steden)", "Het noorden: Groningen, Friesland en Drenthe", "Het oosten: Overijssel, Gelderland en Flevoland", "Het zuiden: Zeeland, Noord-Brabant en Limburg"))

lbl$ethnicity <- tibble(value = c(1:5,999), 
                        label = c("Dutch origin", "First generation non-Western immigrant", "Second generation non-Western immigrant", "First generation Western immigrant", "Second generation Western immigrant", "No response"), 
                        wording = c("Autochtoon", "Niet-westers allochtoon; 1e generatie", "Niet-westers allochtoon; 2e generatie", "Westers allochtoon; 1e generatie", "Westers allochtoon; 2e generatie", "Onbekend"))


lbl$internet_use <- tibble(value = c(1:5),
                           label = c("Much more for work", "More for work", "Equal for work and private reasons", "More for private reasons", "Much more for private reasons"), 
                           wording = c("Veel vaker voor werk", "Iets vaker voor werk", "Ongeveer evenveel voor werk als om persoonlijke redenen", "Iets vaker voor persoonlijke reden", "Veel vaker voor persoonlijke redenen"))

lbl$A2 <- tibble(value = c(1:15,999), 
            label = c("CDA", "ChristenUnie", "D66", "Denk", "Forum for Democracy", "GroenLinks", "PvdA", "Animal Rights Party", "PVV", "SGP", "SP", "VVD", "50Plus Party", "Other party", "I vote blanco","I don't know yet"), 
            wording = c("CDA", "ChristenUnie", "D66", "Denk", "Forum voor Democratie", "GroenLinks", "PvdA", "Partij voor de Dieren", "PVV", "SGP", "SP", "VVD", "50Plus Partij", "Andere partij", "Ik stem blanco","Weet ik niet nog niet"))

lbl$B2 = tibble(value = c(1:13),
        label = c("CDA & Wopke Hoekstra", "ChristenUnie & Gert-Jan Segers", "D66 & Sigrid Kaag", "Denk & Farid Azarkan", "Forum voor Democratie & Thierry Baudet", "GroenLinks & Jesse Klaver", "PvdA & Lodewijk Asscher", "Partij voor de Dieren & Esther Ouwehand", "PVV & Geert Wilders", "SGP  & Kees van der Staaij", "SP & Lilian Marijnissen", "VVD & Mark Rutte", "50Plus Partij & Liane den Haan"),
        wording = c("CDA & Wopke Hoekstra", "ChristenUnie & Gert-Jan Segers", "D66 & Sigrid Kaag", "Denk & Farid Azarkan", "Forum voor Democratie & Thierry Baudet", "GroenLinks & Jesse Klaver", "PvdA & Lodewijk Asscher", "Partij voor de Dieren & Esther Ouwehand", "PVV & Geert Wilders", "SGP  & Kees van der Staaij", "SP & Lilian Marijnissen", "VVD & Mark Rutte", "50Plus Partij & Liane den Haan"))

lbl$E1 <- tibble(value = c(1:14,997:999), 
                 label = c("CDA", "ChristenUnie", "D66", "Denk", "Forum for Democracy", "GroenLinks", "PvdA", "Animal Rights Party", "PVV", "SGP", "SP", "VVD", "50Plus Party", "Other party", "I don't know", "I didn't vote", "I wasn't eligble to vote"), 
                 wording = c("CDA", "ChristenUnie", "D66", "Denk", "Forum voor Democratie", "GroenLinks", "PvdA", "Partij voor de Dieren", "PVV", "SGP", "SP", "VVD", "50Plus Partij", "Andere partij", "Weet ik niet meer", "Ik heb niet gestemd", "Ik mocht niet stemmen"))


lbl$F2 = tibble(value=c(1:11),
                label = c("the jurisprudence", "journalism", "the government", "the House of Representatives", "the European Union", "political parties", "politicians", "Dutch democracy", "science", "big corporations", "banks"),
                wording = c("de rechtspraak","de journalistiek", "de regering", "de Tweede Kamer", "de Europese Unie", "politieke partijen", "politici", "de Nederlandse democratie", "de wetenschap", "grote bedrijven", "banken"))

lbl$H3 = tibble(value = c(1:5), 
                     label = c("Much stricter measures to combat the virus (curfew, area ban).", "Slightly stricter measures to prevent viruses.", "The measures chosen by the government.", "Slightly more flexible measures so that only the most vulnerable elderly are protected.", "Much smoother measures to get the economy and nightlife going immediately."), 
                     wording = c("Veel strengere maatregelen om het virus tegen te gaan (avondklok, gebiedsverbod).", "Iets strengere maatregelen om virus tegen te gaan.","De maatregelen die de regering gekozen heeft.", "Iets soepelere maatregelen zodat alleen de meest kwetsbare ouderen afgeschermd worden.", "Veel soepelere maatregelen om de economie en het uitgaansleven onmiddellijk op gang te brengen."))
lbl$H7 = tibble(value = c(1:4), 
            label = c("Definitely do it", "Do it", "Don't do it", "Definitely don't do it"), 
            wording = c("Zeer zeker doen", "Doen", "Niet doen", "Zeer zeker niet doen"))


lbl$I1 = tibble(value = c(1:9),
              label = c("Television", "Newspapers or opinion magazines (paper or online)", "Radio (including podcast and online)", "Online news sites (such as nu.nl) or blogs", "Social media (such as Facebook, Twitter)", "Messaging apps (such as Whatsapp, messenger)", "(Offline) conversations with people", "News apps or push messages on your phone", "Search engines (such as Google or Bing)"),
              wording = c("Televisie", "Kranten of opiniebladen (op papier of online)", "Radio (inclusief podcast en online)", "Online nieuwssites (zoals nu.nl) of blogs", "Social media (bijvoorbeeld Facebook, Twitter)", "Messaging apps (bijvoorbeeld Whatsapp, messenger)", "(Offline) gesprekken met mensen", "Nieuwsapps of pushberichten op uw telefoon", "Zoekmachines (zoals Google of Bing)"))

lbl$I2 = tibble(value = c(1:13), 
                       label = c("de Telegraaf", "NRC Handelsblad", "Nrc.Next", "Algemeen Dagblad (AD)", "Trouw", "de Volkskrant", "Metro", "A regional or local newspaper", "De Groene Amsterdammer", "HP/de Tijd", "Elsevier", "Vrij Nederland", "Other, namely:"), 
                       wording = c("de Telegraaf", "NRC Handelsblad", "Nrc.Next", "Algemeen Dagblad (AD)", "Trouw", "de Volkskrant", "Metro", "Een regionale of lokale krant", "De Groene Amsterdammer", "HP/de Tijd", "Elsevier", "Vrij Nederland", "Anders, namelijk:"))

lbl$I3 = tibble(value = c(1:16), 
    label = c("Press comnference of Rutte and De Jonge", "NOS Journaal", "RTL Nieuws", "Hart van Nederland", "De Vooravond", "M", "Nieuwsuur", "EenVandaag", "Op Eén", "Jinek", "Beau", "WNL Opiniemakers", "Zondag met Lubach", "Dit was het nieuws", "Own channels of politicians and opinion makers", "Other, namely:"), 
    wording = c("Persconferentie Rutte en De Jonge", "NOS Journaal", "RTL Nieuws", "Hart van Nederland", "De Vooravond", "M", "Nieuwsuur", "EenVandaag", "Op Eén", "Jinek", "Beau", "WNL Opiniemakers", "Zondag met Lubach", "Dit was het nieuws", "Eigen kanalen van politici en opiniemakers", "Anders, namelijk:"))
      
lbl$I4 = tibble(value = c(1:9), 
                label = c("Nu.nl", "Geenstijl.nl", "GoogleNews", "Blendle.com", "Decorrespondent.nl",  "Tpo.nl", "Joop.nl", "Political blogs, namely:", "Other, namely:"), 
                wording = c("Nu.nl", "Geenstijl.nl", "GoogleNews", "Blendle.com", "Decorrespondent.nl",  "Tpo.nl", "Joop.nl", "Politieke blogs, namelijk:", "Anders, namelijk:"))

lbl$I5 = tibble(value = c(1:11), 
                label = c("Twitter", "Facebook", "Youtube", "Instagram", "Snapchat", "Viber", "Telegram", "Google Hangouts", "Tumblr", "Reddit", "Other, namely:"), 
                wording = c("Twitter", "Facebook", "Youtube", "Instagram", "Snapchat", "Viber", "Telegram", "Google Hangouts", "Tumblr", "Reddit", "Anders, namelijk:"))
                 
lbl$I6 = tibble(value = c(1:6), 
       label = c("Whatsapp", "Viber", "Telegram", "Signal", "Google Hangouts", "Other, namely:"), 
       wording = c("Whatsapp", "Viber", "Telegram", "Signal", "Google Hangouts", "Anders, namelijk:"))

lbl$I7 <- tibble(value = c(1:2,11,3:10), 
            label= c("Nu", "NOS", "Teletekst", "Telegraaf", "AD", "NRC", "Volkskrant", "News aggregator like feedly or flipboard", "Apple News", "Google News", "Other, namely:"), 
            wording = c("Nu", "NOS", "Teletekst", "Telegraaf", "AD", "NRC", "Volkskrant", "News aggregator zoals feedly of flipboard", "Apple News", "Google News",  "Anders, namelijk:"))

lbl$I8 = tibble(value=c(1:13),
label = c("NOS journaal", "RTL nieuws", "SBS (Hart van Nederland)", "Zondag met Lubach", "NU.nl", "Algemeen Dagblad", "De Telegraaf", "De Volkskrant", "NRC",	"GeenStijl", "De Correspondent", "Twitter", "Facebook"),
wording = c("NOS journaal", "RTL nieuws", "SBS (Hart van Nederland)", "Zondag met Lubach", "NU.nl", "Algemeen Dagblad", "De Telegraaf", "De Volkskrant", "NRC",	"GeenStijl", "De Correspondent", "Twitter", "Facebook"))

labels = bind_rows(lbl, .id="variable") 

label = function(values, variable) {
  l = labels[labels$variable == variable,]
  fct_reorder(factor(l$label[match(values, l$value)]), values)
}

recode_parties = function(p) case_when(
  p %in% c("I don't know yet" , "I don't know") ~ "Weet niet",
  p %in% c("I didn't vote", "I vote blanco") ~ "Niet",
  p == "I wasn't eligble to vote" ~ "Nieuw",
  p == "Animal Rights Party" ~ "PvdD",
  p == "50Plus Party" ~ "50+",
  p == "Forum for Democracy" ~ "FvD",
  p == "Other party" ~ "Anders",
  T ~ as.character(p))


long_mc = function() {
  d <- read_csv(here("data/intermediate/VUElectionPanel2021_wave0.csv")) 
  result = list()
  for (var in c("F2", str_c("I", 1:8))) 
    result[[var]] = d %>% select(iisID, starts_with(var), -contains("_other")) %>% pivot_longer(-iisID, names_to="medium") %>% 
    mutate(medium=label(as.numeric(str_remove(medium, glue("^{var}_"))), var)) %>% filter(!is.na(value))
  bind_rows(result, .id="question")
}

