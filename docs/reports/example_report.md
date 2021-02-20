VU 2021 Election Study: Example report
================
Wouter van Atteveldt

``` r
library(here)
```

    ## here() starts at /home/wva/VU-Election-Study

``` r
library(glue)
knitr::opts_chunk$set(message = FALSE, warning = FALSE, echo=F, fig.path=here('docs/reports/figures/'), fig.width = 10)
library(printr)
```

    ## Registered S3 method overwritten by 'printr':
    ##   method                from     
    ##   knit_print.data.frame rmarkdown

``` r
#' Save the csv into the figures folder and create a download link
export_data = function(data, name) {
  # normalize file name
  fn = name %>% str_replace_all("\\P{LETTER}+", "_") %>% trimws() 
  if (!str_ends(fn,".csv")) fn = str_c(fn, ".csv")
  outfile = file.path(knitr::opts_chunk$get('fig.path'), fn)
  message(outfile)
  write_csv(data, outfile)
  glue("[Download data: [{name}](figures/{fn})]")
} 
```

![](/home/wva/VU-Election-Study/docs/reports/figures/example-plot-1.png)<!-- -->\[Download
data: [Example plot data](figures/Example_plot_data.csv)\]
