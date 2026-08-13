# INF2167 Final Project

## Project Title

**Government Health Expenditure and Life Expectancy: A Cross-Country Analysis (2007–2017)**

---

# Research Questions

**RQ1:** How is government health expenditure associated with life expectancy across countries from 2007 to 2017?

**RQ2:** Does the relationship between government healthcare expenditure and life expectancy remain after accounting for GDP per capita, regional differences, and changes over time?

---

# Repository Structure

```
project-root/
├── data/
│   ├── raw/                  # Original datasets
│   └── analysis/             # Cleaned datasets
├── scripts/
│   ├── 00_inspect_raw_data.R
│   ├── 01_download_data.R
│   ├── 02_clean_health_expenditure.R
│   ├── 03_clean_life_expectancy.R
│   ├── 04_clean_control_variables.R
│   ├── 05_merge_data.R
│   └── 06_analysis.R
├── docs/                     # Dataset documentation
│   ├── health_dataset_description.md
│   ├── life_dataset_description.md
│   └── gdp_dataset_description.md
├── output/
│   ├── figures/              # Figures 1 to 4
│   └── tables/               # Tables used in the report
├── archive/                  # Earlier working files
├── Final_project/            # Proposal stage materials
├── final_report.qmd
├── final_report.pdf
├── references.bib
├── README.md
└── INF2167.Rproj
```

---

# Data Sources

This project uses three datasets.

## 1. Government Health Expenditure

| Item | Description |
|------|-------------|
| Source | World Bank Data360 |
| Original source organization | International Monetary Fund (IMF) |
| Database | IMF Government Finance Statistics (IMF_GFS_COFOG) |
| Indicator | Government Expenditure on Health |
| Indicator ID | IMF_COFOG_GEL_GF07 |
| Time period | 2007–2017 |
| Variable used | General government expenditure on health (% of GDP) |
| Role in analysis | Primary independent variable |
| Original retrieval date | 2026-06-18 |

Original indicator page (proposal stage):

https://data360.worldbank.org/en/indicator/IMF_COFOG_GEL_GF07

---

## 2. Life Expectancy

| Item | Description |
|------|-------------|
| Source | World Bank Data360 |
| Database | WEF_GCIHH |
| Indicator | Life Expectancy, Years |
| Indicator ID | WEF_GCIHH_LIFEEXPECT |
| Time period | 2007–2017 |
| Variable used | Life expectancy measured in years |
| Role in analysis | Dependent variable |
| Retrieval method | Automatically downloaded using `scripts/01_download_data.R` |
| API endpoint | https://data360api.worldbank.org/data360/data |
| URL | https://data360.worldbank.org/en/indicator/WEF_GCIHH_LIFEEXPECT |

Query parameters:

- DATABASE_ID = WEF_GCIHH
- INDICATOR = WEF_GCIHH_LIFEEXPECT
- timePeriodFrom = 2007
- timePeriodTo = 2017

---

## 3. GDP per Capita

| Item | Description |
|------|-------------|
| Source | World Bank Data360 (World Development Indicators) |
| Database | WB_WDI |
| Indicator | GDP per capita (current US$) |
| Indicator ID | WB_WDI_NY_GDP_PCAP_CD |
| Time period | 2007–2017 |
| Variable used | GDP per capita |
| Role in analysis | Control variable |
| Retrieval method | Automatically downloaded using `scripts/01_download_data.R` |
| API endpoint | https://data360api.worldbank.org/data360/data |
| URL | https://data360.worldbank.org/en/indicator/WB_WDI_NY_GDP_PCAP_CD |

Query parameters:

- DATABASE_ID = WB_WDI
- INDICATOR = WB_WDI_NY_GDP_PCAP_CD
- timePeriodFrom = 2007
- timePeriodTo = 2017

---

# Data Availability

The original Government Health Expenditure dataset (IMF_COFOG_GEL_GF07, 2007–2017) was downloaded during the proposal stage.

During preparation of the final project, we attempted to reproduce the original download process using both the World Bank Data360 platform and the IMF Government Finance Statistics (GFS) Data Explorer.

To verify whether the historical dataset was still publicly available, we:

