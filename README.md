# ISARICBasics

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

This package is under the very early stages of initial development.

## This package offers

* SQLite database creation and a tutorial (below) on basic usage 
* Some built in processing functions for ISARIC data

# Tutorial

During this tutorial, we'll use the convention of appending `packagename::` to
every function that comes from a package outside of base R. 
This makes it easy to keep track
of which R package each function comes from. So, for example, instead of 
writing `install_github()` (a function from the `devtools` package), we will
write `devtools::install_github()`.

## Setting directories

For this tutorial, it will be handy to have file paths prepared.

First, create an empty list called `DIRS`, which will store all of the file
paths.

```r
DIRS <- list()
```

Now, set the location of the ISARIC data CSV files:

```r
DIRS$data <- "C:/my/path/07APR2021/csvs"
```

We'll be making a SQLite database, and we need somewhere to store it, as well as a name 
for the database file. The following will set the database location to the 
same directory as the CSVs, and give it the name `"db.sqlite"`:

```r
DIRS$db_filename <- "db.sqlite"
DIRS$db <- DIRS$data
```

## Installation

Start by installing the `devtools` package:

```r
install.packages("devtools")
```

You can now install the current version of ISARICBasics with:

```r
devtools::install_github("ISARICDataPlatform/ISARICBasics")
```

Then, load the `ISARICBasics` package:

```r
library(ISARICBasics)
```

## Building the SQLite database

The database requires no additional installation, and is built from
the CSV files provided by ISARIC. Assuming you have created the `DIRS` list, as above,
you can build the SQLite database with:

```r
ISARICBasics::build_sqlite(
  csv_folder=DIRS$data,
  sql_folder=DIRS$db,
  sql_filename=DIRS$db_filename,
  overwrite=FALSE)
```

The setting `overwrite=FALSE` makes sure that, if the SQLite database has already
been built, no existing tables will be overwritten. Setting `overwrite=TRUE` 
will cause every table in the database to be overwritten. However, note that the
ISARIC CSV files will never be changed or overwritten.

If you want more information on the `build_sqlite` function, you can open the
help file by executing the code:

```r
?ISARICBasics::build_sqlite
```

## Optional: browsing the database with DB Browser

