VU 2021 Election Study: Example report
================
Wouter van Atteveldt

  - [Option 1: Plot as normal, and use inline code for
    data](#option-1-plot-as-normal-and-use-inline-code-for-data)
  - [Option 2: Explicitly print both plot and
    export:](#option-2-explicitly-print-both-plot-and-export)

``` r
library(here)
```

    ## here() starts at /home/wva/VU-Election-Study

``` r
library(glue)
knitr::opts_chunk$set(message = FALSE, warning = FALSE, echo=F, fig.path='../../docs/figures/', fig.width = 10)
```

## Option 1: Plot as normal, and use inline code for data

![](../../docs/figures/example-plot-1-1.png)<!-- --> Download data:
\[[Example plot 1](figures/Example_plot_1.csv)\]

## Option 2: Explicitly print both plot and export:

![](../../docs/figures/example-plot-2-1.png)<!-- -->Download data:
[Example plot data](figures/Example_plot_data.csv)
