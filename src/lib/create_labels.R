library(glue)
library(tidyverse)
lbl = list()

## Background Variables
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


## Block A
lbl$A2 <- tibble(value = c(1:15,999), 
            label = c("CDA", "ChristenUnie", "D66", "Denk", "Forum for Democracy", "GroenLinks", "PvdA", "Animal Rights Party", "PVV", "SGP", "SP", "VVD", "50Plus Party", "Other party", "I vote blanco","I don't know yet"), 
            wording = c("CDA", "ChristenUnie", "D66", "Denk", "Forum voor Democratie", "GroenLinks", "PvdA", "Partij voor de Dieren", "PVV", "SGP", "SP", "VVD", "50Plus Partij", "Andere partij", "Ik stem blanco","Weet ik niet nog niet"))

# Block B
lbl$B2 = tibble(value = c(1:13),
        label = c("CDA & Wopke Hoekstra", "ChristenUnie & Gert-Jan Segers", "D66 & Sigrid Kaag", "Denk & Farid Azarkan", "Forum voor Democratie & Thierry Baudet", "GroenLinks & Jesse Klaver", "PvdA & Lodewijk Asscher", "Partij voor de Dieren & Esther Ouwehand", "PVV & Geert Wilders", "SGP  & Kees van der Staaij", "SP & Lilian Marijnissen", "VVD & Mark Rutte", "50Plus Partij & Liane den Haan"),
        wording = c("CDA & Wopke Hoekstra", "ChristenUnie & Gert-Jan Segers", "D66 & Sigrid Kaag", "Denk & Farid Azarkan", "Forum voor Democratie & Thierry Baudet", "GroenLinks & Jesse Klaver", "PvdA & Lodewijk Asscher", "Partij voor de Dieren & Esther Ouwehand", "PVV & Geert Wilders", "SGP  & Kees van der Staaij", "SP & Lilian Marijnissen", "VVD & Mark Rutte", "50Plus Partij & Liane den Haan"))

# Block E
lbl$E1 <- tibble(value = c(1:14,997:999), 
                 label = c("CDA", "ChristenUnie", "D66", "Denk", "Forum for Democracy", "GroenLinks", "PvdA", "Animal Rights Party", "PVV", "SGP", "SP", "VVD", "50Plus Party", "Other party", "I don't know", "I didn't vote", "I wasn't eligble to vote"), 
                 wording = c("CDA", "ChristenUnie", "D66", "Denk", "Forum voor Democratie", "GroenLinks", "PvdA", "Partij voor de Dieren", "PVV", "SGP", "SP", "VVD", "50Plus Partij", "Andere partij", "Weet ik niet meer", "Ik heb niet gestemd", "Ik mocht niet stemmen"))

# Block F
lbl$F1 = tibble(value = c(1:10),
       `label` = c("Politicians don't care about the opinions of people like me.", 
                            "The political parties are only interested in my vote and not in my opinion.", 
                            "Against their better judgment, politicians promise more than they can deliver.", 
                            "You become a member of parliament more by your political friends than by your skills.", 
                            "Most politicians are skilled people who know what they are doing.", 
                            "Politicians are able to solve the most important problems.", 
                            "I feel well represented by Dutch politicians.", 
                            "What in politics is called 'making compromises' is actually just betraying your principles.", 
                            "A strong head of government is good for the Netherlands, even if he stretches the rules a bit to get things done.", 
                            "The most important political decisions should be made by the people and not by politicians."),
       `wording` = c("Politici maken zich niet  druk om de mening van mensen zoals ik.", 
                           "De politieke partijen zijn alleen maar geïnteresseerd in mijn stem en niet in mijn mening.",
                           "Tegen beter weten in beloven politici meer dan ze kunnen waarmaken.", 
                           "Kamerlid word je eerder door je politieke vrienden dan door je bekwaamheden.", 
                           "De meeste politici zijn bekwame mensen die weten wat ze doen.", 
                           "Politici zijn in staat om de belangrijkste problemen op te lossen.", 
                           "Ik voel mij goed vertegenwoordigd door Nederlandse politici.", 
                           "Wat men in de politiek ‘het sluiten van compromissen’ noemt, is eigenlijk gewoon het verraden van je principes.", 
                           "Een sterke regeringsleider is goed voor Nederland, ook als deze de regels wat oprekt om dingen voor elkaar te krijgen.",
                           "De belangrijkste politieke beslissingen moeten worden genomen door het volk en niet door politici."))

