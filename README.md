
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Practical ggplot2

[![Build
Status](https://travis-ci.org/wilkelab/isoband.svg?branch=master)](https://travis-ci.org/wilkelab/practicalgg)

The R package ggplot2 provides a powerful and flexible approach to data
visualization, and it is suitable both for rapid exploration of
different visualization approaches and for producing carefully crafted
publication-quality figures. However, getting ggplot2 to make figures
that look exactly the way you want them to can sometimes be challenging,
and beginners and experts alike can get confused by themes, scales,
coords, guides, or facets. This repository houses a set of step-by-step
examples demonstrating how to get the most out of ggplot2, including how
to choose and customize scales, how to theme plots, and when and how to
use extension packages.

The examples shown are based on the book [“Fundamentals of Data
Visualization.”](https://serialmentor.com/dataviz) However, there are
minor differences between the figures here and the ones in the book.
Most importantly, the book uses the Myriad Pro font family, which is not
freely available. I have also cleaned up the ggplot2 code where
appropriate, and I have made adjustments to font and figure sizes so the
figures look appropriate in the default R Markdown html style.

## Installation

The examples presented here require a working installation of the
statistical programming language R. You can download the latest version
from [here.](https://cran.r-project.org/) Further, when working with R,
it is highly recommended to use the RStudio IDE, and you can download
the latest version from
[here.](https://rstudio.com/products/rstudio/download/)

In addition to R and RStudio, you need a number of R packages. You can
install all required packages by executing the following two commands in
an R console:

``` r
# install the latest version of package "remotes" from CRAN
install.packages("remotes")

# install package "practicalgg" from github; this pulls in 
# all required dependencies and makes available the example data
remotes::install_github("wilkelab/practicalgg")
```

You may have to repeat the `install_github()` command if you want to
work through an example I have added after you last installed the
practicalgg package.

## Browse the examples

These are the examples currently available:

  - [Bundestag pie
    chart](https://wilkelab.org/practicalgg/articles/bundestag_pie.html)
  - [Corruption and human
    development](https://wilkelab.org/practicalgg/articles/corruption_human_development.html)
  - [Health status by
    age](https://wilkelab.org/practicalgg/articles/health_status.html)
  - [Interrupted Goode
    homolosine](https://wilkelab.org/practicalgg/articles/goode.html)
  - [Median Texas income by
    county](https://wilkelab.org/practicalgg/articles/Texas_income.html)
  - [Winkel tripel
    projection](https://wilkelab.org/practicalgg/articles/Winkel_tripel.html)
