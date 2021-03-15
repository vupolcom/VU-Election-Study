library(tidyverse)
library(sjlabelled)
library(qualtRics)
library(glue)

#' Save data as csv and return (md) download link
#' @param name: Human-readable name (will be sanitized to .csv file name)
#' @param data: Data frame to save
#' @param label: If TRUE, prepend "Download data:" to link
#' @return character containing download link (`[name](figures/filename.csv)`)
export_data = function(data, name, label=F) {
  fn = name %>% str_replace_all("[^\\p{LETTER}\\p{DIGIT}]+", "_") %>% trimws() 
  if (!str_ends(fn,".csv")) fn = str_c(fn, ".csv")
  outfile = str_c(knitr::opts_chunk$get('fig.path'), fn)
  message(outfile)
  write_csv(data, outfile)
  str_c(if (label) "Download data: " else "", str_c("[", name, "](", outfile, ")"))
} 

#' Load the codebook (variable names and labels)
get_codebook = function() {
  read_csv(here("data/raw/codebook.csv"), col_types="cncnlcc")
}

#' Apply value labels from codebook (e.g. to be used in mutate(across))
#' @param values the values to recode to labels
#' @param codebook the codebook data frame (from get_codebook)
#' @param column the name of the column to recode (defaults to cur_column())
#' @return a factor with the recoded values
apply_value_labels = function(values, codebook, column=cur_column()) {
  cb = codebook %>% filter(variable == column)
  na_values = cb$value[cb$isna]
  factor(ifelse(values %in% na_values, NA, cb$label[match(values, cb$value)] ),
         levels=cb$label[!cb$isna])
}

#' Extract the wide (i.e. simple respondent-level) data
#' @param data The (cleaned) qualtrics data frame
#' @return A data frame with respondent-level variables and (where applicable) value labels
extract_wide = function(data) {
  codebook = get_codebook()
  # Columns to keep and renames to apply
  widecols = c("iisID", codebook %>% filter(!long) %>% pull(variable)) %>% unique()
  renames = codebook %>% filter(!is.na(rename)) %>% select(variable, rename) %>% unique()
  labelcols = codebook %>% filter(!is.na(value)) %>% pull(variable) %>% unique()
  # Filter, rename, and 
  data %>% 
    select(any_of(widecols)) %>% 
    mutate(across(any_of(labelcols), apply_value_labels, codebook=codebook)) %>% 
    rename_with(function(x) renames$rename[match(x, renames$variable)], 
              any_of(renames$variable))
}

#' Extract the 'long' values from the survey, i.e. items with multiple responses
#' @param data The (cleaned) qualtrics data frame
#' @return A data frame with columns iisID, variable, option, name, and value
extract_long = function(data) {
  cb = get_codebook() %>% 
    filter(long==1) %>% 
    select(variable, option=value, name=label) %>% 
    mutate(name = factor(name))
  longcols = cb %>% pull(variable) %>% unique()
  regex = str_c("iisID|(", str_c(longcols, collapse="|"), ")_\\d+")
  data %>% 
    select(matches(regex)) %>% select(!matches("TEXT")) %>% 
    pivot_longer(-iisID) %>%
    filter(!is.na(value)) %>% 
    separate(name, into=c("variable", "option"), sep="_") %>% 
    mutate(option=as.numeric(option)) %>% 
    left_join(cb) %>% 
    mutate(variable=factor(variable)) %>% 
    select(iisID, variable, option, name, value)
}

#' Extract the longitudinal data (vote intention, media use) 
#' @param data A list with one (cleaned/raw) data frame per wave
#' @return a long data frame of wave x respondent x variable
extract_waves = function(data) {
  
  prepare_wave = function(w) {
    ld = extract_long(w) %>% filter(str_detect(variable, "^I|^B")) %>% select(-option)
    wd = extract_wide(w) %>% select(iisID, vote) %>% pivot_longer(-iisID, names_to="variable", values_to="name") %>% add_column(value=1)
    bind_rows(ld,wd)
  }
  purrr::map(data, prepare_wave) %>% bind_rows(.id="wave")
}
  #purrr::map(data, function(x) tibble(variable=colnames(x))) %>% bind_rows(.id="wave") %>% add_column(one=1) %>% 
  #  pivot_wider(names_from="wave", values_from="one", values_fill=0) %>% 
  #  mutate(x=w0+w1+w2) %>% filter(x>1) %>% 
  #  left_join(get_codebook()) %>%
  #  View()


load_survey = function(survey_id) {

  ## Load Data from qualtrics using the API key from data/raw-private
  api_key_fn = here("data/raw-private/qualtrics_api_key.txt")
  API = read_file(api_key_fn) %>% trimws()
  qualtrics_api_credentials(api_key = API,  base_url = "fra1.qualtrics.com")
  d <- fetch_survey(surveyID = survey_id, 
                    verbose = TRUE, force_request = T,
                    label = FALSE, convert = FALSE)
  
  if (!"consent1" %in% colnames(d) & "constent1" %in% colnames(d)) d = d %>% rename(consent1=constent1)
  
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

