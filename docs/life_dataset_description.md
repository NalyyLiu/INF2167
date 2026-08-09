# Life Expectancy Dataset

## Source

World Bank Data360

Indicator ID

WEF_GCIHH_LIFEEXPECT

## Description

This dataset reports life expectancy measured in years for individual countries.

## Variables Used

- REF_AREA
- TIME_PERIOD
- OBS_VALUE
- UNIT_MEASURE

## Cleaning Steps

- restricted to 2007–2017
- retained observations measured in years
- removed missing values
- standardized ISO3 country codes

## Output

data/analysis/life_expectancy_clean.csvlife_dataset_description