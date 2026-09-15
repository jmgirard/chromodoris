
<!-- README.md is generated from README.Rmd. Please edit that file -->

# chromodoris

<!-- badges: start -->

<!-- badges: end -->

chromodoris is a ggplot2 extension for one plot type, the Chromodoris
plot. The plot takes many time series, one per participant or unit, and
summarizes them moment by moment as nested quantile ribbons (for example
the inner 90%, 70%, and 50% of values) around a center line. It replaces
a spaghetti plot of overlaid series with a distributional summary that
reads at a glance.

The package is under development and exports no functions yet. It will
offer two layers: a low-level ggplot2 stat that computes the bands from
long data (columns for series id, time, and value) inside any ggplot
pipeline, and a high-level wrapper that draws the whole plot with
default scales and theme.

## Installation

The package is not on CRAN. Once a GitHub release exists, you can
install the development version with:

``` r
# install.packages("pak")
pak::pak("jmgirard/chromodoris")
```