lbl$F2 = tibble(value=c(1:11),
                label = c("The justice system", "Journalism", "The government", "The House of Representatives", "The European Union", "Political parties", "Politicians", "Dutch democracy", "Science", "Big corporations", "Banks"),
                wording = c("de rechtspraak","de journalistiek", "de regering", "de Tweede Kamer", "de Europese Unie", "politieke partijen", "politici", "de Nederlandse democratie", "de wetenschap", "grote bedrijven", "banken"))

#Block G
lbl$G1 = tibble(value = c(1:5),
                label = c("How the current cabinet has governed the past 4 years", "How the VVD has ruled the past 4 years", "How the CDA has ruled the past 4 years", "How D66 has ruled the past 4 years", "How the Christian Union has ruled in the past 4 years"),
                wording = c("Hoe het huidige kabinet de afgelopen 4 jaar heeft geregeerd", "Hoe de VVD de afgelopen 4 jaar heeft geregeerd",	"Hoe het CDA de afgelopen 4 jaar heeft geregeerd", "Hoe D66 de afgelopen 4 jaar heeft geregeerd", "Hoe de ChristenUnie de afgelopen 4 jaar heeft geregeerd"))

lbl$G2 = tibble(value = c(1:13),
                label = c("Wopke Hoekstra", "Gert-Jan Segers", "Sigrid Kaag", "Farid Azarkan",  "Thierry Baudet","Jesse Klaver", "Lodewijk Asscher", "Esther Ouwehand", "Geert Wilders", "Kees van der Staaij","Lilian Marijnissen", "Mark Rutte", "Liane den Haan"),
                wording = c("Wopke Hoekstra", "Gert-Jan Segers", "Sigrid Kaag", "Farid Azarkan",  "Thierry Baudet","Jesse Klaver", "Lodewijk Asscher", "Esther Ouwehand", "Geert Wilders", "Kees van der Staaij","Lilian Marijnissen", "Mark Rutte", "Liane den Haan"))
lbl$G3 = lbl$G2
lbl$G4 = lbl$G2

# Block H
lbl$H3 = tibble(value = c(1:5), 
                     label = c("Much stricter measures to combat the virus (curfew, area ban).", "Slightly stricter measures to prevent viruses.", "The measures chosen by the government.", "Slightly more flexible measures so that only the most vulnerable elderly are protected.", "Much smoother measures to get the economy and nightlife going immediately."), 
                     wording = c("Veel strengere maatregelen om het virus tegen te gaan (avondklok, gebiedsverbod).", "Iets strengere maatregelen om virus tegen te gaan.","De maatregelen die de regering gekozen heeft.", "Iets soepelere maatregelen zodat alleen de meest kwetsbare ouderen afgeschermd worden.", "Veel soepelere maatregelen om de economie en het uitgaansleven onmiddellijk op gang te brengen."))

lbl$H6 = tibble(value= c(1:3),
            label = c("Children who are born now get it better than we do.", "The arrival of asylum seekers and immigrants is good for the Netherlands.", "International trade is good for the Netherlands."),
            wording = c("Kinderen die nu geboren worden krijgen het beter dan wij.", "De komst van asielzoekers en immigranten is goed voor Nederland.", "Internationale handel is goed voor Nederland."))
lbl$H7 = tibble(value = c(1:4), 
            label = c("Definitely do it", "Do it", "Don't do it", "Definitely don't do it"), 
            wording = c("Zeer zeker doen", "Doen", "Niet doen", "Zeer zeker niet doen"))


# Block I 
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


lbl$I9 = tibble(value = c(1:9),
                       label = c("I feel exhausted by the amount of news coming at me", "If I follow the news, it has a negative effect on my mood", "I cannot trust that the news coming at me is truthful", "The often explicit images in the news coming at me bother me", "If I would talk about the news, I get in trouble with others and I prefer to avoid it", "The news takes up too much of my time", "If I follow the news, it has a negative physical effect on me (e.g., I can't keep up with the news. Headaches, sleep problems, etc.)", "I try to avoid political news", "I try to avoid news about Corona"),
                       wording = c("Ik voel me uitgeput door de hoeveelheid nieuws die op mij afkomt", "Als ik het nieuws volg, heeft dat een negatief effect op mijn humeur","Ik kan er niet op vertrouwen dat het nieuws dat op mij afkomt waarheidsgetrouw is", "De vaak expliciete beelden in het nieuws dat op mij afkomt storen me", "Als ik zou praten over het nieuws, krijg ik moeilijkheden met anderen en dat vermijd ik liever", "Het nieuws neemt te veel van mijn tijd in beslag", "Als ik het nieuws volg, heeft dat een negatief lichamelijk effect op mij (bijv. hoofdpijn, slaapproblemen, etc.)", "Ik probeer politiek nieuws te vermijden",	"Ik probeer nieuws over Corona te vermijden"))



write_csv(labels, here("data/raw/codebook.csv"))

