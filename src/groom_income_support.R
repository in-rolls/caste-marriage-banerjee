library(fixest)

groom_income_support <- function(model_path = "output/limited_models.rds") {
  model <- readRDS(model_path)$T3_1
  first_stage <- model$first
  training_matrix <- model.matrix(first_stage)
  training_frame <- model.frame(first_stage)
  training_rows <- match(rownames(training_matrix), rownames(model$data))
  downstream_rows <- obs(model$fit)
  downstream_data <- model$data[downstream_rows, ]
  prediction_matrix <- model.matrix(delete.response(terms(first_stage)), downstream_data)
  weights <- model.weights(training_frame)
  weighted_matrix <- training_matrix * sqrt(weights)
  decomposition <- svd(weighted_matrix, nu = 0)
  singular_tolerance <- max(dim(weighted_matrix)) * max(decomposition$d) * .Machine$double.eps
  rank <- sum(decomposition$d > singular_tolerance)
  row_span <- decomposition$v[, seq_len(rank), drop = FALSE]
  projection_residual <- prediction_matrix - prediction_matrix %*% row_span %*% t(row_span)
  projection_error <- apply(abs(projection_residual), 1, max)
  r_predictions <- predict(first_stage, downstream_data, rankdeficient = "non-estim")
  column_order <- rev(seq_len(ncol(training_matrix)))
  reordered_fit <- lm.wfit(
    training_matrix[, column_order], model.response(training_frame), weights
  )
  reordered_predictions <- drop(prediction_matrix[, column_order] %*% coef(reordered_fit))
  comparison_error <- max(abs(reordered_predictions - r_predictions))
  coefficients <- coef(model$fit)
  counts <- data.frame(
    quantity = c(
      "candidate_letters", "candidate_advertisers", "reported_income_flag_letters",
      "earnings_training_letters", "earnings_training_advertisers",
      "first_stage_columns", "first_stage_rank", "aliased_coefficients",
      "downstream_letters", "downstream_advertisers", "downstream_missing_predictions",
      "downstream_predictions_outside_linear_span", "r_nonestimable_predictions",
      "maximum_projection_error", "column_reordering_maximum_prediction_change",
      "same_caste_coefficient", "predicted_log_income_coefficient", "outside_income_premium"
    ),
    value = c(
      nrow(model$data), length(unique(model$data$SI)), sum(model$data$noincome_male == 0, na.rm = TRUE),
      nrow(training_matrix), length(unique(model$data$SI[training_rows])),
      ncol(training_matrix), rank, sum(is.na(coef(first_stage))),
      nrow(downstream_data), length(unique(downstream_data$SI)), sum(is.na(r_predictions)),
      sum(projection_error > 1e-10), length(attr(r_predictions, "non-estim")),
      max(projection_error), comparison_error,
      unname(coefficients["samecaste"]), unname(coefficients["predicted_income"]),
      exp(unname(coefficients["samecaste"] / coefficients["predicted_income"])) - 1
    )
  )
  list(
    counts = counts, training_matrix = training_matrix, prediction_matrix = prediction_matrix,
    projection_error = projection_error, r_predictions = r_predictions,
    reordered_predictions = reordered_predictions
  )
}

if (sys.nframe() == 0L) {
  audit <- groom_income_support()
  write.csv(audit$counts, "output/groom_income_support_counts.csv", row.names = FALSE)
  print(audit$counts)
}
