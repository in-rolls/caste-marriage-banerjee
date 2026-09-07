library(fixest)
setFixest_nthreads(1)

bride_income_audit <- function(model_path = "output/limited_models.rds",
                               author_path = "data/original/AEJMicro-2011-0182-Data/R/bridewanted_for_r.txt") {
  model <- readRDS(model_path)$T4_1
  analysis_data <- model$data
  first_stage <- model$first
  training_matrix <- model.matrix(first_stage)
  prediction_matrix <- model.matrix(delete.response(terms(first_stage)), analysis_data)
  coefficients <- coef(first_stage)
  coefficients[is.na(coefficients)] <- 0
  training_rows <- match(rownames(training_matrix), rownames(analysis_data))
  null_basis <- matrix(0, ncol(prediction_matrix), 3, dimnames = list(
    colnames(prediction_matrix), c("post_secondary", "other_field", "education_intercept")
  ))
  null_basis["edu_female4", "post_secondary"] <- 1
  null_basis["otherfield_female", "other_field"] <- 1
  null_basis["(Intercept)", "education_intercept"] <- 1
  education_terms <- c(
    "edu_female3", "edu_female5", "edu_female6", "edu_female7",
    "otheredu_dum_female", "noedu_female"
  )
  null_basis[education_terms, "education_intercept"] <- -1
  direction <- null_basis[, "education_intercept"]
  prediction_changes <- prediction_matrix %*% null_basis
  supported <- rowSums(abs(prediction_changes)) == 0
  stopifnot(max(abs(training_matrix %*% null_basis)) < 1e-12)
  fit_second_stage <- function(predictions, restrict_support = FALSE) {
    fit_data <- analysis_data
    fit_data$predicted_income <- predictions
    if (restrict_support) fit_data <- fit_data[supported, ]
    feols(formula(model$fit), fit_data, weights = ~weight, vcov = ~SI, fixef.rm = "none", notes = FALSE)
  }
  normalization_terms <- c("(Intercept)", education_terms)
  shifts <- -coefficients[normalization_terms] / direction[normalization_terms]
  scenarios <- data.frame(
    scenario = c(paste0("zero_", normalization_terms), "education_intercept_shift_5"),
    zero_coefficient = c(normalization_terms, NA_character_),
    shift = c(unname(shifts), 5)
  )
  default_predictions <- drop(prediction_matrix %*% coefficients)
  normalizations <- lapply(seq_len(nrow(scenarios)), function(index) {
    shifted_coefficients <- coefficients + scenarios$shift[index] * direction
    predictions <- drop(prediction_matrix %*% shifted_coefficients)
    second_stage <- fit_second_stage(predictions)
    supported_stage <- fit_second_stage(predictions, TRUE)
    residuals <- model.response(model.frame(first_stage)) - drop(training_matrix %*% shifted_coefficients)
    data.frame(
      scenarios[index, ],
      earnings_weighted_sse = sum(model.weights(model.frame(first_stage)) * residuals^2),
      maximum_training_prediction_change = max(abs(training_matrix %*% (shifted_coefficients - coefficients))),
      maximum_full_prediction_change = max(abs(predictions - default_predictions)),
      same_caste = unname(coef(second_stage)["samecaste"]),
      predicted_income = unname(coef(second_stage)["predicted_income"]),
      supported_same_caste = unname(coef(supported_stage)["samecaste"]),
      supported_predicted_income = unname(coef(supported_stage)["predicted_income"])
    )
  })
  normalizations <- do.call(rbind, normalizations)
  author_coefficients <- coefficients + coefficients["edu_female7"] * direction
  author_predictions <- drop(prediction_matrix %*% author_coefficients)
  author_fit <- fit_second_stage(author_predictions)
  published <- c(
    samecaste = .1800, diff_above = -.0138, diff_below = -.0428,
    casteimportantmatch = .1162, casteimportantdiff = -.0056,
    castenotimpmatch = -.0629, castenotimpdiff = .0115,
    diffage = .0394, diffagesq = -.0023, diffheight = .7585,
    diffheightsq = -6.3265, calcutta_female = .0591,
    sameresstatus = -.0442, samefamily_origin = .0977,
    skinrank_female = -.0534, beauty_female = .0043,
    vbeauty_female = .0465, predicted_income = .0817
  )
  published_comparison <- data.frame(
    term = names(published), published = unname(published),
    reconstructed = unname(coef(author_fit)[names(published)]),
    matches_printed_precision = round(unname(coef(author_fit)[names(published)]), 4) == unname(published)
  )
  author_data <- read.delim(author_path)
  comparison_columns <- setdiff(names(author_data), "income_pred_female")
  comparison_data <- analysis_data
  export_reversed_terms <- c("diff_above", "diff_below", "casteimportantdiff", "castenotimpdiff")
  for (term in export_reversed_terms) comparison_data[[term]] <- -comparison_data[[term]]
  row_key <- function(data) {
    do.call(paste, c(lapply(data[, comparison_columns], function(value) round(value, 4)), sep = "|"))
  }
  author_keys <- row_key(author_data)
  replica_keys <- row_key(comparison_data)
  stopifnot(identical(sort(author_keys), sort(replica_keys)))
  # Income sorts repeated profiles; this establishes multiset equality, not unique person identifiers.
  author_order <- order(author_keys, author_data$income_pred_female)
  replica_order <- order(replica_keys, author_predictions)
  author_comparison <- data.frame(
    author_row = author_order, analysis_row = replica_order,
    SI = author_data$SI[author_order],
    profile_multiplicity = as.integer(table(author_keys)[author_keys[author_order]]),
    author_prediction = author_data$income_pred_female[author_order],
    reconstructed_prediction = author_predictions[replica_order],
    default_r_prediction = default_predictions[replica_order],
    supported_prediction = supported[replica_order]
  )
  support <- data.frame(
    analysis_row = seq_len(nrow(analysis_data)), SI = analysis_data$SI,
    earnings_training_row = seq_len(nrow(analysis_data)) %in% training_rows,
    supported_prediction = supported,
    post_secondary_affected = prediction_changes[, "post_secondary"] != 0,
    other_field_affected = prediction_changes[, "other_field"] != 0,
    education_intercept_affected = prediction_changes[, "education_intercept"] != 0,
    default_r_prediction = default_predictions, author_prediction = author_predictions
  )
  maximum_covariate_difference <- max(abs(
    as.matrix(author_data[author_order, comparison_columns]) -
      as.matrix(comparison_data[replica_order, comparison_columns])
  ))
  counts <- data.frame(
    quantity = c(
      "main_letters", "main_advertisers", "reported_income_flag_letters",
      "earnings_training_letters", "earnings_training_advertisers",
      "first_stage_columns", "first_stage_rank", "supported_predictions",
      "unsupported_predictions", "post_secondary_affected", "other_field_affected",
      "education_intercept_affected", "author_export_unique_profiles",
      "author_export_maximum_covariate_difference", "author_export_maximum_income_difference"
    ),
    value = c(
      nrow(analysis_data), length(unique(analysis_data$SI)), sum(analysis_data$noincome_female == 0),
      nrow(training_matrix), length(unique(analysis_data$SI[training_rows])),
      ncol(training_matrix), first_stage$rank, sum(supported), sum(!supported),
      colSums(prediction_changes != 0), length(unique(author_keys)),
      maximum_covariate_difference,
      max(abs(author_comparison$author_prediction - author_comparison$reconstructed_prediction))
    )
  )
  list(
    counts = counts, normalizations = normalizations, published_comparison = published_comparison,
    author_comparison = author_comparison, support = support,
    null_basis = null_basis, training_matrix = training_matrix, prediction_matrix = prediction_matrix,
    first_stage = first_stage, author_fit = author_fit
  )
}

if (sys.nframe() == 0) {
  audit <- bride_income_audit()
  for (name in c("counts", "normalizations", "published_comparison", "author_comparison", "support")) {
    write.csv(audit[[name]], paste0("output/bride_income_", name, ".csv"), row.names = FALSE)
  }
  print(audit$counts)
  print(audit$normalizations[, c("scenario", "same_caste", "predicted_income")])
}
