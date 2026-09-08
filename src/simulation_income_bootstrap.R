library(fixest)
setFixest_nthreads(1)

resample_advertisers <- function(data, sampled_ids) {
  rows <- split(seq_len(nrow(data)), data$SI)
  selected_rows <- rows[as.character(sampled_ids)]
  stopifnot(!any(vapply(selected_rows, is.null, logical(1))))
  resampled <- data[unlist(selected_rows, use.names = FALSE), , drop = FALSE]
  resampled$SI <- rep(seq_along(sampled_ids), lengths(selected_rows))
  resampled
}

fit_preference_draw <- function(model, sampled_ids) {
  data <- resample_advertisers(model$data, sampled_ids)
  fit <- feols(formula(model$fit), data = data, weights = ~weight, fixef.rm = "none", notes = FALSE)
  coefficients <- coef(fit)
  missing_terms <- setdiff(model$vars, names(coefficients))
  result <- setNames(rep(NA_real_, length(model$vars) + 1L), c(model$vars, "common_intercept"))
  result[names(coefficients)] <- coefficients
  result["common_intercept"] <- 0
  omitted_support <- data.frame(
    term = missing_terms,
    training_nonzero = vapply(missing_terms, function(term) sum(data[[term]] != 0), integer(1))
  )
  list(coefficients = result, omitted_terms = missing_terms, omitted_support = omitted_support, n = nobs(fit))
}

generate_income_bootstrap <- function(draws = 250L, seed = 114409L,
                                      destination = "output/simulation_income_bootstrap.rds") {
  models <- readRDS("output/models.rds")[c("T3_1", "T4_1")]
  stopifnot(length(draws) == 1L, draws >= 2L)
  set.seed(seed)
  records <- vector("list", draws)
  support <- omitted_support <- list()
  base <- "data/original/AEJMicro-2011-0182-Data/matlab"
  men <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
  women <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
  for (draw in seq_len(draws)) {
    fits <- list()
    for (model_id in names(models)) {
      model <- models[[model_id]]
      ids <- unique(model$data$SI)
      selected <- sample(ids, length(ids), replace = TRUE)
      fit <- fit_preference_draw(model, selected)
      fits[[model_id]] <- fit$coefficients
      if (nrow(fit$omitted_support)) {
        for (row in seq_len(nrow(fit$omitted_support))) {
          term <- fit$omitted_support$term[row]
          flag <- switch(term,
            samenocaste = 6L,
            samenoage = 10L,
            NA_integer_
          )
          candidates <- if (model_id == "T3_1") men else women
          choosers <- if (model_id == "T3_1") women else men
          omitted_support[[paste(draw, model_id, term)]] <- cbind(
            draw = draw, model = model_id, fit$omitted_support[row, ],
            affected_choosers = if (!is.na(flag)) sum(choosers[, flag] == 1, na.rm = TRUE) else NA_integer_,
            candidates_missing = if (!is.na(flag)) sum(candidates[, flag] == 1, na.rm = TRUE) else NA_integer_,
            candidates_observed = if (!is.na(flag)) sum(candidates[, flag] == 0, na.rm = TRUE) else NA_integer_
          )
        }
      }
      support[[paste(draw, model_id)]] <- data.frame(
        draw = draw, model = model_id, n = fit$n, advertisers = length(ids),
        unique_sampled_advertisers = length(unique(selected)),
        omitted_n = length(fit$omitted_terms), omitted_terms = paste(fit$omitted_terms, collapse = ";"),
        sample_sha256 = digest::digest(selected, algo = "sha256")
      )
    }
    records[[draw]] <- fits
  }
  support <- do.call(rbind, support)
  omitted_support <- do.call(rbind, omitted_support)
  result <- list(
    seed = seed, draws = draws, weighting = "published_letter_weights", resampling = "advertisers_with_replacement",
    model_sha256 = digest::digest(file = "output/models.rds", algo = "sha256"),
    source_sha256 = digest::digest(file = "src/simulation_income_bootstrap.R", algo = "sha256"),
    coefficients = records, support = support, omitted_support = omitted_support
  )
  saveRDS(result, destination)
  write.csv(support, sub("[.]rds$", "_support.csv", destination), row.names = FALSE)
  write.csv(omitted_support, sub("[.]rds$", "_omissions.csv", destination), row.names = FALSE)
  message(
    draws, " weighted coefficient draws; ", sum(support$omitted_n > 0),
    " model fits with unidentified coefficient positions (not normalized to zero)"
  )
  invisible(result)
}

if (sys.nframe() == 0L) generate_income_bootstrap()
