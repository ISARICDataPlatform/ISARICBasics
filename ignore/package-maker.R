# This script gives a rough guide to how the CHARLIER package was created.

# Guide to writing R packages
# https://r-pkgs.org/whole-game.html

# {usethis} docs:
# https://usethis.r-lib.org/

# {roxygen2} docs:
# https://roxygen2.r-lib.org/articles/markdown.html

# install.packages("devtools")
# install.packages("roxygen2")
# install.packages("usethis")

# Create the package skeleton and activate the project directory
usethis::create_package("iddoBasics")

# Create a folder in the package directory called 'ignore'.
# Then place package-maker.R inside it to ignore this script when building.
usethis::use_build_ignore("ignore")

# Create an open source license document in the SSA name.
usethis::use_mit_license("Daniel Fryer")

# Use git
usethis::use_git()

# Use README
usethis::use_readme_md()

# Use NEWS.md
usethis::use_news_md()

# Use the following packages
usethis::use_package("RSQLite")
usethis::use_package("dbplyr")
usethis::use_package("magrittr")
usethis::use_package("stringr")
usethis::use_package("tibble")
usethis::use_package("dplyr")
usethis::use_package("ggplot2")
usethis::use_package("purrr")
usethis::use_package("tictoc")
usethis::use_package("vroom")
usethis::use_pipe(export = TRUE)

# Add roxygen2 with markdown for documentation
usethis::use_roxygen_md()

# Add lifecycle badge "experimental"
usethis::use_lifecycle_badge("experimental")

# Use testthat for testing workflow
usethis::use_testthat()

# Example code and testing ------------------------------------------------

DIRS <- list()
DIRS$data <- "C:/Datasets/AKI/data/raw/07APR2021/csvs"
DIRS$db_filename <- "db.sqlite"
DIRS$db <- file.path(DIRS$data, DIRS$db_filename)

ISARICBasics::build_sqlite(
  csv_folder=DIRS$data,
  sql_folder=DIRS$db,
  sql_filename=DIRS$db_filename,
  overwrite=F)

con <- DBI::dbConnect(RSQLite::SQLite(), DIRS$db)

DBI::dbListTables(con)

lb <- dplyr::tbl(con, "LB")

print(lb)
colnames(lb)


ds <- dplyr::tbl(con, "DS")
ds_all <- ds %>% dplyr::collect()

lb_creat <- lb %>% dplyr::filter(LBTESTCD == "CREAT")

lb_creat_all <- lb_creat %>% dplyr::collect()
dim(lb_creat_all)


lb_creat %>%
  dplyr::group_by(LBORRESU) %>%
  dplyr::summarise(n=n()) %>%
  dplyr::collect()

lb_creat


sa <- dplyr::tbl(con, "SA")
ho <- dplyr::tbl(con, "HO")

colnames(sa)
colnames(ho)

sa %>%
  dplyr::group_by(SAOCCUR, SAPRESP) %>%
  dplyr::summarise(n=n()) %>%
  dplyr::collect()

ho %>%
  dplyr::group_by(HOOCCUR, HOPRESP) %>%
  dplyr::summarise(n=n()) %>%
  dplyr::collect()

ho_modified <- ho %>%
  process_occur(xxOCCUR = HOOCCUR, xxPRESP = HOPRESP)

ho_modified %>%
  dplyr::group_by(HOOCCUR, HOPRESP, status) %>%
  dplyr::summarise(n=n()) %>%
  dplyr::collect()

DBI::dbDisconnect(con)



