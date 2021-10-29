#' Build the SQLite database
#'
#' This function uses the CSV files provided by ISARIC to build a SQLite database
#' of tables, where each table will be named after the first two letters of the
#' corresponding CSV file, e.g., DM, DS, LB, HO, etc. This function can take
#' some time to execute, e.g., 20 minutes.
#'
#' @param csv_folder the location of the CSV files provided by ISARIC. This
#' should contain the CSV files from a single release only, and should not
#' contain any CSV files other than those CSV files. Also, there should be no two
#' CSV files whose names starts with the same first two letters.
#' @param sql_folder the location to save the SQLite database. Defaults to
#' `csv_folder`.
#' @param sql_filename the filename to use for the SQLite database, that will
#' be saved in `sql_folder`.
#' @param vroom_guess_max the maximum number of rows to use for gussing data types
#' in [vroom::vroom()] (when reading CSVs).
#' @param overwrite logical where `TRUE` causes the function to
#' overwrite existing tables with the same name in the SQLite database if it
#' exists already.
#' @param ... optional arguments passed to [DBI::dbWriteTable()].
#'
#' @return
#' The function returns `TRUE`, after creating the SQLite database
#' in the folder `sql_folder`. Returns `FALSE` if all tables
#' already exist and `overwrite=FALSE`.
#'
#' @examples
#'
#' build_sqlite(csv_folder=DIRS$data)
#'
#' @export
#' @md
build_sqlite <- function(csv_folder, sql_folder=csv_folder,
                         sql_filename="db.sqlite",
                         vroom_guess_max=1e5,
                         overwrite=F,
                         ...) {

  message("Building database. Please be patient. This can take up to 20 minutes.")

  # Get file and table names
  csv_filenames_short <- list.files(csv_folder) %>%
    stringr::str_subset("\\.csv")
  csv_filenames <- list.files(csv_folder, full.names=T) %>%
    stringr::str_subset("\\.csv")
  table_names <- csv_filenames_short %>%
    stringr::str_sub(1,2) %>% toupper()
  if (any(duplicated(table_names))) {
    stop("There should be no two CSV files, in csv_folder,",
         " whose names starts with the same first two letters.")
  }

  # Open database connection
  con <- DBI::dbConnect(RSQLite::SQLite(), paste0(sql_folder,"\\", sql_filename))

  if (!overwrite) {
    exist_tables <- DBI::dbListTables(con)
    exists <- table_names %in% exist_tables
    if (all(exists)) DBI::dbDisconnect(con); return(FALSE)
    table_names <- table_names[!exists]
    csv_filenames <- csv_filenames[!exists]
  }

  for (i in 1:length(csv_filenames)) {
    message("Processing table ",table_names[i])

    # Load csv file
    csv_dat_i <- vroom::vroom(
      csv_filenames[i], skip_empty_rows = F, guess_max = vroom_guess_max,
      show_col_types = F)

    # Write table to database
    DBI::dbWriteTable(
      con, table_names[i], csv_dat_i, ...)
    rm(csv_dat_i)
  }
  DBI::dbDisconnect(con)

  return(TRUE)
}

