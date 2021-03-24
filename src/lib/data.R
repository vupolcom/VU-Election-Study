library(tidyverse)
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
  if (min(data$A2, na.rm=T) > 15) {
    # Wave 4 used different values for A2 (vote) variable
    codebook = codebook %>% filter(variable != "A2") %>% mutate(variable=recode(variable, "A2_wave4"="A2"))
  }
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
    ld = extract_long(w) %>% filter(str_detect(variable, "A3|^I|^B")) %>% select(-option)
    wd = extract_wide(w) %>% select(iisID, A2) %>% pivot_longer(-iisID, names_to="variable", values_to="name") %>% add_column(value=1)
    bind_rows(ld,wd)
  }
  purrr::map(data, prepare_wave) %>% bind_rows(.id="wave")
}
  #purrr::map(data, function(x) tibble(variable=colnames(x))) %>% bind_rows(.id="wave") %>% add_column(one=1) %>% 
  #  pivot_wider(names_from="wave", values_from="one", values_fill=0) %>% 
  #  mutate(x=w0+w1+w2) %>% filter(x>1) %>% 
  #  left_join(get_codebook()) %>%
  #  View()



