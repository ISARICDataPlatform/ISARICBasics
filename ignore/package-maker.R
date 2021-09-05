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
usethis::use_package("DBI")
usethis::use_package("RMariaDB")
usethis::use_package("dbplyr")
usethis::use_package("httr")
usethis::use_package("jsonlite")
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

# Experimental test code SQL --------------------------------------------------

load("../R/SQL-Credentials.Rdata")

sql <- charlie_connect_sql(
  sql_username = sql_username,
  sql_password = sql_password)

# This user only has access to view event feedback, so is low risk.
# It is fine to leave these credentials here.
sql <- charlie_connect_sql(
  sql_username = "testuser",
  sql_password = "pi7bfnonf0uzzc8j")

# Get a list of all the R compatible tables (technically Views) available
tables <- charlie_sql_tables(sql)
tables


dplyr::tbl(sql, "R_ContactPI") %>%
  dplyr::select(Email2)


# For each JSON field, include a list of the keys.

get_json_keys(sql, "R_Event")

result$details_JSON_keys[2] %>% jsonlite::fromJSON()


# Use basic dplyr tools https://dbplyr.tidyverse.org/
feedback <- dplyr::tbl(sql, "R_EventFeedback")

feedback %>% dplyr::show_query()

# The output is a connection to the database. View the top few rows:
feedback

# The below summary will also be a connection to the database
summary <- feedback %>%
  dplyr::group_by(eventId) %>%
  dplyr::summarise(avg_satisfaction = mean(satisfaction, na.rm=T)) %>%
  dplyr::arrange(desc(avg_satisfaction))
summary

# Find all eventIds from the Event table where the eventName contains "Julia"
julia <- name_id_search(
  sql, search_string = "Julia", table = "R_Event",
  name_col = "eventName", id_col = "eventId")
julia

## Retrieve event feedback for a specific eventId
event_id <- julia$eventId[2]
# Connect to the EventFeedback table
ef_table <- dplyr::tbl(sql, "R_EventFeedback")
# Collect the feedback by filtering on the eventId
feedback <- ef_table %>%
  dplyr::filter(eventId == event_id) %>%
  dplyr::collect()

# Print all of the feedback
print_event_feedback(feedback)

# com <- feedback$feedback[3]
# unlist(sapply(sapply(com, strwrap), paste0, collapse = "\n "))
#
# stringr::str_remove()

# Plot ratings
feedback %>%
  ggplot2::ggplot(ggplot2::aes(x=factor(satisfaction))) +
  ggplot2::geom_bar() +
  ggplot2::labs(title = "Ratings",
                x = "Satisfaction level (stars)", y = "Count")

# Working with JSON

tables$R_Event %>% stringr::str_subset("_JSON")

event <- dplyr::tbl(sql, "R_Event")

event_details <- event %>%
  dplyr::select(eventId, details_JSON) %>%
  dplyr::collect()

details5 <- event_details$details_JSON[5]
details5 %>% jsonlite::fromJSON() %>% View()

query <- "
SELECT eventId, details->>'$.TimeZone.Name'
FROM Event
LIMIT 10
"
result <- DBI::dbGetQuery(sql, query)

query <- "
SELECT DISTINCT details->>'$.TimeZone.Name'
FROM Event
"
result <- DBI::dbGetQuery(sql, query)


query <- "
SELECT eventId, CAST( details AS CHAR )
FROM Event
LIMIT 10
"
result <- DBI::dbGetQuery(sql, query)


# Experimental test code WA --------------------------------------------------

load("../R/credentials.Rdata")
wa <- charlie_connect_wa(
  ssa_username = username,
  ssa_password = password,
  client_id = client_id,
  client_password = client_password)

# Convert API path to URL
url <- path_url(wa,"/accounts/{accountId}/membershiplevels")

# perform query
response <- httr::GET(url, wa$auth_header)

# Convert response to data.frame
df <- response_df(response)

# Look at the column names
names(df)

# Look at the Name column
df$Name

# Convert response to list instead
lst <- response_ls(response)

# Some queries may require a wait period for retrieval
url <- path_url(wa, "/accounts/{accountId}/contacts")
temp <- httr::GET(url, wa$auth_header)
Sys.sleep(60) # wait a minute for server to process request
result <- httr::GET(httr::content(temp)$ResultUrl, wa$auth_header)
df <- response_df(result)
contacts <- df$Contacts # data.frame nested within a data.frame

# Get every value of every custom field with given field name, and make a table
name <- "Suburb/City"
contacts$FieldValues %>%
  purrr::map(~.x %>% dplyr::filter(FieldName == name) %>% .$Value) %>%
  unlist %>% tolower %>% table

# Get every contact named TEST ADMIN
test_Id <- contacts %>% dplyr::filter(FirstName == "TEST ADMIN") %>% dplyr::pull(Id)

# These are some API paths
p0 <- "/accounts"
p1 <- "/accounts/{accountId}/contacts"
p2 <- "/accounts/{accountId}/contacts/{var}/thing"

# URL parameters appearing above in { } must be specified
path_url(wa, p0)
path_url(wa, p1)
path_url(wa, p2, var=123)
path_url(wa, p2, var=123)
path_url(wa, p2, accountId=456, var=123)

# Query parameters can be specified using a named list
path_url(wa, p2, accountId=456, var=123,
         query_params=list(p1="true",p2="false"))


# Setting contact ---------------------------------------------------------

# Get my ID
url <- path_url(wa, "/accounts/{accountId}/contacts/me")
response <- httr::GET(url, wa$auth_header)
l <- response_ls(response)
my_id <- l$Id

# Use my ID to retrieve my contact info
url <- path_url(wa, "/accounts/{accountId}/contacts/{contactId}", contactId = my_id)
response <- httr::GET(url, wa$auth_header)
l <- response_ls(response)

# This is the Id of the TEST ADMIN contact
test_Id <- "60973421"

# Retrieve TEST ADMIN contact info
url <- path_url(wa, "/accounts/{accountId}/contacts/{contactId}", contactId = test_Id)
response <- httr::GET(url, wa$auth_header)
contact_data <- httr::content(response,'text')
cat(contact_data)


# Update TEST ADMIN contact info
contact_data <- '{
  "FirstName": "TEST ADMIN",
  "LastName": "TEST ADMIN",
  "Organization": "TEST ADMIN",
  "Email": "daniel-fryer@live.com.au",
  "Id": 60973421
}'


url <- path_url(wa, "/accounts/{accountId}/contacts/{contactId}", contactId = test_Id)
response <- httr::PUT(
  url, wa$auth_header,
  body= list(contact = list(ID = 60973421)), httr::verbose(), encode="json"
  # ,httr::add_headers(
  #   'Content-Type' = 'application/json',
  #   'Accept' = 'application/json')
  ) #as.character(jsonlite::toJSON(l))


my_request <- httr::PUT(url,
                        body = ,
                        httr::add_headers(
                          'X-login-Key' = '12345678',
                          'OS-Version' = 'iOS 10.3.1',
                          'User-Agent' = 'company/1.2.3.456',
                          'Content-Type' = 'application/json',
                          'X-Access-Token' = 'dkdfjueek12384kdndcos/da8L9u0=',
                          'Nonce' = '1',
                          'Accept' = 'application/json'), encode = "json")


