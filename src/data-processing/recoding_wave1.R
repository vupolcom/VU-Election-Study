#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Wave 1
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#DEPENDS: data/raw-private/qualtrics_api_key.txt
#CREATES: data/intermediate/wave1.csv

d1 = load_survey(survey_id="SV_1X34g6PWhWjj6hD")

# Regular blocks
M = clean_meta(d1) %>% add_column(wave="wave 1", .after = 'iisID')
A = clean_A(d1)
B = clean_B(d1)
I = clean_I(d1)

# Other issues
H <- d1 %>%
  select(iisID, H1, H2, H7, H7a, H7b:H10) %>%
  mutate(H7 = recode(H7, `3` = 2, `4` = 3, `5` = 4)) 

df = M %>%
  left_join(A, by="iisID") %>%
  left_join(B, by="iisID") %>%
  left_join(H, by="iisID") %>%
  left_join(I, by="iisID") 

# TODO: other issues
write_csv(df, here("data/intermediate/wave1.csv"))
