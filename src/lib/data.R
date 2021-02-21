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
  str_c(if (label) "Download data: " else "", glue("[{name}]({outfile})"))
} 

#' Load the codebook (variable names and labels)
get_codebook = function() {
  read_csv(here("data/raw/codebook.csv"), col_types="clcnlcc")
}

#' Apply value labels from codebook (e.g. to be used in mutate(across))
#' @param values the values to recode to labels
#' @param codebook the codebook data frame (from get_codebook)
#' @param column the name of the column to recode (defaults to cur_column())
#' @return a factor with the recoded values
apply_value_labels = function(values, codebook, column=cur_column()) {
  cb = codebook %>% filter(variable == column)
  na_values = cb$value[cb$isna]
  factor(ifelse(values %in% na_values, NA, cb$label[match(values, cb$value)] ))
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
  cb = get_codebook() %>% filter(long) %>% select(variable, option=value, name=label)
  longcols = cb %>% pull(variable) %>% unique()
  regex = str_c("iisID|(", str_c(longcols, collapse="|"), ")_\\d+")
  data %>% 
    select(matches(regex)) %>% 
    pivot_longer(-iisID) %>%
    separate(name, into=c("variable", "option"), sep="_") %>% 
    mutate(option=as.numeric(option)) %>% 
    left_join(cb) %>% 
    select(iisID, variable, option, name, value)
}
