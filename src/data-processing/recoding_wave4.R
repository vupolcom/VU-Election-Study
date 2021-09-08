#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Wave 4
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#DEPENDS: data/raw-private/qualtrics_api_key.txt
#CREATES: data/intermediate/wave4.csv
rm(list=ls())

library(tidyverse)
library(here)
source(here("src/lib/datacleaning.R"))

d4 = load_survey(survey_id="SV_3kfGN9GH4fAJ662") %>% 
  select(-I3_14_TEXT)

# Regular blocks
M = clean_meta(d4) %>% add_column(wave="wave 4", .after = 'iisID')
A = clean_A2(d4)
B = clean_B2(d4)
C = clean_C(d4)
F = clean_F(d4)
G = clean_G(d4)
I = clean_I(d4) 

## Political Background and Other Issues
E <- d4 %>%
  select(iisID, E2 = E1, E3_1 = E2_1, E3_2 = E2_2,
         E3_3 = E2_3, E3_4 = E2_4, E3_5 = E2_5,
         E3_6 = E2_6, E3_7 = E2_7, E3_8 = E2_8,
         E3_9 = E2_9, E3_10 = E2_10, E3_11 = E2_11,
         E3_12 = E2_12, E3_13 = E2_13, E3_14 = E2_14, 
         E3_15 = E2_15, E3_16 = E2_16, E3_17 = E2_17, 
        progress=Progress) %>%
  mutate(check = ifelse(duplicated(iisID) & progress <= 100, 1, 0)) %>%
  filter(check == 0) %>% 
  select(iisID, E2, E3_1:E3_17)

H <- d4 %>%
  select(iisID, H7)

# Merge and save data
df = M %>%
  left_join(A, by="iisID") %>%
  left_join(B, by="iisID") %>%
  left_join(C, by="iisID") %>%
  left_join(E, by="iisID") %>%
  left_join(F, by="iisID") %>%
  left_join(G, by="iisID") %>%
  left_join(H, by="iisID") %>%
  left_join(I, by="iisID") 

output_fn = here("data/intermediate/wave4.csv")
message("Writing output file", output_fn)
write_csv(df, output_fn)


