#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Pre-Wave
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#DEPENDS: data/raw-private/qualtrics_api_key.txt
#CREATES: data/intermediate/VUElectionPanel2021_wave0.csv

library(tidyverse)
library(here)

source(here("src/lib/data.R"))

d0 = load_survey(survey_id="SV_39R4hSWxAJNBKHb")
M = clean_meta(d0) %>% add_column(wave="pre-wave", .after = 'iisID')
A = clean_A(d0)
B = clean_B(d0)
C = clean_C(d0)
F = clean_F(d0)
G = clean_G(d0)
I = clean_I(d0)

## Recode Block Background Variables
BG <- d0 %>%
  mutate(gender = recode(gender, `2` = 0),
         agegroup = case_when(
           is.na(age) ~ NA_real_,
           age <25 ~ 1,
           age <35 ~ 2,
           age <45 ~ 3,
           age <55 ~ 4,
           age <65 ~ 5,
           T ~ 6),
         education = ifelse(education == 8, 999, 8 - education),
         region = recode(region,
                         `1` = 1,
                         `5` = 2,
                         `8` = 3,
                         `9` = 4,
                         `10` = 5),
         postal_code = substr(postal_code, 1, 4),
         job = recode(job, 
                      `1` = 1,
                      `4` = 2,
                      `5` = 3,
                      `6` = 4,
                      `7` = 5,
                      `8` = 6,
                      `9` = 7,
                      `10` = 8),
         ethnicity = case_when(
           country_birth==1 & country_father==1 & country_mother==1 ~ 1,
           country_birth==1 & country_father %in% c(5,6,7,8,13) ~ 3,
           country_birth==1 & country_mother %in% c(5,6,7,8,13) ~ 3,
           country_birth==1 & country_father %in% c(4,9,10,11,12) ~ 5,
           country_birth==1 & country_mother %in% c(4,9,10,11,12) ~ 5,
           country_birth %in% c(4,9,10,11,12) ~ 4,
           country_birth %in% c(5,6,7,8,13) ~ 2,
           T ~ 999)
  ) %>%
  select(iisID, gender, 
         age, agegroup, education, region, ethnicity, 
         postal_code = postal_code_1_TEXT,
         job, internet_use)
  
# Recode Block D Political Knowledge
D <- d0 %>%
  select(iisID, D1_1, D1_2, D1_3, D1_4, 
         D1_timer_First.Click, D1_timer_Last.Click,
         D1_timer_Click.Count, D1_timer_Page.Submit,
         D2_1, D2_2, D2_3, D2_4, 
         D2_timer_First.Click, D2_timer_Last.Click,
         D2_timer_Click.Count, D2_timer_Page.Submit,
         D3_1, D3_2, D3_3, D3_4, 
         D3_timer_First.Click, D3_timer_Last.Click,
         D3_timer_Click.Count, D3_timer_Page.Submit, progress = Progress) %>%
  mutate(D1_1 = ifelse(D1_1 == 6, 1, 0),
         D1_2 = ifelse(D1_2 == 29,1, 0),
         D1_3 = ifelse(D1_3 == 7, 1, 0),
         D1_4 = ifelse(D1_4 == 28,1, 0),
         D1_sum = D1_1 + D1_2 + D1_3 + D1_4,
         D1_time = D1_timer_Last.Click - D1_timer_First.Click,
         D2_1 = ifelse(D2_1 == 1, 1, 0),
         D2_2 = ifelse(D2_2 == 5, 1, 0),
         D2_3 = ifelse(D2_3 == 14,1, 0),
         D2_4 = ifelse(D2_4 == 9, 1, 0),
         D2_sum = D2_1 + D2_2 + D2_3 + D2_4,
         D2_time = D2_timer_Last.Click - D2_timer_First.Click,
         D3_1 = ifelse(D3_1 == 7, 1, 0),
         D3_2 = ifelse(D3_2 == 10,1, 0),
         D3_3 = ifelse(D3_3 == 1, 1, 0),
         D3_4 = ifelse(D3_4 == 4, 1, 0),
         D3_sum = D3_1 + D3_2 + D3_3 + D3_4,
         D3_time = D3_timer_Last.Click - D3_timer_First.Click,
         D1 = D1_sum + D2_sum + D3_sum,
         D1_time_secs = D1_time + D2_time + D3_time,
         D1_clicks = D1_timer_Click.Count + D2_timer_Click.Count +
           D3_timer_Click.Count) %>%
  mutate(check = ifelse(duplicated(iisID) & progress <= 100, 1, 0)) %>%
  filter(check == 0) %>% 
  select(iisID, D1, D1_time_secs, D1_clicks) 

# Recode Block E Political Background
E <- d0 %>%
  select(iisID, E1, E1_otherparty = E1_16_TEXT, 
         E1_DO_1:E1_DO_19, E2, E3_1:E3_13, progress=Progress) %>%
  mutate(E1 = recode(E1,
                     `1` = 1, `4` = 2, `5` = 3, `6` = 4,
                     `7` = 5, `8` = 6, `9` = 7, `10` = 8,
                     `11` = 9, `12` = 10, `13` = 11, `14` = 12,
                     `15` = 13, `16` = 14, `17` = 997, `18` = 998,
                      `19` = 999),
         order_E1 = paste(E1_DO_1, E1_DO_4, E1_DO_5, E1_DO_6, 
                          E1_DO_7, E1_DO_8, E1_DO_9, E1_DO_10, 
                          E1_DO_11, E1_DO_12, E1_DO_13, E1_DO_14, 
                          E1_DO_15, E1_DO_16, E1_DO_17, E1_DO_18,
                          E1_DO_19, sep = "|")) %>%
  mutate(check = ifelse(duplicated(iisID) & progress <= 100, 1, 0)) %>%
  filter(check == 0) %>% 
  select(iisID, E1, E1_otherparty, order_E1, E2, E3_1:E3_13)

# Recode Block H Other Issues
H <- d0 %>%
  mutate(H4 = recode(H4, `8` = 999),
         order_H6 = paste(H6_DO_1,H6_DO_2,H6_DO_3, sep = "|"),
         H7 = recode(H7, `3` = 2, `4` = 3, `5` = 4))  %>%
  mutate(check = ifelse(duplicated(iisID) & Progress <= 100, 1, 0)) %>%
  filter(check == 0) %>% 
  select(iisID, H3:H6_3, order_H6, H7)

# Recode Block I News Consumption
I_trust <- d0 %>% unite(order_I8, I8_DO_1:I8_DO_15, sep="|") %>%
  select(iisID, I8_1, I8_2 = I8_4, I8_3 = I8_5,
         I8_4 = I8_6, I8_5 = I8_7, I8_6 = I8_8,
         I8_7 = I8_9, I8_8 = I8_10, I8_9 = I8_11,
         I8_10 = I8_12, I8_11 = I8_13, 
         I8_12 = I8_14, I8_13 = I8_15, order_I8,
         I9_1:I9_9) 

## Merge &amp; Save Data
df <- M %>% 
  inner_join(BG, by = "iisID") %>%
  inner_join(A, by = "iisID") %>%
  inner_join(B, by = "iisID") %>%
  inner_join(C, by = "iisID") %>%
  inner_join(D, by = "iisID") %>%
  inner_join(E, by = "iisID") %>%
  inner_join(F, by = "iisID") %>%
  inner_join(G, by = "iisID") %>%
  inner_join(H, by = "iisID") %>%
  inner_join(I, by = "iisID") %>%
  inner_join(I_trust, by = "iisID")

output_fn = here("data/intermediate/wave0.csv")
message("Writing output file", output_fn)
write_csv(df, output_fn)

