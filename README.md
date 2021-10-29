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
DIRS$db <- file.path(DIRS$data, DIRS$db_filename)
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
first 10 rows, and some other information (in this tutorial, we cannot display 
example output, for data security reasons):

```r
print(lb)
```

To view just the column names of `lb`:

```
colnames(lb)

#>  [1] "STUDYID"  "DOMAIN"   "USUBJID"  "LBSEQ"   
#>  [5] "LBTESTCD" "LBTEST"   "LBCAT"    "LBSCAT"  
#>  [9] "LBORRES"  "LBORRESU" "LBSTRESC" "LBSTRESN"
#> [13] "LBSTRESU" "LBSTAT"   "LBREASND" "LBSPEC"  
#> [17] "LBMETHOD" "LBDY"     "LBEVINTX"
```



## Example

This is a basic example which shows you how to solve a common problem:

```r
## basic example code
```

