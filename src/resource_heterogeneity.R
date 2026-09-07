library(fixest)
setFixest_nthreads(1)
prepared_data <- readRDS("output/prepared.rds")
model <- readRDS("output/limited_models.rds")$T3_1
analysis_data <- model$data
interview_rows <- match(analysis_data$SI, prepared_data$interviews$SI)
analysis_data$upper_background <- as.numeric(prepared_data$interviews$economicbkg[interview_rows] == 1)
stopifnot(!anyNA(analysis_data$upper_background))
heterogeneity_formula <- as.formula(paste(
  "considered ~", paste(c(model$vars, "same_caste_upper", "income_upper"), collapse = " + "), "| SI"
))
fit_heterogeneity <- function(sample_data) {
  income_model <- do.call(lm, list(
    formula = formula(model$first), data = sample_data, weights = sample_data$weight,
    subset = sample_data$noincome_male == 0
  ))
  sample_data$predicted_income <- suppressWarnings(predict(income_model, sample_data))
  sample_data$same_caste_upper <- sample_data$samecaste * sample_data$upper_background
  sample_data$income_upper <- sample_data$predicted_income * sample_data$upper_background
  preference_model <- feols(heterogeneity_formula, sample_data,
    weights = ~weight,
    fixef.rm = "none", vcov = ~SI, notes = FALSE
  )
  coefficients <- coef(preference_model)
  middle_lower_same_caste <- unname(coefficients["samecaste"])
  upper_background_same_caste <- middle_lower_same_caste + unname(coefficients["same_caste_upper"])
  middle_lower_income <- unname(coefficients["predicted_income"])
  upper_income <- middle_lower_income + unname(coefficients["income_upper"])
  c(
    middle_lower_same_caste = middle_lower_same_caste,
    upper_background_same_caste = upper_background_same_caste,
    middle_lower_income = middle_lower_income, upper_income = upper_income,
    same_caste_group_difference = upper_background_same_caste - middle_lower_same_caste,
    income_difference = upper_income - middle_lower_income,
    middle_lower_premium = exp(middle_lower_same_caste / middle_lower_income) - 1,
    upper_premium = exp(upper_background_same_caste / upper_income) - 1,
    premium_difference = exp(upper_background_same_caste / upper_income) -
      exp(middle_lower_same_caste / middle_lower_income)
  )
}
if (sys.nframe() == 0L) {
  point_estimates <- fit_heterogeneity(analysis_data)
  set.seed(114408)
  bootstrap_count <- 1999L
  advertiser_rows <- split(seq_len(nrow(analysis_data)), analysis_data$SI)
  bootstrap_estimates <- t(vapply(seq_len(bootstrap_count), function(draw) {
    selected_rows <- advertiser_rows[sample(seq_along(advertiser_rows), length(advertiser_rows), replace = TRUE)]
    sample_data <- analysis_data[unlist(selected_rows, use.names = FALSE), ]
    sample_data$SI <- rep(seq_along(selected_rows), lengths(selected_rows))
    fit_heterogeneity(sample_data)
  }, numeric(length(point_estimates))))
  colnames(bootstrap_estimates) <- names(point_estimates)
  stopifnot(all(is.finite(bootstrap_estimates)))
  write.csv(bootstrap_estimates, "output/resource_heterogeneity_draws.csv", row.names = FALSE)
  summary_estimates <- data.frame(
    statistic = names(point_estimates), estimate = point_estimates,
    lower = apply(bootstrap_estimates, 2, quantile, .025),
    upper = apply(bootstrap_estimates, 2, quantile, .975),
    bootstrap_draws = bootstrap_count, seed = 114408
  )
  write.csv(summary_estimates, "output/resource_heterogeneity.csv", row.names = FALSE)

  included <- complete.cases(analysis_data[, c("considered", "weight", "SI", model$vars)]) &
    is.finite(analysis_data$weight) & analysis_data$weight > 0
  analytic_advertisers <- unique(analysis_data$SI[included])
  background_levels <- c("Upper", "Middle", "Lower")
  background_counts <- do.call(rbind, lapply(seq_along(background_levels), function(level) {
    matching_interviews <- prepared_data$interviews$economicbkg == level
    advertiser_ids <- prepared_data$interviews$SI[matching_interviews]
    data.frame(
      self_reported_background = background_levels[level],
      all_advertisers = sum(matching_interviews),
      groom_search_advertisers = sum(analytic_advertisers %in% advertiser_ids),
      groom_search_letters = sum(analysis_data$SI[included] %in% advertiser_ids)
    )
  }))
  write.csv(background_counts, "output/economic_background_counts.csv", row.names = FALSE)

  income_distribution <- do.call(rbind, lapply(seq_along(background_levels), function(level) {
    advertiser_ids <- prepared_data$interviews$SI[prepared_data$interviews$economicbkg == level]
    candidate_income <- exp(analysis_data$predicted_income[included & analysis_data$SI %in% advertiser_ids])
    data.frame(
      family_background = background_levels[level], letter_count = length(candidate_income),
      q25 = quantile(candidate_income, .25), median = median(candidate_income),
      q75 = quantile(candidate_income, .75)
    )
  }))
  write.csv(income_distribution, "output/prospective_groom_income_distribution.csv", row.names = FALSE)
  print(summary_estimates)
  print(background_counts)
  income_slopes <- bootstrap_estimates[, c("middle_lower_income", "upper_income")]
  cat("Positive income slopes in bootstrap:", colMeans(income_slopes > 0), "\n")
}
