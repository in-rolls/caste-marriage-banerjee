library(fixest)
setFixest_nthreads(1)
analysis_models <- readRDS("output/models.rds")
shortlist_baselines <- lapply(c("T3_1", "T4_1"), function(model_name) {
  model <- analysis_models[[model_name]]
  analysis_data <- model$data
  included <- complete.cases(analysis_data[, c("considered", "weight", "SI", model$vars)]) &
    is.finite(analysis_data$weight) & analysis_data$weight > 0
  analysis_data <- analysis_data[included, ]
  stopifnot(nrow(analysis_data) == nobs(model$fit))
  data.frame(
    model = model_name, letters = nrow(analysis_data), advertisers = length(unique(analysis_data$SI)),
    shortlist_rate = weighted.mean(analysis_data$considered, analysis_data$weight),
    same_caste_coefficient = unname(coef(model$fit)["samecaste"])
  )
})
write.csv(do.call(rbind, shortlist_baselines), "output/shortlist_baselines.csv", row.names = FALSE)

model <- analysis_models$T3_1
analysis_data <- model$data
included <- complete.cases(analysis_data[, c("considered", "weight", "SI", model$vars)]) &
  is.finite(analysis_data$weight) & analysis_data$weight > 0
analysis_data <- analysis_data[included, ]
clustered_model <- feols(formula(model$fit), analysis_data, weights = ~weight, fixef.rm = "none",
  vcov = ~SI, ssc = ssc(K.fixef = "nonnested"), notes = FALSE
)
contrast_weights <- list(
  same_caste = c(samecaste = 1),
  bachelor_to_master = c(edu_male6 = 1, edu_male5 = -1, moreedu = 1, sameedu_max = -1),
  same_caste_bachelor_minus_outside_master = c(
    samecaste = 1, edu_male6 = -1, edu_male5 = 1, moreedu = -1, sameedu_max = 1
  )
)
education_contrasts <- lapply(names(contrast_weights), function(contrast_name) {
  contrast <- setNames(rep(0, length(coef(clustered_model))), names(coef(clustered_model)))
  contrast[names(contrast_weights[[contrast_name]])] <- contrast_weights[[contrast_name]]
  estimate <- sum(contrast * coef(clustered_model))
  standard_error <- sqrt(drop(t(contrast) %*% vcov(clustered_model) %*% contrast))
  critical_value <- qt(.975, length(unique(analysis_data$SI)) - 1)
  data.frame(
    contrast = contrast_name, estimate = estimate, standard_error = standard_error,
    lower = estimate - critical_value * standard_error, upper = estimate + critical_value * standard_error
  )
})
write.csv(do.call(rbind, education_contrasts), "output/education_tradeoff_contrasts.csv", row.names = FALSE)
