
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bbsTaiwan

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

### Overview 📑

The goal of `bbsTaiwan` is to streamline Taiwan Breeding Birds Survey
(BBS) data retrieval and analysis. It will support data retrieval from
GBIF, where Taiwan BBS data are stored. This work was supported by
[rOpenSci Champions Program](https://ropensci.org/champions/) 2023-2024,
with the main developer [Sunny Tseng](https://sunnytseng.ca/) and the
mentor [Eunseop
Kim](https://ropensci.org/blog/2023/11/29/champions-program-mentors-2023/).

The first version of bbsTaiwan is using 2009 to 2016 GBIF data (version
XXX) and we will updated once new dataset is published

- General introduction of the functionalities

- Case study with the package

### Installation 💻

You can install and load the development version of `bbsTaiwan` from
Github with:

``` r
# install.packages("devtools")
devtools::install_github("SunnyTseng/bbsTaiwan")
```

### Main functions ⛺

`bbsTaiwan` provides several intuitive imported datasets and data
processing functions. For accessing the raw Taiwan BBS dataset on GBIF:

- `occurrence`: times and locations at which particular species have
  been recorded

- `event`: the protocols used, the sample size, and the location for
  each

- `measurementorfacts`: additional information relating to the events

- `extendedmeasurementorfact`: additional information relating to the
  taxon occurrences

To perform basic data retrieval and visualization:

- `bbs_translate()` translate bird species’ Chinese common name to
  scientific name

- `bbs_fetch()` fetch the cleaned version of Taiwan BBS cccurrence data
  by species

- `bbs_plotmap()` visualize species distribution across all BBS sites

- `bbs_history()` examine the number of BBS sites surveyed each year

- `bbs_sites()` return the coordinates of sll BBS sites

### Usage 💡

``` r
library(bbsTaiwan)

## Get data for species of interest
bbs_fetch(c("白頭翁", "烏頭翁"))
#> # A tibble: 92,475 × 16
#>     year month   day site   locationID decimalLatitude decimalLongitude weather
#>    <dbl> <dbl> <dbl> <chr>  <chr>                <dbl>            <dbl> <chr>  
#>  1  2009     3    10 A02-01 A02-01_01             25.1             122. <NA>   
#>  2  2009     3    10 A02-01 A02-01_01             25.1             122. <NA>   
#>  3  2009     4     5 A02-01 A02-01_01             25.1             122. <NA>   
#>  4  2009     4    26 A02-01 A02-01_01             25.1             122. <NA>   
#>  5  2009     3    10 A02-01 A02-01_01             25.1             122. <NA>   
#>  6  2009     4    26 A02-01 A02-01_01             25.1             122. <NA>   
#>  7  2009     4     5 A02-01 A02-01_01             25.1             122. <NA>   
#>  8  2009     4    26 A02-01 A02-01_02             25.1             122. <NA>   
#>  9  2009     3    10 A02-01 A02-01_02             25.1             122. <NA>   
#> 10  2009     4     5 A02-01 A02-01_02             25.1             122. <NA>   
#> # ℹ 92,465 more rows
#> # ℹ 8 more variables: wind <chr>, habitat <chr>, scientificName <chr>,
#> #   vernacularName <chr>, individualCount <dbl>, time_slot <chr>,
#> #   distance <chr>, flock <chr>

## Find the distribution/overlap of two species
bbs_plotmap(c("白頭翁", "烏頭翁"))
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />
