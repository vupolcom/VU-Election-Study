library(tidyverse)
library(glue)
library(sjlabelled)
library(qualtRics)

load_survey = function(survey_id) {
  
  ## Load Data from qualtrics using the API key from data/raw-private
  api_key_fn = here("data/raw-private/qualtrics_api_key.txt")
  API = read_file(api_key_fn) %>% trimws()
  qualtrics_api_credentials(api_key = API,  base_url = "fra1.qualtrics.com")
  d <- fetch_survey(surveyID = survey_id, 
                    verbose = TRUE, force_request = T,
                    label = FALSE, convert = FALSE)
  column_map = attributes(d)$column_map
  if (!"consent1" %in% colnames(d) & "constent1" %in% colnames(d)) d = d %>% rename(consent1=constent1)
  if (!"consent2" %in% colnames(d)) d = d %>% add_column(consent2=1)
  #only keep people that have given consent, are not admin or 007/009, and have filled in A1
  d <- d %>%
    remove_all_labels() %>% 
    as_tibble() %>%
    filter(consent1==1 & consent2==1,
           !is.na(iisID),
           !str_detect(iisID, "admin|Loes|Mariken"),
           !iisID %in% c("007", "009"),
           !is.na(A1)
           
    ) %>%
    mutate(iisID = as.numeric(iisID))
  if (any(is.na(d$iisID))) stop("iisID still contains NA values after cleaning")
  
  if (nrow(d) != length(unique(d$iisID))) {
    # Some respondents have duplicate rows due to an error in launching the survey
    # For those people, we take the latest non-missing value for each column
    message(glue("Merging {nrow(d) - length(unique(d$iisID))} duplicates..."))
    first_non_missing = function(x) na.omit(x)[1]
    d = d %>% arrange(iisID, desc(RecordedDate)) %>% group_by(iisID) %>% 
      group_by(iisID) %>% summarize(across(everything(), first_non_missing))
  }
  attr(d,"column_map") = column_map
  d
}

#' Clean the metavariables present in each survey (start, duration, etc)
clean_meta = function(d) {
  d %>%
    mutate(start_date = StartDate,
           end_date = EndDate,
           duration_min = round(Duration..in.seconds./60,2)) %>%
    select(iisID, start_date, end_date, duration_min, 
           progress = Progress)
}

#' Recode Block A Voting Behavior
clean_A = function(d) {
  A = d %>%
    select(iisID, A1:A2, A2_otherparty = A2_14_TEXT,
           matches("A[23]_DO_\\d+")) %>%
    mutate(A1 = recode(A1,
                       `2` = 0,
                       `3` = 998,
                       `4` = 999),
           A2 = recode(A2,
                       `16` = 999)) %>%
    unite(order_A2, matches("A2_DO_\\d+"), sep="|") %>%
    unite(order_A3, matches("A3_DO_\\d+"), sep="|") 
  
  
  A3 <- d %>%
    select(iisID, matches("A3_\\d+")) %>%
    pivot_longer(-iisID, names_to = "variable") %>%
    drop_na(value) %>%
    separate(variable, c("variable", "party"), "_", extra = "merge")  %>%
    group_by(iisID) %>%
    summarise(n = row_number(),
              party = party) %>%
    ungroup() %>%
    mutate(n = paste("A3", n, sep="_"),
           n = factor(n),
           party = as.integer(party)) %>%
    pivot_wider(names_from = n, values_from = party, 
                values_fill = 0) %>%
    unite("A3", matches("A3_\\d+"), sep="|", remove=FALSE)
  
  left_join(A, A3, by = "iisID") %>%
    select(iisID, A1:A2_otherparty, order_A2, A3, order_A3, matches("A3_\\d+")) 
}

#' Recode Block B: Performance Politics in the Media
clean_B = function(d) {
  B = d %>% mutate(across(matches("B2_\\d+"), 
                          ~recode(., `1` = 999, `2` = 1, `24` = 2,`25` = 3))
  ) %>%
    unite(order_B2, matches("B2_DO_\\d+"), sep="|") %>%
    select(iisID, B2_1:B2_13, order_B2)
  
  d## meaning of X1_B3_3 etc: performance of party X1, filled in either in variable _3 or _4
  B3 <- d %>%  select(iisID, matches("^X\\d+_B3_\\d+$")) %>%
    pivot_longer(cols = -iisID, names_to = "variable") %>%
    separate(variable, c("variable", "question"), "_", extra = "merge")  %>%
    pivot_wider(names_from = question, values_from = value) %>%
    mutate(B3=case_when(
      !is.na(B3_3) ~ B3_3,
      !is.na(B3_4) ~ B3_4,
      T ~ 999)) %>% 
    select(-B3_3, -B3_4) %>%
    mutate(variable = str_c("B3_", str_remove_all(variable, "X"))) %>%
    pivot_wider(names_from = variable, values_from = B3) 
  
  
  left_join(B, B3, by = "iisID") 
}

