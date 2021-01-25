library(yotover)

# data ----

ch1_application2_2 <- yotov_data("ch1_application2") %>%
  # this filter covers both OLS and PPML
  filter(year %in% seq(1986, 2006, 4)) %>%
  mutate(
    # variables for both OLS and PPML
    exp_year = paste0(exporter, year),
    imp_year = paste0(importer, year),
    year = paste0("log_dist_", year),
    log_trade = log(trade),
    log_dist = log(dist),

    # PPML specific variables
    smctry = ifelse(importer != exporter, 0, 1),
    log_dist_intra = log_dist * smctry,
    intra_pair = ifelse(exporter == importer, exporter, "inter")
  ) %>%
  spread(year, log_dist, fill = 0) %>%
  mutate(across(log_dist_1986:log_dist_2006, ~ .x * (1 - smctry)))

# ols ----

ch1_app2_ols <- yotov_model_summary2(
  formula = "log_trade ~ 0 + log_dist_1986 + log_dist_1990 + log_dist_1994 +
    log_dist_1998 + log_dist_2002 + log_dist_2006 + cntg +
    lang + clny + exp_year + imp_year",
  data = filter(ch1_application2_2, importer != exporter, trade > 0),
  method = "lm"
)

# ppml ----

ch1_app2_ppml <- yotov_model_summary2(
  formula = "trade ~ 0 + log_dist_1986 + log_dist_1990 +
    log_dist_1994 + log_dist_1998 + log_dist_2002 + log_dist_2006 +
    cntg + lang + clny + exp_year + imp_year",
  data = filter(ch1_application2_2, importer != exporter),
  method = "lm"
)

# internal distance ----

ch1_app2_intra <- yotov_model_summary2(
  formula = "trade ~ 0 + log_dist_1986 + log_dist_1990 +
    log_dist_1994 + log_dist_1998 + log_dist_2002 + log_dist_2006 +
    cntg + lang + clny + exp_year + imp_year + log_dist_intra",
  data = ch1_application2_2,
  method = "glm"
)

# internal distance and home bias ----

ch1_app2_home <- yotov_model_summary2(
  formula = "trade ~ 0 + log_dist_1986 + log_dist_1990 +
    log_dist_1994 + log_dist_1998 + log_dist_2002 + log_dist_2006 +
    cntg + lang + clny + exp_year + imp_year + log_dist_intra + smctry",
  data = ch1_application2_2,
  method = "glm"
)

# fe ----

ch1_app2_fe <- yotov_model_summary2(
  formula = "trade ~ 0 + log_dist_1986 + log_dist_1990 +
    log_dist_1994 + log_dist_1998 + log_dist_2002 + log_dist_2006 +
    cntg + lang + clny + exp_year + imp_year + intra_pair",
  data = ch1_application2_2,
  method = "glm"
)