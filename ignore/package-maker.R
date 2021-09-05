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
usethis::use_pipe(export = TRUE)

# Add roxygen2 with markdown for documentation
usethis::use_roxygen_md()

# Add lifecycle badge "experimental"
usethis::use_lifecycle_badge("experimental")

# Use testthat for testing workflow
usethis::use_testthat()
