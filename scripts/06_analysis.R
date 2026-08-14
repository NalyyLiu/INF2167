# ============================================================
# INF2167 Final Project
# Script 06: Regression Analysis
# Input : data/analysis/final_analysis.csv
# Output: output/tables/table1_summary_stats.csv
#         output/tables/table2_regression_coefficients.csv
#         output/figures/fig1_expenditure_distribution.png
#         output/figures/fig2_scatter_fitted.png
#         output/figures/fig3_region_boxplot.png
#         output/figures/fig4_diagnostics.png
#         output/results_summary.txt
#
# Run from the repository root (open INF2167.Rproj first):
#   source("scripts/06_analysis.R")
# ============================================================

library(tidyverse)
library(here)
library(broom)

dir.create(here("output", "figures"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "tables"),  recursive = TRUE, showWarnings = FALSE)

theme_set(theme_minimal(base_size = 12))


# ---- 1. Load the final analysis dataset --------------------------------

analysis_data <- read_csv(
  here("data", "analysis", "final_analysis.csv"),
  show_col_types = FALSE
)

model_data <- analysis_data |>
  mutate(
    year_c = year - 2007,                                  # intercept at 2007
    region = fct_relevel(factor(region), "Europe & Central Asia")
  )

message("Observations: ", nrow(model_data),
        " | Countries: ", n_distinct(model_data$country_code))


# ---- 2. Table 1: Summary statistics ------------------------------------

table1 <- model_data |>
  select(life_expectancy, health_expenditure_gdp,
         gdp_per_capita, log_gdp_per_capita) |>
  pivot_longer(everything(), names_to = "variable", values_to = "value") |>
  group_by(variable) |>
  summarise(
    n      = n(),
    mean   = mean(value),
    sd     = sd(value),
    min    = min(value),
    median = median(value),
    max    = max(value),
    .groups = "drop"
  ) |>
  mutate(across(where(is.numeric), \(x) round(x, 2)))

write_csv(table1, here("output", "tables", "table1_summary_stats.csv"))
print(table1)


# ---- 3. Figure 1: Distribution of health expenditure -------------------

fig1 <- ggplot(model_data, aes(x = health_expenditure_gdp)) +
  geom_histogram(bins = 30, fill = "steelblue", colour = "white") +
  labs(
    title = "Distribution of government health expenditure",
    x = "Government health expenditure (% of GDP)",
    y = "Count"
  )

ggsave(here("output", "figures", "fig1_expenditure_distribution.png"),
       fig1, width = 7, height = 4.5, dpi = 300)


# ---- 4. Figure 2: Scatterplot with fitted line -------------------------

fig2 <- ggplot(model_data,
               aes(x = health_expenditure_gdp, y = life_expectancy)) +
  geom_point(alpha = 0.35, colour = "grey30") +
  geom_smooth(method = "lm", formula = y ~ x, colour = "firebrick") +
  labs(
    title = "Life expectancy and government health expenditure",
    x = "Government health expenditure (% of GDP)",
    y = "Life expectancy (years)"
  )

ggsave(here("output", "figures", "fig2_scatter_fitted.png"),
       fig2, width = 7, height = 4.5, dpi = 300)


# ---- 5. Figure 3: Regional comparison ----------------------------------

fig3 <- ggplot(model_data,
               aes(x = fct_reorder(region, life_expectancy, .fun = median),
                   y = life_expectancy)) +
  geom_boxplot(fill = "lightsteelblue") +
  coord_flip() +
  labs(
    title = "Life expectancy by region",
    x = NULL,
    y = "Life expectancy (years)"
  )

ggsave(here("output", "figures", "fig3_region_boxplot.png"),
       fig3, width = 7, height = 4.5, dpi = 300)


# ---- 6. Regression models ----------------------------------------------

# Model 1: simple linear regression
model1 <- lm(life_expectancy ~ health_expenditure_gdp, data = model_data)

# Model 2: multiple linear regression
model2 <- lm(life_expectancy ~ health_expenditure_gdp + log_gdp_per_capita +
               region + year_c, data = model_data)

summary(model1)
summary(model2)

# Which control changes the coefficient? Add each one separately.
model_year   <- lm(life_expectancy ~ health_expenditure_gdp + year_c,
                   data = model_data)
