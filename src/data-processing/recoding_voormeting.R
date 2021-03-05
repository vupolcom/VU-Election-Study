#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Pre-Wave
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#DEPENDS: data/raw-private/qualtrics_raw_wave0.csv
#CREATES: data/intermediate/VUElectionPanel2021_wave0.csv

## Required Packages &amp; Reproducibility
rm(list = ls())

library(tidyverse)
library(sjlabelled)
library(here)
library(qualtRics)

#input_fn = here("data/raw-private/qualtrics_raw_wave0.csv")
output_fn = here("data/intermediate/VUElectionPanel2021_wave0.csv")

## Load Data
# Load the data downloaded from Qualtrics, and only keep those that have given consent to participate in the panel study.
#col_names <- names(read_csv(input_fn, n_max = 0))
#d <- read_csv(input_fn, col_names = col_names, skip = 3) %>%
#  remove_all_labels() %>% 
#  tibble() %>%
  #only keep people that have given consent
#  filter(consent1==1 & consent2==1) 
#rm(input_fn, col_names)

input_fn <- fetch_survey(surveyID = "SV_39R4hSWxAJNBKHb", 
                         verbose = TRUE, force_request = T,
                         label = FALSE, convert = FALSE)
d <- input_fn %>%
  remove_all_labels() %>% 
  tibble() %>%
  #only keep people that have given consent
  filter(consent1==1 & consent2==1) 
rm(input_fn)
## Recode Block Background Variables
BG <- d %>%
  mutate(gender = recode(gender, `2` = 0),
         age = ifelse(age <25, 1,
               ifelse(age >24 & age <35, 2,
               ifelse(age >34 & age <45, 3,
               ifelse(age >44 & age <55, 4,
               ifelse(age >54 & age <65, 5,
               ifelse(age >64, 6, 999)))))),
         education = recode(education, 
                            `1` = 1, 
                            `2` = 1,
                            `3` = 2,
                            `4` = 2,
                            `5` = 3,
                            `6` = 3,
                            `7` = 3,
                            `8` = 999),
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
         wave = "pre-wave",
         start_date = StartDate,
         end_date = EndDate,
         duration_min = round(Duration..in.seconds./60,2),
         ethnicity = ifelse(country_birth==1 & country_father==1 & 
                             country_mother==1, 1,
                    ifelse(country_birth==1 & country_father== 5, 3,
                    ifelse(country_birth==1 & country_father== 6, 3,
                    ifelse(country_birth==1 & country_father== 7, 3,
                    ifelse(country_birth==1 & country_father== 8, 3,
                    ifelse(country_birth==1 & country_father== 13, 3,
                    ifelse(country_birth==1 & country_mother== 5, 3,
                    ifelse(country_birth==1 & country_mother== 6, 3,
                    ifelse(country_birth==1 & country_mother== 7, 3,
                    ifelse(country_birth==1 & country_mother== 8, 3,
                    ifelse(country_birth==1 & country_mother== 13, 3,
                    ifelse(country_birth==1 & country_father== 4, 5,
                    ifelse(country_birth==1 & country_father== 9, 5,
                    ifelse(country_birth==1 & country_father== 10, 5,
                    ifelse(country_birth==1 & country_father== 11, 5,
                    ifelse(country_birth==1 & country_father== 12, 5,
                    ifelse(country_birth==1 & country_mother== 4, 5,
                    ifelse(country_birth==1 & country_mother== 9, 5,
                    ifelse(country_birth==1 & country_mother== 10, 5,
                    ifelse(country_birth==1 & country_mother== 11, 5,
                    ifelse(country_birth==1 & country_mother== 12, 5,
                    ifelse(country_birth==4, 4,
                    ifelse(country_birth==9, 4,
                    ifelse(country_birth==10, 4,
                    ifelse(country_birth==11, 4,
                    ifelse(country_birth==12, 4,
                    ifelse(country_birth==5, 2,
                    ifelse(country_birth==6, 2,
                    ifelse(country_birth==7, 2,
                    ifelse(country_birth==8, 2,
                    ifelse(country_birth==13, 2,
                           999)))))))))))))))))))))))))))))))) %>%
  select(wave,start_date, end_date, duration_min, progress = Progress, iisID, gender, 
         age, education,region, ethnicity, 
         postal_code = postal_code_1_TEXT,
         job, internet_use)

## Recode Block A Voting Behavior
A <- d %>%
  select(iisID, A1:A2, A2_otherparty = A2_14_TEXT,
         A2_DO_1:A2_DO_13, A3_DO_1:A3_DO_13) %>%
  mutate(A1 = recode(A1,
                     `2` = 0,
                     `3` = 998,
                     `4` = 999),
         A2 = recode(A2,
                     `16` = 999),
         order_A2 = paste(A2_DO_1, A2_DO_2, A2_DO_3, A2_DO_4,
                          A2_DO_5, A2_DO_6, A2_DO_7, A2_DO_8,
                          A2_DO_9, A2_DO_10, A2_DO_11, 
                          A2_DO_12, A2_DO_13, sep = "|"),
         order_A3 = paste(A3_DO_1, A3_DO_2, A3_DO_3, A3_DO_4,
                          A3_DO_5, A3_DO_6, A3_DO_7, A3_DO_8,
                          A3_DO_9, A3_DO_10, A3_DO_11, 
                          A3_DO_12, A3_DO_13, sep = "|"))
  
