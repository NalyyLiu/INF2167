health_dataset_description
# IMF Government Expenditure on Health Dataset

## Source

World Bank Data360

Original data provider: International Monetary Fund (IMF)

Indicator ID:
IMF_COFOG_GEL_GF07

## Description

This dataset reports general government expenditure on health as a percentage of GDP.

The archived 2007–2017 dataset retained during the proposal stage is used in this project because the historical observations are no longer publicly accessible through the current World Bank Data360 and IMF interfaces.

## Variables Used

- REF_AREA
- TIME_PERIOD
- OBS_VALUE
- UNIT_MEASURE
- COMP_BREAKDOWN_1

## Cleaning Steps

- restricted to 2007–2017
- retained PT_GDP observations
- retained IMF_SEC_GG observations
- removed missing values
- standardized ISO3 country codes

## Output

data/analysis/health_expenditure_clean.csv