model_region <- lm(life_expectancy ~ health_expenditure_gdp + region,
                   data = model_data)
model_gdp    <- lm(life_expectancy ~ health_expenditure_gdp + log_gdp_per_capita,
                   data = model_data)

# Does adding the controls improve the model?
model_comparison <- anova(model1, model2)
print(model_comparison)


# ---- 7. Table 2: Regression coefficients -------------------------------

table2 <- bind_rows(
  tidy(model1, conf.int = TRUE) |> mutate(model = "Model 1"),
  tidy(model2, conf.int = TRUE) |> mutate(model = "Model 2")
) |>
  transmute(
    model,
    term,
    estimate  = round(estimate, 3),
    std_error = round(std.error, 3),
    statistic = round(statistic, 2),
    p_value   = signif(p.value, 3),
    conf_low  = round(conf.low, 3),
    conf_high = round(conf.high, 3)
  )

write_csv(table2, here("output", "tables", "table2_regression_coefficients.csv"))
print(table2, n = Inf)


# ---- 8. Figure 4: Model 2 diagnostics ----------------------------------

diagnostics <- augment(model2)

fig4a <- ggplot(diagnostics, aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.35, colour = "grey30") +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "firebrick") +
  labs(title = "Residuals vs fitted values",
       x = "Fitted values", y = "Residuals")

ggsave(here("output", "figures", "fig4_diagnostics.png"),
       fig4a, width = 7, height = 4.5, dpi = 300)

# Multicollinearity check: correlation between the two continuous predictors
predictor_correlation <- cor(model_data$health_expenditure_gdp,
                             model_data$log_gdp_per_capita)

# Influential observations: Cook's distance above the 4/n rule of thumb
influential <- diagnostics |>
  mutate(row_id = row_number()) |>
  filter(.cooksd > 4 / nrow(model_data)) |>
  arrange(desc(.cooksd))

influential_labelled <- model_data |>
  mutate(row_id = row_number()) |>
  select(row_id, country, year, health_expenditure_gdp, life_expectancy) |>
  inner_join(influential |> select(row_id, .cooksd), by = "row_id") |>
  arrange(desc(.cooksd))

print(head(influential_labelled, 10))

# Sensitivity: refit Model 2 without the influential observations
model2_sensitivity <- lm(
  life_expectancy ~ health_expenditure_gdp + log_gdp_per_capita +
    region + year_c,
  data = model_data |> mutate(row_id = row_number()) |>
    filter(!row_id %in% influential_labelled$row_id)
)


# ---- 9. Results summary ------------------------------------------------

sink(here("output", "results_summary.txt"))

cat("INF2167 Final Project: Regression Results\n")
cat("Observations:", nrow(model_data),
    "| Countries:", n_distinct(model_data$country_code), "\n\n")

cat("SUMMARY STATISTICS\n")
print(as.data.frame(table1))

cat("\n\nMODEL 1: life_expectancy ~ health_expenditure_gdp\n")
print(summary(model1))

cat("\n\nMODEL 2: + log_gdp_per_capita + region + year_c\n")
print(summary(model2))

cat("\n\nMODEL COMPARISON\n")
print(model_comparison)

cat("\n\nEFFECT OF EACH CONTROL ON THE HEALTH EXPENDITURE COEFFICIENT\n")
cat("  Model 1 (no controls)  :",
    round(coef(model1)[["health_expenditure_gdp"]], 4), "\n")
cat("  + year only            :",
    round(coef(model_year)[["health_expenditure_gdp"]], 4), "\n")
cat("  + region only          :",
    round(coef(model_region)[["health_expenditure_gdp"]], 4), "\n")
cat("  + log GDP only         :",
    round(coef(model_gdp)[["health_expenditure_gdp"]], 4), "\n")
cat("  Model 2 (all controls) :",
    round(coef(model2)[["health_expenditure_gdp"]], 4), "\n")

cat("\nCorrelation(health expenditure, log GDP per capita):",
    round(predictor_correlation, 3), "\n")

cat("\nInfluential observations above 4/n:", nrow(influential_labelled), "\n")
print(as.data.frame(head(influential_labelled, 5)))
cat("\nModel 2 coefficient excluding them:",
    round(coef(model2_sensitivity)[["health_expenditure_gdp"]], 4), "\n")

sink()

message("Done. See output/results_summary.txt")