A3 <- d %>%
  select(iisID, A3_1:A3_13) %>%
  pivot_longer(cols = A3_1:A3_13,
               names_to = "variable") %>%
  drop_na(value) %>%
  separate(variable, c("variable", "party"), "_", extra = "merge")  %>%
  group_by(iisID) %>%
  summarise(n = row_number(),
            party = party) %>%
  ungroup() %>%
  mutate(n = paste("A3", n, sep="_"),
         n = factor(n),
         party = as.integer(party))

A3 <-  pivot_wider(A3, names_from = n, values_from = party, 
                    values_fill = 0) %>%
  mutate(A3 = paste(A3_1, A3_2, A3_3, A3_4, A3_5,
                    A3_6, A3_7, A3_8, A3_9, A3_10, 
                    A3_11, A3_12, A3_13, sep = "|"))
A <- left_join(A, A3, by = "iisID") %>%
  select(iisID, A1:A2_otherparty, order_A2, A3, order_A3, A3_1:A3_13)
rm(A3)

## Recode Block B Performance Politics in the Media
d <-d %>%
  mutate(B2_1 = recode(B2_1,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_2 = recode(B2_2,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_3 = recode(B2_3,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_4 = recode(B2_4,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_5 = recode(B2_5,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_6 = recode(B2_6,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_7 = recode(B2_7,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_8 = recode(B2_8,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_9 = recode(B2_9,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_10 = recode(B2_10,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_11 = recode(B2_11,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_12 = recode(B2_12,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       B2_13 = recode(B2_13,`1` = 999, `2` = 1, `24` = 2,`25` = 3),
       order_B2 = paste(B2_DO_1, B2_DO_2, B2_DO_3, B2_DO_4, 
                          B2_DO_5, B2_DO_6, B2_DO_7, B2_DO_8, 
                          B2_DO_9, B2_DO_10, B2_DO_11, B2_DO_12, 
                          B2_DO_13, sep = "|"))

B3 <- d %>%
  select(iisID, X1_B3_3, X2_B3_3, X3_B3_3, X4_B3_3, X5_B3_3,
         X6_B3_3, X7_B3_3, X8_B3_3, X9_B3_3, X10_B3_3,
         X11_B3_3, X12_B3_3, X13_B3_3,
         X1_B3_4, X2_B3_4, X3_B3_4, X4_B3_4, X5_B3_4,
         X6_B3_4, X7_B3_4, X8_B3_4, X9_B3_4, X10_B3_4,
         X11_B3_4, X12_B3_4, X13_B3_4) %>%
  pivot_longer(cols = X1_B3_3:X13_B3_4,
               names_to = "variable") %>%
  separate(variable, c("variable", "question"), "_", extra = "merge")  %>%
  group_by(variable) %>%
  mutate(row = row_number()) %>%
  pivot_wider(names_from = question, values_from = value) %>%
  unite("B3", B3_3:B3_4, remove = T, na.rm = T) %>%
  mutate(B3 = ifelse(B3 == "", "999", B3),
         B3 = as.numeric(B3)) 
  
B3 <- B3 %>%
  group_by(variable) %>%
  mutate(row = row_number()) %>%
  pivot_wider(names_from = variable, values_from = B3) %>%
  select(iisID, B3_1 = X1,
         B3_2 = X1, B3_3 = X3, B3_4 = X4, B3_5 = X5,
         B3_6 = X6, B3_7 = X7, B3_8 = X1, B3_9 = X9,
         B3_10 = X10, B3_11 = X11, B3_12 = X12, B3_13 = X13) 

B <- d %>%
  select(iisID, B1, B2_1:B2_13, order_B2)
B <- left_join(B, B3, by = "iisID")
rm(B3)

## Recode Block C Issue Association
C1_1 <- d %>%
  select(iisID, X1_C1_1_2,
         X2_C1_1_2, X3_C1_1_2, X4_C1_1_2, X5_C1_1_2,
         X6_C1_1_2, X7_C1_1_2, X8_C1_1_2, X9_C1_1_2,
         X10_C1_1_2,X11_C1_1_2, X12_C1_1_2, X13_C1_1_2,
         X1_C1_1_3,
         X2_C1_1_3, X3_C1_1_3, X4_C1_1_3, X5_C1_1_3,
         X6_C1_1_3, X7_C1_1_3, X8_C1_1_3, X9_C1_1_3,
         X10_C1_1_3,X11_C1_1_3, X12_C1_1_3, X13_C1_1_3,
         X1_C1_1_4,
         X2_C1_1_4, X3_C1_1_4, X4_C1_1_4, X5_C1_1_4,
         X6_C1_1_4, X7_C1_1_4, X8_C1_1_4, X9_C1_1_4,
         X10_C1_1_4,X11_C1_1_4, X12_C1_1_4, X13_C1_1_4) %>%
  unite("C1_1_1", c(X1_C1_1_2, X1_C1_1_3, X1_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_2", c(X2_C1_1_2, X2_C1_1_3, X2_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_3", c(X3_C1_1_2, X3_C1_1_3, X3_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_4", c(X4_C1_1_2, X4_C1_1_3, X4_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_5", c(X5_C1_1_2, X5_C1_1_3, X5_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_6", c(X6_C1_1_2, X6_C1_1_3, X6_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_7", c(X7_C1_1_2, X7_C1_1_3, X7_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_8", c(X8_C1_1_2, X8_C1_1_3, X8_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_9", c(X9_C1_1_2, X9_C1_1_3, X9_C1_1_4),remove = T, na.rm = T) %>%
  unite("C1_1_10", c(X10_C1_1_2, X10_C1_1_3, X10_C1_1_4),remove = T, 
        na.rm = T) %>%
  unite("C1_1_11", c(X11_C1_1_2, X11_C1_1_3, X11_C1_1_4),remove = T, 
        na.rm = T) %>%
  unite("C1_1_12", c(X12_C1_1_2, X12_C1_1_3, X12_C1_1_4),remove = T, 
        na.rm = T) %>%
  unite("C1_1_13", c(X13_C1_1_2, X13_C1_1_3, X13_C1_1_4),remove = T, 
        na.rm = T) %>%
  mutate(C1_1_1 = recode(C1_1_1,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_2 = recode(C1_1_2,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_3 = recode(C1_1_3,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_4 = recode(C1_1_4,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_5 = recode(C1_1_5,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_6 = recode(C1_1_6,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_7 = recode(C1_1_7,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_8 = recode(C1_1_8,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_9 = recode(C1_1_9,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_10 = recode(C1_1_10,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_11 = recode(C1_1_11,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_12 = recode(C1_1_12,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_1_13 = recode(C1_1_13,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20))

C1_1_txt <- d %>%
  select(X1_C1_1_2_38_TEXT, X2_C1_1_2_38_TEXT, X3_C1_1_2_38_TEXT,
         X4_C1_1_2_38_TEXT, X5_C1_1_2_38_TEXT, X6_C1_1_2_38_TEXT,
         X7_C1_1_2_38_TEXT, X8_C1_1_2_38_TEXT, X9_C1_1_2_38_TEXT,
         X10_C1_1_2_38_TEXT, X11_C1_1_2_38_TEXT, X12_C1_1_2_38_TEXT,
         X13_C1_1_2_38_TEXT,
         X1_C1_1_3_38_TEXT, X2_C1_1_3_38_TEXT, X3_C1_1_3_38_TEXT,
         X4_C1_1_3_38_TEXT, X5_C1_1_3_38_TEXT, X6_C1_1_3_38_TEXT,
         X7_C1_1_3_38_TEXT, X8_C1_1_3_38_TEXT, X9_C1_1_3_38_TEXT,
         X10_C1_1_3_38_TEXT, X11_C1_1_3_38_TEXT, X12_C1_1_3_38_TEXT,
         X13_C1_1_3_38_TEXT,
         X1_C1_1_4_38_TEXT, X2_C1_1_4_38_TEXT, X3_C1_1_4_38_TEXT,
         X4_C1_1_4_38_TEXT, X5_C1_1_4_38_TEXT, X6_C1_1_4_38_TEXT,
         X7_C1_1_4_38_TEXT, X8_C1_1_4_38_TEXT, X9_C1_1_4_38_TEXT,
         X10_C1_1_4_38_TEXT, X11_C1_1_4_38_TEXT, X12_C1_1_4_38_TEXT,
         X13_C1_1_4_38_TEXT, iisID) %>%
  unite("C1_1_1_text", c(X1_C1_1_2_38_TEXT, X1_C1_1_3_38_TEXT,
                         X1_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_2_text", c(X2_C1_1_2_38_TEXT, X2_C1_1_3_38_TEXT,
                         X2_C1_1_4_38_TEXT),remove = T, na.rm = T) %>% 
  unite("C1_1_3_text", c(X3_C1_1_2_38_TEXT, X3_C1_1_3_38_TEXT,
                         X3_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_4_text", c(X4_C1_1_2_38_TEXT, X4_C1_1_3_38_TEXT,
                         X4_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_5_text", c(X5_C1_1_2_38_TEXT, X5_C1_1_3_38_TEXT,
                         X5_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_6_text", c(X6_C1_1_2_38_TEXT, X6_C1_1_3_38_TEXT,
                         X6_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_7_text", c(X7_C1_1_2_38_TEXT, X7_C1_1_3_38_TEXT,
                         X7_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_8_text", c(X8_C1_1_2_38_TEXT, X8_C1_1_3_38_TEXT,
                         X8_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_9_text", c(X9_C1_1_2_38_TEXT, X9_C1_1_3_38_TEXT,
                         X9_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_10_text", c(X10_C1_1_2_38_TEXT, X10_C1_1_3_38_TEXT,
                         X10_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_11_text", c(X11_C1_1_2_38_TEXT, X11_C1_1_3_38_TEXT,
                         X11_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_12_text", c(X12_C1_1_2_38_TEXT, X12_C1_1_3_38_TEXT,
                         X12_C1_1_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_1_13_text", c(X13_C1_1_2_38_TEXT, X13_C1_1_3_38_TEXT,
                         X13_C1_1_4_38_TEXT),remove = T, na.rm = T)

C1_2 <- d %>%
  select(iisID, X1_C1_2_2,
         X2_C1_2_2, X3_C1_2_2, X4_C1_2_2, X5_C1_2_2,
         X6_C1_2_2, X7_C1_2_2, X8_C1_2_2, X9_C1_2_2,
         X10_C1_2_2,X11_C1_2_2, X12_C1_2_2, X13_C1_2_2,
         X1_C1_2_3,
         X2_C1_2_3, X3_C1_2_3, X4_C1_2_3, X5_C1_2_3,
         X6_C1_2_3, X7_C1_2_3, X8_C1_2_3, X9_C1_2_3,
         X10_C1_2_3,X11_C1_2_3, X12_C1_2_3, X13_C1_2_3,
         X1_C1_2_4,
         X2_C1_2_4, X3_C1_2_4, X4_C1_2_4, X5_C1_2_4,
         X6_C1_2_4, X7_C1_2_4, X8_C1_2_4, X9_C1_2_4,
         X10_C1_2_4,X11_C1_2_4, X12_C1_2_4, X13_C1_2_4) %>%
  unite("C1_2_1", c(X1_C1_2_2, X1_C1_2_3, X1_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_2", c(X2_C1_2_2, X2_C1_2_3, X2_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_3", c(X3_C1_2_2, X3_C1_2_3, X3_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_4", c(X4_C1_2_2, X4_C1_2_3, X4_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_5", c(X5_C1_2_2, X5_C1_2_3, X5_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_6", c(X6_C1_2_2, X6_C1_2_3, X6_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_7", c(X7_C1_2_2, X7_C1_2_3, X7_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_8", c(X8_C1_2_2, X8_C1_2_3, X8_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_9", c(X9_C1_2_2, X9_C1_2_3, X9_C1_2_4),remove = T, na.rm = T) %>%
  unite("C1_2_10", c(X10_C1_2_2, X10_C1_2_3, X10_C1_2_4),remove = T, 
        na.rm = T) %>%
  unite("C1_2_11", c(X11_C1_2_2, X11_C1_2_3, X11_C1_2_4),remove = T, 
        na.rm = T) %>%
  unite("C1_2_12", c(X12_C1_2_2, X12_C1_2_3, X12_C1_2_4),remove = T, 
        na.rm = T) %>%
  unite("C1_2_13", c(X13_C1_2_2, X13_C1_2_3, X13_C1_2_4),remove = T, 
        na.rm = T) %>%
  mutate(C1_2_1 = recode(C1_2_1,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_2 = recode(C1_2_2,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_3 = recode(C1_2_3,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_4 = recode(C1_2_4,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_5 = recode(C1_2_5,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_6 = recode(C1_2_6,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_7 = recode(C1_2_7,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_8 = recode(C1_2_8,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_9 = recode(C1_2_9,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_10 = recode(C1_2_10,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_11 = recode(C1_2_11,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_12 = recode(C1_2_12,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20),
         C1_2_13 = recode(C1_2_13,
                       `20` = 1,`21` = 2, `22` = 3, `23` = 4,
                       `24` = 5,`25` = 6, `26` = 7, `27` = 8,
                       `28` = 9,`29` = 10, `30` = 11, `31` = 12,
                       `32` = 13,`33` = 14, `34` = 15, `35` = 16,
                       `36` = 17,`37` = 18, `38` = 19, `40` = 20))

C1_2_txt <- d %>%
  select(X1_C1_2_2_38_TEXT, X2_C1_2_2_38_TEXT, X3_C1_2_2_38_TEXT,
         X4_C1_2_2_38_TEXT, X5_C1_2_2_38_TEXT, X6_C1_2_2_38_TEXT,
         X7_C1_2_2_38_TEXT, X8_C1_2_2_38_TEXT, X9_C1_2_2_38_TEXT,
         X10_C1_2_2_38_TEXT, X11_C1_2_2_38_TEXT, X12_C1_2_2_38_TEXT,
         X13_C1_2_2_38_TEXT,
         X1_C1_2_3_38_TEXT, X2_C1_2_3_38_TEXT, X3_C1_2_3_38_TEXT,
         X4_C1_2_3_38_TEXT, X5_C1_2_3_38_TEXT, X6_C1_2_3_38_TEXT,
         X7_C1_2_3_38_TEXT, X8_C1_2_3_38_TEXT, X9_C1_2_3_38_TEXT,
         X10_C1_2_3_38_TEXT, X11_C1_2_3_38_TEXT, X12_C1_2_3_38_TEXT,
         X13_C1_2_3_38_TEXT,
         X1_C1_2_4_38_TEXT, X2_C1_2_4_38_TEXT, X3_C1_2_4_38_TEXT,
         X4_C1_2_4_38_TEXT, X5_C1_2_4_38_TEXT, X6_C1_2_4_38_TEXT,
         X7_C1_2_4_38_TEXT, X8_C1_2_4_38_TEXT, X9_C1_2_4_38_TEXT,
         X10_C1_2_4_38_TEXT, X11_C1_2_4_38_TEXT, X12_C1_2_4_38_TEXT,
         X13_C1_2_4_38_TEXT, iisID) %>%
  unite("C1_2_1_text", c(X1_C1_2_2_38_TEXT, X1_C1_2_3_38_TEXT,
                         X1_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_2_text", c(X2_C1_2_2_38_TEXT, X2_C1_2_3_38_TEXT,
                         X2_C1_2_4_38_TEXT),remove = T, na.rm = T) %>% 
  unite("C1_2_3_text", c(X3_C1_2_2_38_TEXT, X3_C1_2_3_38_TEXT,
                         X3_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_4_text", c(X4_C1_2_2_38_TEXT, X4_C1_2_3_38_TEXT,
                         X4_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_5_text", c(X5_C1_2_2_38_TEXT, X5_C1_2_3_38_TEXT,
                         X5_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_6_text", c(X6_C1_2_2_38_TEXT, X6_C1_2_3_38_TEXT,
                         X6_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_7_text", c(X7_C1_2_2_38_TEXT, X7_C1_2_3_38_TEXT,
                         X7_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_8_text", c(X8_C1_2_2_38_TEXT, X8_C1_2_3_38_TEXT,
                         X8_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_9_text", c(X9_C1_2_2_38_TEXT, X9_C1_2_3_38_TEXT,
                         X9_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_10_text", c(X10_C1_2_2_38_TEXT, X10_C1_2_3_38_TEXT,
                         X10_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_11_text", c(X11_C1_2_2_38_TEXT, X11_C1_2_3_38_TEXT,
                         X11_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_12_text", c(X12_C1_2_2_38_TEXT, X12_C1_2_3_38_TEXT,
                         X12_C1_2_4_38_TEXT),remove = T, na.rm = T) %>%
  unite("C1_2_13_text", c(X13_C1_2_2_38_TEXT, X13_C1_2_3_38_TEXT,
                         X13_C1_2_4_38_TEXT),remove = T, na.rm = T)

C2_1 <- d %>%
  select(iisID, X1_C2_1_2,
         X2_C2_1_2, X3_C2_1_2, X4_C2_1_2, X5_C2_1_2,
         X6_C2_1_2, X7_C2_1_2, X8_C2_1_2, X9_C2_1_2,
         X10_C2_1_2,X11_C2_1_2, X12_C2_1_2, X13_C2_1_2,
         X1_C2_1_3,
         X2_C2_1_3, X3_C2_1_3, X4_C2_1_3, X5_C2_1_3,
         X6_C2_1_3, X7_C2_1_3, X8_C2_1_3, X9_C2_1_3,
         X10_C2_1_3,X11_C2_1_3, X12_C2_1_3, X13_C2_1_3,
         X1_C2_1_4,
         X2_C2_1_4, X3_C2_1_4, X4_C2_1_4, X5_C2_1_4,
         X6_C2_1_4, X7_C2_1_4, X8_C2_1_4, X9_C2_1_4,
         X10_C2_1_4,X11_C2_1_4, X12_C2_1_4, X13_C2_1_4) %>%
  unite("C2_1_1", c(X1_C2_1_2, X1_C2_1_3, X1_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_2", c(X2_C2_1_2, X2_C2_1_3, X2_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_3", c(X3_C2_1_2, X3_C2_1_3, X3_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_4", c(X4_C2_1_2, X4_C2_1_3, X4_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_5", c(X5_C2_1_2, X5_C2_1_3, X5_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_6", c(X6_C2_1_2, X6_C2_1_3, X6_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_7", c(X7_C2_1_2, X7_C2_1_3, X7_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_8", c(X8_C2_1_2, X8_C2_1_3, X8_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_9", c(X9_C2_1_2, X9_C2_1_3, X9_C2_1_4),remove = T, na.rm = T) %>%
  unite("C2_1_10", c(X10_C2_1_2, X10_C2_1_3, X10_C2_1_4),remove = T, 
        na.rm = T) %>%
  unite("C2_1_11", c(X11_C2_1_2, X11_C2_1_3, X11_C2_1_4),remove = T, 
        na.rm = T) %>%
  unite("C2_1_12", c(X12_C2_1_2, X12_C2_1_3, X12_C2_1_4),remove = T, 
        na.rm = T) %>%
  unite("C2_1_13", c(X13_C2_1_2, X13_C2_1_3, X13_C2_1_4),remove = T, 
        na.rm = T) %>%
  mutate(C2_1_1 = ifelse(C2_1_1 == "", "999", C2_1_1),
         C2_1_1 = as.numeric(C2_1_1),
         C2_1_2 = ifelse(C2_1_2 == "", "999", C2_1_2),
         C2_1_2 = as.numeric(C2_1_2),
         C2_1_3 = ifelse(C2_1_3 == "", "999", C2_1_3),
         C2_1_3 = as.numeric(C2_1_3),
         C2_1_4 = ifelse(C2_1_4 == "", "999", C2_1_4),
         C2_1_4 = as.numeric(C2_1_4),
         C2_1_5 = ifelse(C2_1_5 == "", "999", C2_1_5),
         C2_1_5 = as.numeric(C2_1_5),
         C2_1_6 = ifelse(C2_1_6 == "", "999", C2_1_6),
         C2_1_6 = as.numeric(C2_1_6),
         C2_1_7 = ifelse(C2_1_7 == "", "999", C2_1_7),
         C2_1_7 = as.numeric(C2_1_7),
         C2_1_8 = ifelse(C2_1_8 == "", "999", C2_1_8),
         C2_1_8 = as.numeric(C2_1_8),
         C2_1_9 = ifelse(C2_1_9 == "", "999", C2_1_9),
         C2_1_9 = as.numeric(C2_1_9),
         C2_1_10 = ifelse(C2_1_10 == "", "999", C2_1_10),
         C2_1_10 = as.numeric(C2_1_10),
         C2_1_11 = ifelse(C2_1_11 == "", "999", C2_1_11),
         C2_1_11 = as.numeric(C2_1_11),
         C2_1_12 = ifelse(C2_1_12 == "", "999", C2_1_12),
         C2_1_12 = as.numeric(C2_1_12),
         C2_1_13 = ifelse(C2_1_13 == "", "999", C2_1_13),
         C2_1_13 = as.numeric(C2_1_13))

C2_2 <- d %>%
  select(iisID, X1_C2_2_2,
         X2_C2_2_2, X3_C2_2_2, X4_C2_2_2, X5_C2_2_2,
         X6_C2_2_2, X7_C2_2_2, X8_C2_2_2, X9_C2_2_2,
         X10_C2_2_2,X11_C2_2_2, X12_C2_2_2, X13_C2_2_2,
         X1_C2_2_3,
         X2_C2_2_3, X3_C2_2_3, X4_C2_2_3, X5_C2_2_3,
         X6_C2_2_3, X7_C2_2_3, X8_C2_2_3, X9_C2_2_3,
         X10_C2_2_3,X11_C2_2_3, X12_C2_2_3, X13_C2_2_3,
         X1_C2_2_4,
         X2_C2_2_4, X3_C2_2_4, X4_C2_2_4, X5_C2_2_4,
         X6_C2_2_4, X7_C2_2_4, X8_C2_2_4, X9_C2_2_4,
         X10_C2_2_4,X11_C2_2_4, X12_C2_2_4, X13_C2_2_4) %>%
  unite("C2_2_1", c(X1_C2_2_2, X1_C2_2_3, X1_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_2", c(X2_C2_2_2, X2_C2_2_3, X2_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_3", c(X3_C2_2_2, X3_C2_2_3, X3_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_4", c(X4_C2_2_2, X4_C2_2_3, X4_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_5", c(X5_C2_2_2, X5_C2_2_3, X5_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_6", c(X6_C2_2_2, X6_C2_2_3, X6_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_7", c(X7_C2_2_2, X7_C2_2_3, X7_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_8", c(X8_C2_2_2, X8_C2_2_3, X8_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_9", c(X9_C2_2_2, X9_C2_2_3, X9_C2_2_4),remove = T, na.rm = T) %>%
  unite("C2_2_10", c(X10_C2_2_2, X10_C2_2_3, X10_C2_2_4),remove = T, 
        na.rm = T) %>%
  unite("C2_2_11", c(X11_C2_2_2, X11_C2_2_3, X11_C2_2_4),remove = T, 
        na.rm = T) %>%
  unite("C2_2_12", c(X12_C2_2_2, X12_C2_2_3, X12_C2_2_4),remove = T, 
        na.rm = T) %>%
  unite("C2_2_13", c(X13_C2_2_2, X13_C2_2_3, X13_C2_2_4),remove = T, 
        na.rm = T) %>%
  mutate(C2_2_1 = ifelse(C2_2_1 == "", "999", C2_2_1),
         C2_2_1 = as.numeric(C2_2_1),
         C2_2_2 = ifelse(C2_2_2 == "", "999", C2_2_2),
         C2_2_2 = as.numeric(C2_2_2),
         C2_2_3 = ifelse(C2_2_3 == "", "999", C2_2_3),
         C2_2_3 = as.numeric(C2_2_3),
         C2_2_4 = ifelse(C2_2_4 == "", "999", C2_2_4),
         C2_2_4 = as.numeric(C2_2_4),
         C2_2_5 = ifelse(C2_2_5 == "", "999", C2_2_5),
         C2_2_5 = as.numeric(C2_2_5),
         C2_2_6 = ifelse(C2_2_6 == "", "999", C2_2_6),
         C2_2_6 = as.numeric(C2_2_6),
         C2_2_7 = ifelse(C2_2_7 == "", "999", C2_2_7),
         C2_2_7 = as.numeric(C2_2_7),
         C2_2_8 = ifelse(C2_2_8 == "", "999", C2_2_8),
         C2_2_8 = as.numeric(C2_2_8),
         C2_2_9 = ifelse(C2_2_9 == "", "999", C2_2_9),
         C2_2_9 = as.numeric(C2_2_9),
         C2_2_10 = ifelse(C2_2_10 == "", "999", C2_2_10),
         C2_2_10 = as.numeric(C2_2_10),
         C2_2_11 = ifelse(C2_2_11 == "", "999", C2_2_11),
         C2_2_11 = as.numeric(C2_2_11),
         C2_2_12 = ifelse(C2_2_12 == "", "999", C2_2_12),
         C2_2_12 = as.numeric(C2_2_12),
         C2_2_13 = ifelse(C2_2_13 == "", "999", C2_2_13),
         C2_2_13 = as.numeric(C2_2_13))

C <- left_join(C1_1, C1_1_txt, by = "iisID")
C <- left_join(C, C1_2, by = "iisID")
C <- left_join(C, C1_2_txt, by = "iisID")
C <- left_join(C, C2_1, by = "iisID")
C <- left_join(C, C2_2, by = "iisID") %>%
  distinct(iisID, .keep_all = T)
rm(C1_1, C1_1_txt, C1_2, C1_2_txt, C2_1, C2_2)

# Recode Block D Political Knowledge
D <- d %>%
  select(iisID, D1_1, D1_2, D1_3, D1_4, 
         D1_timer_First.Click, D1_timer_Last.Click,
         D1_timer_Click.Count, D1_timer_Page.Submit,
         D2_1, D2_2, D2_3, D2_4, 
         D2_timer_First.Click, D2_timer_Last.Click,
         D2_timer_Click.Count, D2_timer_Page.Submit,
         D3_1, D3_2, D3_3, D3_4, 
         D3_timer_First.Click, D3_timer_Last.Click,
         D3_timer_Click.Count, D3_timer_Page.Submit) %>%
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
  select(iisID, D1, D1_time_secs, D1_clicks)

# Recode Block E Political Background
E <- d %>%
  select(iisID, E1, E1_otherparty = E1_16_TEXT, 
         E1_DO_1:E1_DO_19, E2, E3_1:E3_13) %>%
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
  select(iisID, E1, E1_otherparty, order_E1, E2, E3_1:E3_13)

# Recode Block F Trust
F <- d %>%
  mutate(order_F1 = paste(F1_DO_1, F1_DO_2, F1_DO_3, F1_DO_4,
                          F1_DO_5, F1_DO_6, F1_DO_7, F1_DO_8,
                          F1_DO_9, F1_DO_10, sep ="|"),
         order_F2 = paste(F2_DO_1, F2_DO_2, F2_DO_3, F2_DO_4,
                          F2_DO_5, F2_DO_6, F2_DO_7, F2_DO_8,
                          F2_DO_9, F2_DO_10, F2_DO_15, sep = "|")) %>%
  select(iisID, F1_1:F1_10, order_F1,
         F2_1:F2_10, F2_11 = F2_15, order_F2)

# Recode Block G Evaluation of Government and Political Leaders
G <- d %>%
  select(iisID, G1_1:G1_5, G1_b, G_eval_leaders_1:G_eval_leaders_14,
         G2_DO_4:G2_DO_17,
         G2_1 = G2_4, G2_2 = G2_5, G2_3 = G2_6,
         G2_4 = G2_7, G2_5 = G2_8, G2_6 = G2_9,
         G2_7 = G2_10, G2_8 = G2_11, G2_9 = G2_12,
         G2_10 = G2_13, G2_11 = G2_14, G2_12 = G2_15,
         G2_13 = G2_16, G2_14 = G2_17,
         G3_1 = G3_4, G3_2 = G3_5, G3_3 = G3_6,
         G3_4 = G3_7, G3_5 = G3_8, G3_6 = G3_9,
         G3_7 = G3_10, G3_8 = G3_11, G3_9 = G3_12,
         G3_10 = G3_13, G3_11 = G3_14, G3_12 = G3_15,
         G3_13 = G3_16, G3_14 = G3_17,
         G4_1 = G4_4, G4_2 = G4_5, G4_3 = G4_6,
         G4_4 = G4_7, G4_5 = G4_8, G4_6 = G4_9,
         G4_7 = G4_10, G4_8 = G4_11, G4_9 = G4_12,
         G4_10 = G4_13, G4_11 = G4_14, G4_12 = G4_15,
         G4_13 = G4_16, G4_14 = G4_17) %>%
  mutate(G_eval_leaders_1 = recode(G_eval_leaders_1, `1` = 1, `4` = 0),
         G_eval_leaders_2 = recode(G_eval_leaders_2, `1` = 1, `4` = 0),
         G_eval_leaders_3 = recode(G_eval_leaders_3, `1` = 1, `4` = 0),
         G_eval_leaders_4 = recode(G_eval_leaders_4, `1` = 1, `4` = 0),
         G_eval_leaders_5 = recode(G_eval_leaders_5, `1` = 1, `4` = 0),
         G_eval_leaders_6 = recode(G_eval_leaders_6, `1` = 1, `4` = 0),
         G_eval_leaders_7 = recode(G_eval_leaders_7, `1` = 1, `4` = 0),
         G_eval_leaders_8 = recode(G_eval_leaders_8, `1` = 1, `4` = 0),
         G_eval_leaders_9 = recode(G_eval_leaders_9, `1` = 1, `4` = 0),
         G_eval_leaders_10 = recode(G_eval_leaders_10, `1` = 1, `4` = 0),
         G_eval_leaders_11 = recode(G_eval_leaders_11, `1` = 1, `4` = 0),
         G_eval_leaders_12 = recode(G_eval_leaders_12, `1` = 1, `4` = 0),
         G_eval_leaders_13 = recode(G_eval_leaders_13, `1` = 1, `4` = 0),
         G_eval_leaders_14 = recode(G_eval_leaders_14, `1` = 1, `4` = 0),
         order_G2 = paste(G2_DO_4, G2_DO_5, G2_DO_6, G2_DO_7,
                          G2_DO_8, G2_DO_9, G2_DO_10, G2_DO_11,
                          G2_DO_12, G2_DO_13, G2_DO_14, G2_DO_15,
                          G2_DO_16, G2_DO_17, sep = "|"),
         G2_1 = G2_1*2, G2_2 = G2_2*2, G2_3 = G2_3*2,
         G2_4 = G2_4*2, G2_5 = G2_5*2, G2_6 = G2_6*2,
         G2_7 = G2_7*2, G2_8 = G2_8*2, G2_9 = G2_9*2,
         G2_10 = G2_10*2, G2_11 = G2_11*2, G2_12 = G2_12*2,
         G2_13 = G2_13*2, G2_14 = G2_14*2, 
         G3_1 = G3_1*2, G3_2 = G3_2*2, G3_3 = G3_3*2,
         G3_4 = G3_4*2, G3_5 = G3_5*2, G3_6 = G3_6*2,
         G3_7 = G3_7*2, G3_8 = G3_8*2, G3_9 = G3_9*2,
         G3_10 = G3_10*2, G3_11 = G3_11*2, G3_12 = G3_12*2,
         G3_13 = G3_13*2, G3_14 = G3_14*2,
         G4_1 = G4_1*2, G4_2 = G4_2*2, G4_3 = G4_3*2,
         G4_4 = G4_4*2, G4_5 = G4_5*2, G4_6 = G4_6*2,
         G4_7 = G4_7*2, G4_8 = G4_8*2, G4_9 = G4_9*2,
         G4_10 = G4_10*2, G4_11 = G4_11*2, G4_12 = G4_12*2,
         G4_13 = G4_13*2, G4_14 = G4_14*2) %>%
  select(-G2_DO_4, -G2_DO_5, -G2_DO_6, -G2_DO_7,
         -G2_DO_8, -G2_DO_9, -G2_DO_10, -G2_DO_11,
         -G2_DO_12, -G2_DO_13, -G2_DO_14, -G2_DO_15,
         -G2_DO_16, -G2_DO_17)

# Recode Block H Other Issues
H <- d %>%
  mutate(H4 = recode(H4, `8` = 999),
         order_H6 = paste(H6_DO_1,H6_DO_2,H6_DO_3, sep = "|"),
         H7 = recode(H7, `3` = 2, `4` = 3, `5` = 4))  %>%
    select(iisID, H3:H6_3, order_H6, H7)

# Recode Block I News Consumption
I <- d %>%
  mutate(order_I8 = paste(I8_DO_1, I8_DO_4, I8_DO_5, I8_DO_6,
                          I8_DO_7, I8_DO_8, I8_DO_9, I8_DO_10,
                          I8_DO_11, I8_DO_12, I8_DO_13, I8_DO_14,
                          I8_DO_15, sep = "I")) %>%
  select(iisID, I1_1:I1_9, I2_1:I2_13, I2_other = I2_13_TEXT,
         I3_1:I3_14, I3_15 = I3_17,I3_16 = I3_15, I3_other = I3_15_TEXT,
         I4_1:I4_8, I4_9 = I4_15, I4_other_blogs = I4_8_TEXT,
         I4_other_sites = I4_15_TEXT,
         I5_1:I5_11, I5_other = I5_11_TEXT,
         I6_1:I6_6, I6_other = I6_6_TEXT,
         I7_1:I7_9, I7_other = I7_10_TEXT,
         I8_1, I8_2 = I8_4, I8_3 = I8_5,
         I8_4 = I8_6, I8_5 = I8_7, I8_6 = I8_8,
         I8_7 = I8_9, I8_8 = I8_10, I8_9 = I8_11,
         I8_10 = I8_12, I8_11 = I8_13, 
         I8_12 = I8_14, I8_13 = I8_15, order_I8,
         I9_1:I9_9,
         I10, I11) 

#twitter <- I %>%
#  select(iisID, I11) %>%
#  drop_na()
#write_csv(twitter, "twitter_handles_VUElectionPanel2021.csv")

## Merge &amp; Save Data
df <- left_join(BG, A, by = "iisID")
df <- left_join(df, B, by = "iisID")
df <- left_join(df, C, by = "iisID")
df <- left_join(df, D, by = "iisID")
df <- left_join(df, E, by = "iisID")
df <- left_join(df, F, by = "iisID")
df <- left_join(df, G, by = "iisID")
df <- left_join(df, H, by = "iisID")
df <- left_join(df, I, by = "iisID") %>%
  distinct(iisID, .keep_all = T) %>%
  drop_na(A1) %>%
  select(-I10, -I11) %>%
  filter(iisID !="007",
         iisID !="009") %>%
  mutate(iisID = as_numeric(iisID)) %>%
  drop_na(iisID)

write_csv(df, output_fn)


#haven::write_sav(df, "pre_wave_VUElectionPanel2021.sav")
rm(A, B, C, D, E, F, G, H, I, BG, twitter)

