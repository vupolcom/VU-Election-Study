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