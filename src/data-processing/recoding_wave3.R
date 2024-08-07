#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Pre-Wave
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#DEPENDS: data/raw-private/qualtrics_api_key.txt
#CREATES: data/intermediate/VUElectionPanel2021_wave3.csv

rm(list=ls())
library(tidyverse)
library(here)
source(here("src/lib/datacleaning.R"))

d3 = load_survey(survey_id="SV_a92jPqJ9B5EQMSx") %>% select(-I3_14_TEXT)

# Regular blocks
M = clean_meta(d3) %>% add_column(wave="wave 3", .after = 'iisID')
A = clean_A(d3)
B = clean_B2(d3)
I = clean_I(d3) 

# Other issues
H <- d3 %>%
  select(iisID, H7:H11_5_6)

#Merge and save
df = M %>%
  left_join(A, by="iisID") %>%
  left_join(B, by="iisID") %>%
  left_join(H, by="iisID") %>%
  left_join(I, by="iisID") 

output_fn = here("data/intermediate/wave3.csv")
message("Writing output file", output_fn)
write_csv(df, output_fn)
