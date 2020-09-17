
<!-- README.md is generated from README.Rmd. Please edit that file -->

# HTSoutliers

<!-- badges: start -->

<!-- badges: end -->

The goal of HTSoutliers is to provide functions to help with the
detection of outliers found in hyrdological time series data.

## Installation

You can install the released version of HTSoutliers from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("HTSoutliers")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("scoutiii/HTSoutliers")
```

## Example

This is a basic example which shows you how to solve a common problem:

Getting data from the GHCND. You can specify as few or as many different
locations as you want, and mix the type of locations. For example you
can get two different states data, along with some other stations which
lie outside of those states, and include a desired ecoregion.

``` r
library(HTSoutliers)

data <- get_weather_data(c("BF1BI000001", "BF1EG000001"), progress = FALSE)
head(data)
#>             ID       DATE ELEMENT VALUE MFLAG QFLAG SFLAG
#> 23 BF1BI000001 2020-03-23    WESD    13                 N
```
