# 02_clean_health_expenditure.R
#
# Purpose:
# Clean the archived IMF government health expenditure dataset.
#
# Input:
# data/raw/IMF_COFOG_GEL_GF07.csv
#
# Output:
# data/analysis/health_expenditure_clean.csv

library(tidyverse)
library(here)

# Load archived raw health expenditure data
health_raw <- read_csv(
  here("data", "raw", "IMF_COFOG_GEL_GF07.csv"),
  show_col_types = FALSE
)

# Keep observations measured as a percentage of GDP,
# reported for the general government sector,
# and observed during 2007-2017.
health_clean <- health_raw |>
  filter(
    UNIT_MEASURE == "PT_GDP",
    COMP_BREAKDOWN_1 == "IMF_SEC_GG",
    TIME_PERIOD >= 2007,
    TIME_PERIOD <= 2017
  ) |>
  transmute(
    country_code = REF_AREA,
    country = REF_AREA_LABEL,
    year = as.integer(TIME_PERIOD),
    health_expenditure_gdp = as.numeric(OBS_VALUE)
  ) |>
  filter(
    !is.na(country_code),
    !is.na(year),
    !is.na(health_expenditure_gdp)
  ) |>
  arrange(country_code, year)

# Check that every country-year appears only once
health_duplicates <- health_clean |>
  count(country_code, year) |>
  filter(n > 1)

if (nrow(health_duplicates) > 0) {
  stop("Duplicate country-year observations remain in the health dataset.")
}

# Create the analysis directory if needed
dir.create(
  here("data", "analysis"),
  recursive = TRUE,
  showWarnings = FALSE
)

# Save cleaned dataset
write_csv(
  health_clean,
  here(
    "data",
    "analysis",
    "health_expenditure_clean.csv"
  )
)

message(
  "Health expenditure data cleaned successfully: ",
  nrow(health_clean),
  " observations across ",
  n_distinct(health_clean$country_code),
  " countries."
)