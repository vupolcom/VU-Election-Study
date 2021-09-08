#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Wave 4
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#CREATES: data/intermediate/waves_merged.csv
rm(list=ls())

library(tidyverse)
library(here)

d0 <- read_csv(here("data/intermediate/wave0.csv"))
BG <- d0 %>%
  select(iisID, gender:internet_use, E1:order_E1)
d1 <- read_csv(here("data/intermediate/wave1.csv")) %>%
  left_join(BG, by = "iisID")
d2 <- read_csv(here("data/intermediate/wave2.csv")) %>%
  left_join(BG, by = "iisID")
d3 <- read_csv(here("data/intermediate/wave3.csv")) %>%
  left_join(BG, by = "iisID")
d4 <- read_csv(here("data/intermediate/wave4.csv")) %>%
  left_join(BG, by = "iisID")

df <- bind_rows(d0, d1, d2, d3, d4)

output_fn = here("data/intermediate/waves_merged.csv")
message("Writing output file", output_fn)
write_csv(df, output_fn)


