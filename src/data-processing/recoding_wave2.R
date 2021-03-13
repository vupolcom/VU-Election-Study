#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Pre-Wave
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#DEPENDS: data/raw-private/qualtrics_api_key.txt
#CREATES: data/intermediate/wave2.csv


library(tidyverse)
library(here)
source(here("src/lib/data.R"))
d2 = load_survey(survey_id="SV_byf8IHLmuTHe00l")

# Regular blocks
M = clean_meta(d2) %>% add_column(wave="wave 2", .after = 'iisID')
A = clean_A(d2)
B = clean_B(d2)
I = clean_I(d2)

# Other issues
H <- d2 %>%
  select(iisID, H_deJonge_1:H7) %>%
  mutate(H7 = recode(H7, `3` = 2, `4` = 3, `5` = 4),
         order_H5 = paste(H5_DO_1, H5_DO_2, H5_DO_3, H5_DO_4, 
                          H5_DO_5,  sep = "|")) %>%
  select(iisID:H5_5, order_H5, H_corona_1:H7)

df = M %>%
  left_join(A, by="iisID") %>%
  left_join(B, by="iisID") %>%
  left_join(H, by="iisID") %>%
  left_join(I, by="iisID") 

# TODO: other issues
output_fn = here("data/intermediate/wave2.csv")
message("Writing output file", output_fn)
write_csv(df, output_fn)

