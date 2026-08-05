# 03_clean_life_expectancy.R
#
# Purpose:
# Clean the WEF life expectancy dataset.
#
# Input:
# data/raw/WEF_GCIHH_LIFEEXPECT.csv
#
# Output:
# data/analysis/life_expectancy_clean.csv

library(tidyverse)
library(here)

# Load raw life expectancy data
life_raw <- read_csv(
  here("data", "raw", "WEF_GCIHH_LIFEEXPECT.csv"),
  show_col_types = FALSE
)

# Keep life expectancy measured in years rather than rankings
life_clean <- life_raw |>
  filter(
    UNIT_MEASURE == "YR",
    TIME_PERIOD >= 2007,
    TIME_PERIOD <= 2017
  ) |>
  transmute(
    country_code = REF_AREA,
    year = as.integer(TIME_PERIOD),
    life_expectancy = as.numeric(OBS_VALUE)
  ) |>
  filter(
    !is.na(country_code),
    !is.na(year),
    !is.na(life_expectancy)
  ) |>
  arrange(country_code, year)

# Check that every country-year appears only once
life_duplicates <- life_clean |>
  count(country_code, year) |>
  filter(n > 1)

if (nrow(life_duplicates) > 0) {
  stop("Duplicate country-year observations remain in the life expectancy dataset.")
}

dir.create(
  here("data", "analysis"),
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  life_clean,
  here(
    "data",
    "analysis",
    "life_expectancy_clean.csv"
  )
)

message(
  "Life expectancy data cleaned successfully: ",
  nrow(life_clean),
  " observations across ",
  n_distinct(life_clean$country_code),
  " countries."
)