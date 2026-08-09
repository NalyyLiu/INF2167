# 04_clean_control_variables.R
#
# Purpose:
# Clean GDP per capita data and create a regional control variable.
#
# Input:
# data/raw/WB_WDI_NY_GDP_PCAP_CD.csv
#
# Output:
# data/analysis/gdp_per_capita_clean.csv

library(tidyverse)
library(here)
library(countrycode)


# 1. Load raw GDP per capita data

gdp_raw <- read_csv(
  here("data", "raw", "WB_WDI_NY_GDP_PCAP_CD.csv"),
  show_col_types = FALSE
)


# 2. Clean GDP per capita data and create region

gdp_clean <- gdp_raw |>
  filter(
    TIME_PERIOD >= 2007,
    TIME_PERIOD <= 2017
  ) |>
  transmute(
    country_code = REF_AREA,
    year = as.integer(TIME_PERIOD),
    gdp_per_capita = as.numeric(OBS_VALUE)
  ) |>
  filter(
    !is.na(country_code),
    !is.na(year),
    !is.na(gdp_per_capita),
    gdp_per_capita > 0
  ) |>
  mutate(
    log_gdp_per_capita = log(gdp_per_capita),
    region = countrycode(
      country_code,
      origin = "iso3c",
      destination = "region"
    )
  )


# 3. Check unmatched region codes

unmatched_regions <- gdp_clean |>
  filter(is.na(region)) |>
  distinct(country_code) |>
  arrange(country_code)

if (nrow(unmatched_regions) > 0) {
  message(
    "The following country codes could not be matched to a region:"
  )
  print(unmatched_regions)
} else {
  message("All country codes were successfully matched to a region.")
}


# 4. Remove observations without a valid region

gdp_clean <- gdp_clean |>
  filter(!is.na(region))


# 5. Check duplicate country-year observations

gdp_duplicates <- gdp_clean |>
  count(country_code, year) |>
  filter(n > 1)

if (nrow(gdp_duplicates) > 0) {
  stop("Duplicate country-year observations remain in the GDP dataset.")
}


# 6. Create output directory

dir.create(
  here("data", "analysis"),
  recursive = TRUE,
  showWarnings = FALSE
)


# 7. Save cleaned control-variable dataset

write_csv(
  gdp_clean,
  here(
    "data",
    "analysis",
    "gdp_per_capita_clean.csv"
  )
)

message(
  "GDP per capita data cleaned successfully: ",
  nrow(gdp_clean),
  " observations across ",
  n_distinct(gdp_clean$country_code),
  " country codes."
)
