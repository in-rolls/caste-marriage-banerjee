library(fixest)
setFixest_nthreads(1)
models <- readRDS("output/models.rds")
original_commands <- readLines("data/original/AEJMicro-2011-0182-Data/do/bootstrap_witherrors.do", warn = FALSE)
expand_terms <- function(command) {
  command <- sub(",.*$", "", sub("^areg considered ", "", trimws(command)))
  tokens <- strsplit(command, " +")[[1]]
  unlist(lapply(tokens, function(term) {
    if (!grepl("-", term, fixed = TRUE)) {
      return(term)
    }
    endpoints <- strsplit(term, "-", fixed = TRUE)[[1]]
    prefix <- sub("[0-9]+$", "", endpoints[1])
    paste0(prefix, seq(
      as.integer(sub(prefix, "", endpoints[1], fixed = TRUE)),
      as.integer(sub(prefix, "", endpoints[2], fixed = TRUE))
    ))
  }), use.names = FALSE)
}
coefficient_sets <- list()
coefficient_map <- list()
for (model_id in c("T3_1", "T4_1")) {
  model <- models[[model_id]]
  relevant_command <- original_commands[grepl(
    if (model_id == "T3_1") "^areg considered caste_no3" else "^areg considered caste_nof3", original_commands
  )][1]
  terms <- expand_terms(relevant_command)
  stopifnot(identical(terms, model$vars), identical(names(coef(model$fit)), terms))
  analysis_data <- model$data
  analysis_data$weight <- 1
  unweighted <- feols(formula(model$fit),
    data = analysis_data, weights = ~weight,
    fixef.rm = "none", notes = FALSE
  )
  stopifnot(identical(names(coef(unweighted)), terms), nobs(unweighted) == nobs(model$fit))
  for (scheme in c("unweighted", "weighted")) {
    coefficients <- if (scheme == "weighted") coef(model$fit) else coef(unweighted)
    coefficient_sets[[paste(scheme, model_id, sep = "_")]] <- c(coefficients, 0)
    coefficient_map[[paste(scheme, model_id)]] <- data.frame(
      model = model_id, scheme = scheme, feature_column = seq_len(length(terms) + 1L),
      term = c(terms, "common_intercept"), estimate = c(coefficients, 0), n = nobs(unweighted)
    )
  }
}
write.csv(do.call(rbind, coefficient_map), "output/simulation_weighting_coefficients.csv", row.names = FALSE)