#' Recode Block C Issue Association
clean_C = function(d) {
  # Recode numerical answers to question blocks C1 and C2
  # Variable names are coded <party>_<variable:C1 or C2>_<choice:1st or 2nd>_<screen:2,3,4>
  C12 = d0 %>% select(iisID, matches("X\\d+_C[12]_[12]_[234]$")) %>% 
    pivot_longer(-iisID) %>% 
    separate(name, into=c("party", "variable", "choice", "screen"))  %>%
    # Participants fill in either _2, _3, or _4 depending on earlier choice
    # so pivot wide, pick first non-missing value, drop columns
    pivot_wider(names_from="screen") %>%
    mutate(value = case_when(!is.na(`2`) ~ `2`,
                             !is.na(`3`) ~ `3`,
                             T ~ `4`)) %>% 
    select(-`2`, -`3`, -`4`) %>%
    filter(!is.na(value)) %>% 
    # Convert value for question C1 from 20-38 to 1-19 and 40->20
    mutate(value=case_when(variable=="C1" & value == 40 ~ 20,
                           variable=="C1" ~ value - 19,
                           T ~ value),
           # Create output variable name <variable>_<choice>_<party> and pivot wider
           party=as.numeric(str_remove(party, "X")),
           name=glue("{variable}_{choice}_{party}")) %>% 
    arrange(variable, choice, party) %>%
    select(iisID, name, value) %>% 
    pivot_wider()
  
  # Extract 'other' text from C1 answer value 38
  # <party>_<variable:C1 or C2>_<choice:1st or 2nd>_<screen:2,3,4>_38_TEXT
  C1_TEXT = d0 %>% select(iisID, matches("X\\d+_C1_[12]_[234]_38_TEXT$")) %>% 
    pivot_longer(-iisID) %>% 
    separate(name, into=c("party", "variable", "choice", "screen", "answer", "text"), sep = "_") %>%
    # As above, participants fill in either _2, _3, or _4 depending on earlier choice
    # so pivot wide, pick first non-missing value, drop columns
    pivot_wider(names_from="screen") %>%
    mutate(value = case_when(!is.na(`2`) ~ `2`,
                             !is.na(`3`) ~ `3`,
                             T ~ `4`)) %>% 
    select(-`2`, -`3`, -`4`) %>% 
    filter(!is.na(value)) %>% 
    # Create output variable name C1_<choice>_<party>_text and pivot
    mutate(party=as.numeric(str_remove(party, "X")),
           name=glue("{variable}_{choice}_{party}_text")) %>% 
    arrange(variable, choice, party) %>%
    select(iisID, name, value) %>% 
    pivot_wider()
  # Join together and return
  full_join(C12, C1_TEXT, by="iisID")
}

clean_F = function(d) {
  d %>% select(iisID, matches("^F[12]")) %>% rename(F2_11=F2_15) %>% unite(order_F1, matches("F1_DO"), sep="|") %>% unite(order_F2, matches("F2_DO"), sep="|")
}

#' Clean block G: Leader evaluations
clean_G = function(d) {
  #' Replace Gn_4 ... Gn_17 by Gn_1..Gn_14
  rename_G = function(x) str_replace(x, '([0-9]+)$', function(x) as.numeric(x)-3)
  
  G_eval = d %>% select(iisID, matches("^G_eval")) %>% mutate(across(-iisID, ~recode(., `1` = 1, `4` = 0)))
  G2_order = d %>% select(iisID, matches("^G2_DO_")) %>% unite(order_G2, -iisID, sep="|")
  G234 = d %>% select(iisID, matches("^G[234567]_\\d+$")) %>% rename_with(rename_G, .cols=-iisID) %>%  mutate(across(-iisID, ~.*2)) 
  d %>% select(iisID, matches("^G1_b$|^G1_\\d")) %>%  # only present in first wave
    full_join(G_eval, by="iisID") %>% 
    full_join(G2_order, by="iisID") %>% 
    full_join(G234, by="iisID")
}

clean_I = function(d) {
  I = d %>% select(iisID, matches("^I[1-7]")) %>% rename(
    I2_other = I2_13_TEXT,
    I3_other = I3_15_TEXT,
    I4_other_blogs = I4_8_TEXT,
    I4_other_sites = I4_15_TEXT,
    I5_other = I5_11_TEXT,
    I6_other = I6_6_TEXT
  )
  if ("I7_10_TEXT" %in% colnames(I)) I = rename(I, I7_other = I7_10_TEXT)
  if ("I7_11_TEXT" %in% colnames(I)) I = rename(I, I7_other = I7_11_TEXT)
  I
}