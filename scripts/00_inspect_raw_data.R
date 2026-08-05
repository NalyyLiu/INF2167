library(tidyverse)
library(here)
library(janitor)

health_raw <- read_csv(
  here("data", "raw", "IMF_COFOG_GEL_GF07.csv"),
  show_col_types = FALSE
)

life_raw <- read_csv(
  here("data", "raw", "WEF_GCIHH_LIFEEXPECT.csv"),
  show_col_types = FALSE
)

gdp_raw <- read_csv(
  here("data", "raw", "WB_WDI_NY_GDP_PCAP_CD.csv"),
  show_col_types = FALSE
)

# Column names
names(health_raw)
names(life_raw)
names(gdp_raw)

# Structure and sample values
glimpse(health_raw)
glimpse(life_raw)
glimpse(gdp_raw)

# Number of rows and columns
dim(health_raw)
dim(life_raw)
dim(gdp_raw)