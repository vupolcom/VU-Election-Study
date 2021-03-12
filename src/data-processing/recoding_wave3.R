#! /usr/bin/env Rscript
#DESCRIPTION: Data Cleaning: Dutch Parliamentary Elections 2021 Pre-Wave
#AUTHOR: "VU Political Communication Group: Mariken van der Velden (coordinator), Loes Aaldering, Wouter van Atteveldt, Andreu Casas Salleras, Felicia Loecherbach, Anita van Hoof, Dirck de Kleer, Jan Kleinnijenhuis, Marloes Jansen, Nicolas Matthis, Kasper Welbers and Nienke Wolfers"
#DEPENDS: data/raw-private/qualtrics_api_key.txt
#CREATES: data/intermediate/VUElectionPanel2021_wave3.csv

library(tidyverse)
library(sjlabelled)
library(here)
library(qualtRics)

input_fn = here("data/raw-private/qualtrics_api_key.txt")
output_fn = here("data/intermediate/wave3.csv")

API = read_file(input_fn) %>% trimws()
qualtrics_api_credentials(api_key = API,  base_url = "fra1.qualtrics.com")
d <- fetch_survey(surveyID = "SV_a92jPqJ9B5EQMSx", 
                  verbose = TRUE, force_request = T,
                  label = FALSE, convert = FALSE)

# drop missing & admin iisID and merge  duplicates (!)
d = d %>% filter(!is.na(iisID), !str_detect(iisID, "admin")) %>% mutate(iisID = as.numeric(iisID))
first_non_missing = function(x) na.omit(x)[1]
d = d %>% arrange(iisID, desc(RecordedDate)) %>% group_by(iisID) %>% 
  group_by(iisID) %>% summarize(across(everything(), first_non_missing))
if (nrow(d) != length(unique(d$iisID))) stop("Duplicates!")

# Recode Block Background Variables
BG <- d %>%
  mutate(wave = "wave 3",
         start_date = StartDate,
         end_date = EndDate,
         duration_min = round(`Duration (in seconds)`/60,2)) %>%
  select(iisID, wave, start_date, end_date, duration_min, 
         progress = Progress)


# Recode Block A Voting Behavior
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
                          A3_DO_12, A3_DO_13, sep = "|")) %>%
  select(iisID, A1, A2, A2_otherparty, order_A2, order_A3)

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
                    A3_6, 
                    sep = "|"))
A <- left_join(A, A3, by = "iisID") %>%
  select(iisID, A1:A2_otherparty, order_A2, A3, order_A3, A3_1:A3_6)
rm(A3)


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

colnames(d)
B3 <- d %>%
  select(iisID, matches("^\\d+_B3_\\d+$")) %>%
  pivot_longer(cols = `1_B3_3`:`13_B3_4`,
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
  rename_with(~str_c('B3_', .), matches("\\d")) %>% 
  select(-row) %>% 
  distinct(iisID, .keep_all = TRUE)

B <- d %>%
  select(iisID, B2_1:B2_13, order_B2) %>% 
  left_join(B3, by = "iisID")

colnames(d)

#TODO: recode H

I <- d %>%
  select(iisID, I1_1:I1_9, I2_1:I2_13, I2_other = I2_13_TEXT,
         I3_1:I3_14, I3_15 = I3_17,I3_16 = I3_15, I3_other = I3_15_TEXT,
         I4_1:I4_8, I4_9 = I4_15, I4_other_blogs = I4_8_TEXT,
         I4_other_sites = I4_15_TEXT,
         I5_1:I5_11, I5_other = I5_11_TEXT,
         I6_1:I6_6, I6_other = I6_6_TEXT,
         I7_1:I7_10, I7_other = I7_10_TEXT) 

## Merge & Save Data
df = BG %>%
  left_join(A, by = "iisID") %>% 
  left_join(B, by = "iisID") %>%
  left_join(I, by = "iisID") 
  #distinct(iisID, .keep_all = T) %>% <<< WHY IS THIS NEEDED?
  # drop_na(A1) %>% <<< Do we realy want this?
  #filter(iisID !="007",
  #       iisID !="009") %>%
  
  
write_csv(df, output_fn)