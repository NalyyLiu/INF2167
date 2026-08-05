# 05_merge_data.R
#
# Purpose:
# Merge the cleaned health expenditure, life expectancy,
# and GDP per capita datasets into one country-year analysis dataset.
#
# Inputs:
# data/analysis/health_expenditure_clean.csv
# data/analysis/life_expectancy_clean.csv
# data/analysis/gdp_per_capita_clean.csv
#
# Outputs:
# data/analysis/final_analysis.csv
# output/tables/data_merge_summary.csv

library(tidyverse)
library(here)


# 1. Load cleaned datasets

health <- read_csv(
  here(
    "data",
    "analysis",
    "health_expenditure_clean.csv"
  ),
  show_col_types = FALSE
)

life <- read_csv(
  here(
    "data",
    "analysis",
    "life_expectancy_clean.csv"
  ),
  show_col_types = FALSE
)

gdp <- read_csv(
  here(
    "data",
    "analysis",
    "gdp_per_capita_clean.csv"
  ),
  show_col_types = FALSE
)


# 2. Check that each dataset has one row per country-year

health_duplicates <- health |>
  count(country_code, year) |>
  filter(n > 1)

life_duplicates <- life |>
  count(country_code, year) |>
  filter(n > 1)

gdp_duplicates <- gdp |>
  count(country_code, year) |>
  filter(n > 1)

if (nrow(health_duplicates) > 0) {
  stop("Duplicate country-year observations found in health data.")
}

if (nrow(life_duplicates) > 0) {
  stop("Duplicate country-year observations found in life expectancy data.")
}

if (nrow(gdp_duplicates) > 0) {
  stop("Duplicate country-year observations found in GDP data.")
}


# 3. Merge health expenditure and life expectancy

health_life <- health |>
  inner_join(
    life,
    by = c("country_code", "year"),
    relationship = "one-to-one"
  )


# 4. Add GDP per capita and region

final_analysis <- health_life |>
  left_join(
    gdp,
    by = c("country_code", "year"),
    relationship = "one-to-one"
  ) |>
  arrange(country_code, year)


# 5. Check the merged dataset

final_duplicates <- final_analysis |>
  count(country_code, year) |>
  filter(n > 1)

if (nrow(final_duplicates) > 0) {
  stop("Duplicate country-year observations remain after merging.")
}

missing_summary <- final_analysis |>
  summarise(
    missing_health_expenditure =
      sum(is.na(health_expenditure_gdp)),
    missing_life_expectancy =
      sum(is.na(life_expectancy)),
    missing_gdp_per_capita =
      sum(is.na(gdp_per_capita)),
    missing_log_gdp_per_capita =
      sum(is.na(log_gdp_per_capita)),
    missing_region =
      sum(is.na(region))
  )

print(missing_summary)


# 6. Create complete-case analysis dataset

final_analysis_complete <- final_analysis |>
  filter(
    !is.na(health_expenditure_gdp),
    !is.na(life_expectancy),
    !is.na(gdp_per_capita),
    !is.na(log_gdp_per_capita),
    !is.na(region)
  )


# 7. Create output directories if needed

dir.create(
  here("data", "analysis"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  here("output", "tables"),
  recursive = TRUE,
  showWarnings = FALSE
)


# 8. Save final analysis dataset

write_csv(
  final_analysis_complete,
  here(
    "data",
    "analysis",
    "final_analysis.csv"
  )
)


# 9. Create and save merge summary

merge_summary <- tibble(
  stage = c(
    "Clean health expenditure data",
    "Clean life expectancy data",
    "Clean GDP per capita data",
    "Health and life expectancy merged",
    "Final complete-case analysis data"
  ),
  observations = c(
    nrow(health),
    nrow(life),
    nrow(gdp),
    nrow(health_life),
    nrow(final_analysis_complete)
  ),
  countries = c(
    n_distinct(health$country_code),
    n_distinct(life$country_code),
    n_distinct(gdp$country_code),
    n_distinct(health_life$country_code),
    n_distinct(final_analysis_complete$country_code)
  )
)

write_csv(
  merge_summary,
  here(
    "output",
    "tables",
    "data_merge_summary.csv"
  )
)

print(merge_summary)


# 10. Final checks

message(
  "Final analysis dataset created successfully: ",
  nrow(final_analysis_complete),
  " observations across ",
  n_distinct(final_analysis_complete$country_code),
  " countries."
)

message(
  "Year range: ",
  min(final_analysis_complete$year),
  " to ",
  max(final_analysis_complete$year)
)