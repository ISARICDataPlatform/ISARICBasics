

#' Categorise occurrence of events
#'
#' Use the OCCUR and PRESP columns from the ISARIC
#' [SDTM](https://en.wikipedia.org/wiki/SDTM) data format to derive
#' a column indicating the occurrence status of each event.
#'
#'This function implements the following logic:
#'```
#' xxOCCUR == Y                 -> yes
#' xxOCCUR == NA & xxPRESP != Y -> yes
#' xxOCCUR == N                 -> no
#' xxOCCUR == NA & xxPRESP == Y -> unknown
#' xxOCCUR == U                 -> unknown
#'```
#'
#'@param data a `data.frame` or SQL connection (`tbl_sql`) object
#'@param xxOCCUR the name of OCCUR column (e.g., SAOCCUR or HOOCCUR)
#'@param xxPRESP the name of the PRESP column (e.g., SAPRESP or HOPRESP)
#'@param overwrite a logical value. `TRUE` means the column `status` will
#'be overwritten if already present in `data`. `FALSE` means the function
#'will throw an error if `status` is already present in `data`.
#'
#'@return
#'Returns the `data` argument with an additional column called `status`,
#'having values 'yes', 'no', 'unknown' or 'categorisation failed'.
#'
#'@examples
#'
#' con <- DBI::dbConnect(RSQLite::SQLite(), DIRS$db)
#' ho <- dplyr::tbl(con, "HO")
#' ho_modified <- ho %>%
#'    process_occur(xxOCCUR = HOOCCUR, xxPRESP = HOPRESP)
#'
#' @export
#' @md
process_occur <- function(data, xxOCCUR, xxPRESP, overwrite=F) {
  if (!overwrite) {
    if ("status" %in% colnames(data)) {
      stop("Column 'status' already present in data,",
           " either rename the column or set overwrite=TRUE in",
           " ISARICBasics::process_occur")
    }
  }
  data %>% dplyr::mutate(
    status = dplyr::case_when(
      {{xxOCCUR}} == 'Y' ~ 'yes',
      {{xxOCCUR}} == 'N' ~ 'no',
      is.na({{xxOCCUR}}) & (is.na({{xxPRESP}}) | {{xxPRESP}} != 'Y') ~ 'yes',
      is.na({{xxOCCUR}}) & {{xxPRESP}} == 'Y' ~ 'unknown',
      {{xxOCCUR}} == 'U' ~ 'unknown',
      T ~ "categorisation failed"
    )
  )
}


