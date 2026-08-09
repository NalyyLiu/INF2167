# GDP per Capita Dataset

## Source

World Bank Data360

World Development Indicators (WDI)

Indicator ID:
WB_WDI_NY_GDP_PCAP_CD

## Description

This dataset reports GDP per capita (current US dollars) for individual countries.

## Variables Used

- REF_AREA
- TIME_PERIOD
- OBS_VALUE

## Cleaning Steps

- restricted to 2007–2017
- retained positive GDP per capita values
- removed missing values
- calculated log GDP per capita
- standardized ISO3 country codes
- generated region using the countrycode package

## Output

data/analysis/gdp_per_capita_clean.csv