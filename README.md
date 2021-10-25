# ISARICBasics

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

This package is under the very early stages of initial development.

## This package offers

* Simple functions focused on clarifying and advising on a few best practices, including:
  * Cleaning basics for time series by days and sequence
* Determining if an event occurred (yes, no, unknown)
* SQLite database creation and basic usage
* Documentation and data dictionary

## Installation

You can install the current version of iddoBasics with:

``` r
devtools::install_github("ISARICDataPlatform/iddoBasics")
```

## Building the SQLite database

The database requires no installation outside of R packages, and is built from
the csv files provided by ISARIC. See the help file for the function
`build_sqlite` for instructions on how to build the SQLite database.

```
library(ISARICBasics)
?build_sqlite
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(ISARICBasics)
## basic example code
```