One advantage of having the SQLite database, is that browsing large tables is 
easier and faster than it would be through, e.g., Excel. To browse the database,
you can install [DB Browser for SQLite](https://sqlitebrowser.org/). Once 
DB Browser is installed, you can open the SQLite database in DB Browser by 
clicking on the database file. If you have followed this tutorial until now,
the SQLite database file will be located in the same folder as the ISARIC CSV
files, and will have the name `db.sqlite`. DB Browser is quite powerful. Here
is a [beginner friendly tutorial](https://towardsdatascience.com/an-easy-way-to-get-started-with-databases-on-your-own-computer-46f01709561).

## Browsing the database with R

Now the SQLite database is built, it does not have to be built again. 
Each time you use it with R, you can connect to it with:

```r
con <- DBI::dbConnect(RSQLite::SQLite(), DIRS$db)
```

The object `con` represents a connection to the whole database. We can
find out what tables are available:

```r
DBI::dbListTables(con)

#> [1] "DM" "DS" "IN" "LB" "SA" "VS"
```

To connect to just the LB table, we use `con` as follows:

```r
lb <- dplyr::tbl(con, "LB")
```

Now, `lb` can be treated much like a `data.frame`. We can easily print the 
first 10 rows of the LB table, and some other information:

```r
print(lb)

#> # Source:   table<LB> [?? x 19]
#> # Database: sqlite 3.35.4
#> #   [C:\my\path\07APR2021\csvs\db.sqlite]
#>    STUDYID DOMAIN USUBJID   LBSEQ LBTESTCD LBTEST    LBCAT
#>    <chr>   <chr>  <chr>     <dbl> <chr>    <chr>     <chr>
#>  1 CVMEWUS LB     CVMEWUS_~     1 HGB      Hemoglob~ NA   
#>  2 CVMEWUS LB     CVMEWUS_~     2 MCH      Ery. Mea~ NA   
#>  3 CVMEWUS LB     CVMEWUS_~     3 PLAT     Platelets NA   
#>  4 CVMEWUS LB     CVMEWUS_~     4 RBC      Erythroc~ NA   
#>  5 CVMEWUS LB     CVMEWUS_~     5 RDW      Erythroc~ NA   
#>  6 CVMEWUS LB     CVMEWUS_~     6 WBC      Leukocyt~ NA   
#>  7 CVMEWUS LB     CVMEWUS_~     7 IRON     Iron      NA   
#>  8 CVMEWUS LB     CVMEWUS_~     8 K        Potassium NA   
#>  9 CVMEWUS LB     CVMEWUS_~     9 LDH      Lactate ~ NA   
#> 10 CVMEWUS LB     CVMEWUS_~    10 LYM      Lymphocy~ NA   
#> # ... with more rows, and 12 more variables:
#> #   LBSCAT <int>, LBORRES <chr>, LBORRESU <chr>,
#> #   LBSTRESC <chr>, LBSTRESN <dbl>, LBSTRESU <chr>,
#> #   LBSTAT <chr>, LBREASND <chr>, LBSPEC <chr>,
#> #   LBMETHOD <int>, LBDY <dbl>, LBEVINTX <chr>
```

Notice, at the top of the above output, the sentence `Source: table<LB> [?? x 19]`.
The `??` indicates that we do not know how many rows the LB table has. This is
because the LB table hasn't been fully loaded into R memory. We are just connected
to the table, which still resides in the SQLite database.

To view just the column names of the `LB` table:

```r
colnames(lb)

#>  [1] "STUDYID"  "DOMAIN"   "USUBJID"  "LBSEQ"   
#>  [5] "LBTESTCD" "LBTEST"   "LBCAT"    "LBSCAT"  
#>  [9] "LBORRES"  "LBORRESU" "LBSTRESC" "LBSTRESN"
#> [13] "LBSTRESU" "LBSTAT"   "LBREASND" "LBSPEC"  
#> [17] "LBMETHOD" "LBDY"     "LBEVINTX"
```

## A note on the pipe operator

From now on, we will start using the pipe operator `%>%`. If you are
unfamiliar with this handy tool, [here is a tutorial](https://towardsdatascience.com/an-introduction-to-the-pipe-in-r-823090760d64). 

## Working with large SQL data in R

For a small table, such as DS, we can comfortably load the whole table into R,
using `dplyr::collect()`:

```r
ds <- dplyr::tbl(con, "DS")
ds_all <- ds %>% dplyr::collect()
```

However, the LB table is very large. Loading the whole table into R may be unnecessary
and slow. The [R package dbplyr](https://dbplyr.tidyverse.org/) is installed
automatically with `ISARICBasics`, and is useful for working with large SQL tables.
With `dbplyr` installed, we can use many functions from the more well known
[R package, dplyr](https://dplyr.tidyverse.org/), on our SQL table connections.

A common operation is to filter the data, to retrieve only rows matching some
condition. For example, we can filter the LB table, using our `lb` connection,
to only connect to rows that have the value `"CREAT"` entered in the 
column LBTESTCD:

```r
lb_creat <- lb %>% dplyr::filter(LBTESTCD == "CREAT")
```

The object `lb_creat` is now a connection, just like `lb`, but it is aware that
we only want to look at cases where `LBTESTCD == "CREAT"`. If we want to load 
all those cases into R memory, we can use `dplyr::collect()` again:

```r
lb_creat_all <- lb_creat %>% dplyr::collect()
```

Now the full table has been loaded in R memory, as `data.frame`. We can, 
for example, look at its dimensions. 

```r
dim(lb_creat_all)

#> [1] 403509     19
```

Above, see that we have 403,509 rows, and 19 columns, pertaining to `"CREAT"`
records in the LB table.

The `dplyr` package provides many other ways for us to summarise and retrieve 
information. For example, we can find out how many different units have 
been used, and how many times, for reporting on CREAT tests:

```r
lb_creat %>%
  dplyr::group_by(LBORRESU) %>%
  dplyr::summarise(n=n()) %>%
  dplyr::collect()
  
#> # A tibble: 12 x 2
#>    LBORRESU      n
#>    <chr>     <int>
#>  1 NA         4561
#>  2 0.9           1
#>  3 MG/L          1
#>  4 MMOL/L        1
#>  5 U/L           2
#>  6 mg/L          9
#>  7 mg/dL     83307
#>  8 mg/dL'        1
#>  9 mmol/L      424
#> 10 mol          21
#> 11 umol        878
#> 12 umol/L   314303
```

Above, we have grouped the rows of `lb_creat`, by the contents of the `LBORRESU`
column, and then we have summarised the result, asking for a tally of the
number of rows in each group, with `dplyr::summarise(n=n())`.

There are many more tools available in `dplyr`, and many are discussed 
clearly [in the documentation](https://dplyr.tidyverse.org/).

## ISARICBasics processing functions

ISARIC data are stored in an [SDTM](https://en.wikipedia.org/wiki/SDTM) format
and collected from the [ISARIC Case Report Forms (CRF)](https://isaric.org/research/covid-19-clinical-research-resources/covid-19-crf/).

ISARICBasics processing functions are designed to transform some of the more 
complicated encodings for ISARIC data, to simpler formats.

To start, we will work with the SA and HO tables, to categorise events 
according to whether they occurred ('yes'), did not occur ('no'), or have an
unknown status ('unknown') at each point in time.

```r
sa <- dplyr::tbl(con, "SA")
ho <- dplyr::tbl(con, "HO")

colnames(sa)

#>  [1] "STUDYID"  "DOMAIN"   "USUBJID"  "SASEQ"    "SATERM"  
#>  [6] "SAMODIFY" "SACAT"    "SASCAT"   "SAPRESP"  "SAOCCUR" 
#> [11] "SASTAT"   "SAREASND" "SADY"     "SASTDY"   "SAENDY"  
#> [16] "SADUR"    "SASTRF"   "SAEVLINT" "SAEVINTX"

colnames(ho)

#>  [1] "STUDYID"  "DOMAIN"   "USUBJID"  "HOSEQ"    "HOTERM"  
#>  [6] "HODECOD"  "HOPRESP"  "HOOCCUR"  "HOSTAT"   "HOREASND"
#> [11] "HODY"     "HOSTDY"   "HOENDY"   "HODUR"    "HOSTRF"  
#> [16] "HOEVINTX" "HODISOUT" "SELFCARE" "HOINDC"  
```
We can see above that SA and HO have many similar column names, 
when the prefix `xx` is ignored. In particular, they both have:

* `xxTERM`: the verbatim wording of the event (non-standardised).
* `xxOCCUR`: helps indicate whether an event occurred.
* `xxPRESP`: 'y' indicates the observation was pre-specified on the CRF, while missing or 'N' indicates spontaneous reports.
* `xxSTDY`: the day of the event, relative to admission.

Rather than work with the verbatim wording of an event (`xxTERM`), which is
highly variable, we can work with the standardised versions, e.g.,
`HODECOD` or `SAMODIFY`.

To understand `xxOCCUR` and `xxPRESP` better, we can find out how many combinations
of these appear in each table, and how many times each combination occurs:

```r
sa %>%
  dplyr::group_by(SAOCCUR, SAPRESP) %>%
  dplyr::summarise(n=n()) %>%
  dplyr::collect()
  
#> # A tibble: 5 x 3
#> # Groups:   SAOCCUR [4]
#>   SAOCCUR SAPRESP        n
#>   <chr>   <chr>      <int>
#> 1 NA      NA        250815
#> 2 NA      Y          43496
#> 3 N       Y       17334310
#> 4 U       Y        5388019
#> 5 Y       Y        2426457

ho %>%
  dplyr::group_by(HOOCCUR, HOPRESP) %>%
  dplyr::summarise(n=n()) %>%
  dplyr::collect()
  
#> # A tibble: 6 x 3
#> # Groups:   HOOCCUR [4]
#>   HOOCCUR HOPRESP      n
#>   <chr>   <chr>    <int>
#> 1 NA      NA      218769
#> 2 NA      Y         1000
#> 3 N       Y       651063
#> 4 U       Y         6331
#> 5 Y       NA         577
#> 6 Y       Y       468717
```
We can see, for example, that in the HO table, the value `HOOCCUR = 'Y'`
appeared beside the value `HOPRESP = NA`, a total of 577 times. 

The function `ISARICBasics::process_occur` will process each possible combination
of `xxOCCUR` and `xxPRESP` into one column, called `status`, which takes values
'yes' (occurred), 'no' (did not occur), or 'unknown' (unknown status):

```r
ho_modified <- ho %>%
  ISARICBasics::process_occur(xxOCCUR = HOOCCUR, xxPRESP = HOPRESP)
```

We can now summarise the results to see how the new column named `status` 
compares to `HOOCCUR` and `HOPRESP`:

```r
ho_modified %>%
  dplyr::group_by(HOOCCUR, HOPRESP, status) %>%
  dplyr::summarise(n=n()) %>%
  dplyr::collect()
  
#> # A tibble: 6 x 4
#> # Groups:   HOOCCUR, HOPRESP [6]
#>   HOOCCUR HOPRESP status       n
#>   <chr>   <chr>   <chr>    <int>
#> 1 NA      NA      yes     218769
#> 2 NA      Y       unknown   1000
#> 3 N       Y       no      651063
#> 4 U       Y       unknown   6331
#> 5 Y       NA      yes        577
#> 6 Y       Y       yes     468717
```

Note that the `status` column added by `ISARICBasics::process_occur` is 
lowercase, while the other columns are uppercase. This is a good convention 
to keep track of which columns are from the original ISARIC data (uppercase) and which 
columns are derived (lowercase). 
