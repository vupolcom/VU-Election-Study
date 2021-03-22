#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Wave 4
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#DEPENDS: data/raw-private/qualtrics_api_key.txt
#CREATES: data/intermediate/VUElectionPanel2021_wave4.csv

library(tidyverse)
library(here)

source(here("src/lib/data.R"))
output_fn = here("data/intermediate/wave4.csv")
d = fetch_survey(surveyID = "SV_3kfGN9GH4fAJ662", 
                 verbose = TRUE, force_request = T,
                 label = TRUE, convert = FALSE)
#labels = d %>% mutate(iisID=as.numeric(iisID))%>% select(iisID, A2_label = A2) %>% na.omit() 
#cb = get_codebook()  %>% filter(variable=="A2") %>% select(value, A2_label=label)
#d4 %>% select(iisID, A2) %>% inner_join(labels) %>% select(A2, A2_label) %>% unique() %>% full_join(cb) %>% View()

attributes(d)$column_map %>% filter(str_detect(description, "Wopke")) %>% select(qname, description) %>% View()

d4 = load_survey(survey_id="SV_3kfGN9GH4fAJ662") %>% 
  select(-I3_14_TEXT) %>%
  add_column(A2_14_TEXT=NA) # was missing in survey?


# Regular blocks
M = clean_meta(d4) %>% add_column(wave="wave 4", .after = 'iisID')
A = clean_A(d4)
B = clean_B(d4)
I = clean_I(d4) 


df = M %>%
  left_join(A, by="iisID") %>%
  left_join(B, by="iisID") %>%
  left_join(I, by="iisID") 

# TODO: other issues

message("Writing output file", output_fn)
write_csv(df, output_fn)


