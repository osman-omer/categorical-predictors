# --------------------------------------------------------
# Project: Categorical Predictors and Dummy Variables
# Goal: Understand how categorical variables work in regression
#       and how to interpret dummy variable coefficients
#
# Variables:
#   - Outcome (Y): Charges (USD) — Continuous
#   - Predictors (X): 
#       * Sex (male/female) — Categorical (Binary)
#       * Region (northeast/northwest/southeast/southwest) — Categorical
#
# Key Concepts:
#   1. Dummy variable encoding
#   2. Reference category (baseline)
#   3. Coefficient interpretation
#   4. Baseline comparison
#
# Author: Osman Omer Mustafa (Medical Student & Data Analyst Trainee)
# Date: February 2026
# --------------------------------------------------------

# 0) Load required libraries
library(tidyverse)
library(broom)

# 1) Read data
data <- read_csv("insurance.csv")

# 2) Basic checks
glimpse(data)
summary(data)
sum(is.na(data))

# 3) Ensure categorical variables are factors
data <- data %>% 
  mutate(
    sex = as.factor(sex),
    smoker = as.factor(smoker),
    region = as.factor(region)
  )

glimpse(data)

# --------------------------------------------------------
# EXPLORATORY DATA ANALYSIS
# --------------------------------------------------------

# 4) Summary statistics by sex
summary_sex <- data %>% 
  group_by(sex) %>% 
  summarise(
    n = n(),
    mean_charges = mean(charges),
    sd_charges = sd(charges),
    median_charges = median(charges)
  )
summary_sex

# 5) Summary statistics by region
summary_region <- data %>% 
  group_by(region) %>% 
  summarise(
    n = n(),
    mean_charges = mean(charges),
    sd_charges = sd(charges),
    median_charges = median(charges)
  )
summary_region

# 6) Boxplot: Charges by sex
box_sex <- ggplot(data, aes(x = sex, y = charges, fill = sex)) +
  geom_boxplot() +
  labs(
    x = "Sex",
    y = "Insurance Charges (USD)",
    title = "Insurance Charges by Sex"
  ) +
  theme(legend.position = "none") +
  theme(plot.title = element_text(hjust = 0.5))
box_sex

# 7) Boxplot: Charges by region
box_region <- ggplot(data, aes(x = region, y = charges, fill = region)) +
  geom_boxplot() +
  labs(
    x = "Region",
    y = "Insurance Charges (USD)",
    title = "Insurance Charges by Region"
  ) +
  theme(legend.position = "none") +
  theme(plot.title = element_text(hjust = 0.5))
box_region

# --------------------------------------------------------
# UNDERSTANDING DUMMY VARIABLES
# --------------------------------------------------------

# 8) Check default contrasts (how R encodes categories)
# This shows which category is the baseline (reference)
contrasts(data$sex)
contrasts(data$region)

# 9) Check levels order
levels(data$sex)
levels(data$region)

# --------------------------------------------------------
# MODEL 1: SEX ONLY
# --------------------------------------------------------

# 10) Fit model with sex as predictor
model_sex <- lm(charges ~ sex, data = data)

# 11) Tidy results
tidy_sex <- tidy(model_sex, conf.int = TRUE)
tidy_sex

# 12) Model performance
glance_sex <- glance(model_sex)
glance_sex

# --------------------------------------------------------
# MODEL 2: REGION ONLY
# --------------------------------------------------------

# 13) Fit model with region as predictor
model_region <- lm(charges ~ region, data = data)

# 14) Tidy results
tidy_region <- tidy(model_region, conf.int = TRUE)
tidy_region

# 15) Model performance
glance_region <- glance(model_region)
glance_region

# --------------------------------------------------------
# MODEL 3: SEX + REGION
# --------------------------------------------------------

# 16) Fit model with both predictors
model_both <- lm(charges ~ sex + region, data = data)

# 17) Tidy results
tidy_both <- tidy(model_both, conf.int = TRUE)
tidy_both

# 18) Model performance
glance_both <- glance(model_both)
glance_both

# --------------------------------------------------------
# MODEL COMPARISON
# --------------------------------------------------------

# 19) Compare all three models
anova(model_sex, model_both)
anova(model_region, model_both)

# 20) AIC comparison
AIC(model_sex, model_region, model_both)

# 21) BIC comparison
BIC(model_sex, model_region, model_both)

# --------------------------------------------------------
# CHANGING THE BASELINE (REFERENCE CATEGORY)
# --------------------------------------------------------

# 22) Change baseline for sex to male
data_male_baseline <- data %>%
  mutate(sex = relevel(sex, ref = "male"))

model_sex_male <- lm(charges ~ sex, data = data_male_baseline)
tidy(model_sex_male, conf.int = TRUE)

# 23) Change baseline for region to southwest
data_sw_baseline <- data %>%
  mutate(region = relevel(region, ref = "southwest"))

model_region_sw <- lm(charges ~ region, data = data_sw_baseline)
tidy(model_region_sw, conf.int = TRUE)

# --------------------------------------------------------
# MANUAL DUMMY VARIABLE CREATION (FOR UNDERSTANDING)
# --------------------------------------------------------

# 24) Create dummy variables manually to show what R does internally
data_manual <- data %>%
  mutate(
    # Sex dummies (female = baseline, so only need male)
    male = ifelse(sex == "male", 1, 0),
    
    # Region dummies (assuming northeast = baseline)
    northwest = ifelse(region == "northwest", 1, 0),
    southeast = ifelse(region == "southeast", 1, 0),
    southwest = ifelse(region == "southwest", 1, 0)
  )

# 25) Fit model using manual dummies (should give same results)
model_manual <- lm(charges ~ male + northwest + southeast + southwest, 
                   data = data_manual)
tidy(model_manual, conf.int = TRUE)

# Compare with automatic factor encoding
tidy_both

# --------------------------------------------------------
# VISUALIZATION: COEFFICIENT PLOTS
# --------------------------------------------------------

# Create plots directory if it doesn't exist
if (!dir.exists("plots")) dir.create("plots")

# 26) Coefficient plot for sex model
coef_sex_plot <- tidy_sex %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = term, y = estimate)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  coord_flip() +
  labs(
    x = "Predictor",
    y = "Coefficient Estimate",
    title = "Sex Model: Coefficient with 95% CI"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
coef_sex_plot

ggsave("plots/coef_sex.png", coef_sex_plot, width = 6, height = 4)


# 27) Coefficient plot for region model
coef_region_plot <- tidy_region %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = term, y = estimate)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  coord_flip() +
  labs(
    x = "Predictor",
    y = "Coefficient Estimate",
    title = "Region Model: Coefficients with 95% CI"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))


ggsave("plots/coef_region.png", coef_region_plot, width = 6, height = 4)
coef_region_plot

# 28) Coefficient plot for combined model
coef_both_plot <- tidy_both %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = term, y = estimate)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  coord_flip() +
  labs(
    x = "Predictor",
    y = "Coefficient Estimate",
    title = "Combined Model: Coefficients with 95% CI"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("plots/coef_both.png", coef_both_plot, width = 6, height = 4)
coef_both_plot

# --------------------------------------------------------
# END OF SCRIPT
# --------------------------------------------------------