- located the updated World Bank Data360 indicator page;
- confirmed that the currently available release only contains observations from 2017–2025;
- queried the official Data360 API using the original indicator ID (`IMF_COFOG_GEL_GF07`);
- queried the API using the original study period (2007–2017);
- confirmed that the API returned zero historical observations (`count = 0`);
- checked the IMF Government Finance Statistics (GFS) Data Explorer and confirmed that historical observations are no longer publicly accessible.

Following instructor approval, this project therefore uses the archived CSV downloaded during the proposal stage.

The archived dataset is stored in:

```
data/raw/IMF_COFOG_GEL_GF07.csv
```

Although the original historical dataset is no longer publicly downloadable, the archived CSV, original indicator information, retrieval process, verification steps, and all data cleaning scripts are included in this repository to ensure that the complete analytical workflow remains transparent and reproducible.

---

# Original Health Dataset Retrieval Process

During the proposal stage, the dataset was obtained through the World Bank Data360 portal by:

1. locating the indicator **IMF_COFOG_GEL_GF07**;
2. selecting the **Government Expenditure on Health** indicator;
3. filtering observations for the required study period (2007–2017);
4. downloading the dataset as a CSV file;
5. storing the downloaded file as an archived copy;
6. cleaning and processing the dataset using R.

Although the original download page is no longer publicly accessible, the original indicator ID, source information, retrieval date, archived dataset, and verification process have been preserved in this repository.

---

# Additional Explanatory Variables

Following instructor feedback, two additional explanatory variables were incorporated into the regression analysis.

### GDP per capita

GDP per capita was included as a control variable because national income levels are strongly associated with both government healthcare expenditure and life expectancy. Including GDP per capita helps distinguish the relationship between healthcare expenditure and life expectancy from broader differences in economic development.

### Region

Region was generated from ISO3 country codes using the `countrycode` R package. Regional classifications help account for geographic differences in healthcare systems, economic development, and population characteristics that may influence life expectancy independently of government healthcare expenditure.

---

# Reproducibility

## Required packages

```r
install.packages(c("tidyverse", "here", "janitor", "httr2",
                   "countrycode", "broom", "knitr"))
```

## Running the workflow

Open `INF2167.Rproj` first so that file paths resolve correctly, then run the scripts in the following order:

```r
source("scripts/01_download_data.R")
source("scripts/02_clean_health_expenditure.R")
source("scripts/03_clean_life_expectancy.R")
source("scripts/04_clean_control_variables.R")
source("scripts/05_merge_data.R")
source("scripts/06_analysis.R")
```

`06_analysis.R` produces all figures and tables used in the report and writes them to `output/figures/` and `output/tables/`. The report is then rendered from `final_report.qmd`, which reads those output files rather than re-running the analysis.

---

# Final Analytical Dataset

After cleaning and merging the three datasets:

| Stage | Observations | Countries |
|--------|------------:|----------:|
| Clean health expenditure data | 673 | 75 |
| Clean life expectancy data | 1524 | 152 |
| Clean GDP per capita data | 2301 | 211 |
| Health and life expectancy merged | 601 | 64 |
| Final complete-case analysis data | **601** | **64** |

The final analytical dataset contains:

- 601 country-year observations;
- 64 countries;
- study period from 2007 to 2017;
- no duplicate country-year observations;
- no missing values in the final analytical dataset.

Key variables include:

- country_code
- country
- year
- health_expenditure_gdp
- life_expectancy
- gdp_per_capita
- log_gdp_per_capita
- region

---

# Main Finding

In the unadjusted model, government healthcare expenditure is positively and significantly associated with life expectancy, with a coefficient of 1.231 (p < 0.001). After controlling for log GDP per capita, region, and year, the coefficient falls to 0.092 and is no longer statistically significant (p = 0.193). Adding each control separately shows that this change is driven almost entirely by GDP per capita rather than by region or year.

---

# Limitations

GDP per capita and region were included as additional explanatory variables to improve the regression model. However, life expectancy is also influenced by many other factors, including education, healthcare system quality, demographic characteristics, public health policies, and lifestyle factors. These variables are not fully captured in the current model and should be considered when interpreting the results.

The regional groups are also unevenly sized, and the sample is limited to the 64 countries with complete data across all three sources, which restricts how far the findings can be generalized.
