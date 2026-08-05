# 01_download_data.R
#
# Purpose:
# Document and reproduce acquisition of the raw datasets used in the INF2167 final project.
#
# The historical health expenditure release cannot currently be retrieved from the public Data360 or IMF interfaces. The archived CSV retained from the proposal stage is therefore required.

library(here)
library(readr)
library(dplyr)
library(tibble)
library(httr2)

dir.create(
  here("data", "raw"),
  recursive = TRUE,
  showWarnings = FALSE
)

# 1. Archived government health expenditure dataset

health_path <- here(
  "data",
  "raw",
  "IMF_COFOG_GEL_GF07.csv"
)

if (!file.exists(health_path)) {
  stop(
    paste(
      "Archived health expenditure dataset is missing.",
      "Expected file:",
      health_path,
      "See README.md for data availability documentation."
    )
  )
}

message("Archived health expenditure dataset found.")


# Function: Download all pages from the Data360 API

download_data360_all <- function(
    database_id,
    indicator_id,
    time_from,
    time_to
) {
  
  all_data <- tibble::tibble()
  skip_value <- 0
  total_count <- Inf
  
  while (nrow(all_data) < total_count) {
    
    response <- httr2::request(
      "https://data360api.worldbank.org/data360/data"
    ) |>
      httr2::req_url_query(
        DATABASE_ID = database_id,
        INDICATOR = indicator_id,
        timePeriodFrom = time_from,
        timePeriodTo = time_to,
        skip = skip_value
      ) |>
      httr2::req_perform()
    
    if (httr2::resp_status(response) != 200) {
      stop(
        paste(
          "Data360 download failed for",
          indicator_id,
          "at skip =",
          skip_value
        )
      )
    }
    
    response_json <- httr2::resp_body_json(
      response,
      simplifyVector = TRUE
    )
    
    total_count <- as.integer(response_json$count)
    
    page_data <- tibble::as_tibble(
      response_json$value
    )
    
    if (nrow(page_data) == 0) {
      break
    }
    
    all_data <- dplyr::bind_rows(
      all_data,
      page_data
    )
    
    message(
      indicator_id,
      ": downloaded ",
      nrow(all_data),
      " of ",
      total_count,
      " records."
    )
    
    skip_value <- skip_value + nrow(page_data)
  }
  
  if (nrow(all_data) == 0) {
    stop(
      paste(
        "No observations returned for",
        indicator_id
      )
    )
  }
  
  all_data
}

# 2. Download Life Expectancy dataset

life_raw <- download_data360_all(
  database_id = "WEF_GCIHH",
  indicator_id = "WEF_GCIHH_LIFEEXPECT",
  time_from = 2007,
  time_to = 2017
)

readr::write_csv(
  life_raw,
  here::here(
    "data",
    "raw",
    "WEF_GCIHH_LIFEEXPECT.csv"
  )
)

message(
  "Life Expectancy dataset downloaded successfully: ",
  nrow(life_raw),
  " records."
)

# 3. Download GDP per capita dataset

gdp_raw <- download_data360_all(
  database_id = "WB_WDI",
  indicator_id = "WB_WDI_NY_GDP_PCAP_CD",
  time_from = 2007,
  time_to = 2017
)

readr::write_csv(
  gdp_raw,
  here::here(
    "data",
    "raw",
    "WB_WDI_NY_GDP_PCAP_CD.csv"
  )
)

message(
  "GDP per capita dataset downloaded successfully: ",
  nrow(gdp_raw),
  " records."
)