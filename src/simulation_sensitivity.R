source("src/simulation_matching.R")
Rcpp::sourceCpp("src/simulation_preferences.cpp")
base <- "data/original/AEJMicro-2011-0182-Data/matlab"
males <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
females <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
# Match csvread: empty numeric fields in the original CSV are zeros.
females[is.na(females)] <- 0
males[is.na(males)] <- 0
beta_brides <- as.matrix(read.csv(file.path(base, "beta_brides_sigma.csv"), header = FALSE))
beta_grooms <- as.matrix(read.csv(file.path(base, "beta_grooms_sigma.csv"), header = FALSE))
draw_ids <- as.integer(strsplit(Sys.getenv("SIMULATION_DRAWS", "1"), ",", fixed = TRUE)[[1]])
stopifnot(all(draw_ids >= 1L & draw_ids <= 250L))
scenarios <- expand.grid(correct_residence = c(FALSE, TRUE), no_caste = c(FALSE, TRUE))
scenario_names <- c("original", "residence_corrected", "no_caste_original", "no_caste_residence_corrected")
results <- list()
choices <- list()
for (draw in draw_ids) {
  for (scenario in seq_len(nrow(scenarios))) {
    started <- proc.time()[[3]]
    bride_coefficients <- beta_brides[draw, 1:57]
    groom_coefficients <- beta_grooms[draw, 1:58]
    if (scenarios$no_caste[scenario]) {
      bride_coefficients[1:18] <- 0
      groom_coefficients[1:18] <- 0
    }
    message("Draw ", draw, ": ", scenario_names[scenario])
    preferences <- simulation_preferences(
      males, females, bride_coefficients, groom_coefficients,
      scenarios$correct_residence[scenario]
    )
    message("Preferences built; matching")
    matching <- simulation_match(preferences$male_preferences, preferences$female_ranks)
    blocking_pairs <- matching$blocking_pairs
    stopifnot(blocking_pairs == 0L, anyDuplicated(matching$choice) == 0L)
    moments <- matching_moments(males, females, matching$choice)
    wives <- females[matching$choice, , drop = FALSE]
    moments$quality_gap_original <- mean(quality_index(males, "male") - quality_index(wives, "female"))
    moments$quality_gap_corrected <- mean(quality_index(males, "male", TRUE) - quality_index(wives, "female", TRUE))
    moments$quality_correlation_original <- cor(quality_index(males, "male"), quality_index(wives, "female"))
    moments$quality_correlation_corrected <- cor(
      quality_index(males, "male", TRUE), quality_index(wives, "female", TRUE)
    )
    key <- paste(draw, scenario_names[scenario], sep = "_")
    results[[key]] <- cbind(
      draw = draw, scenario = scenario_names[scenario], moments,
      proposals = matching$proposals, blocking_pairs = blocking_pairs,
      elapsed_seconds = proc.time()[[3]] - started
    )
    choices[[key]] <- data.frame(
      draw = draw, scenario = scenario_names[scenario], man = seq_len(nrow(males)),
      woman = matching$choice
    )
    write.csv(do.call(rbind, results), "output/simulation_sensitivity.csv", row.names = FALSE)
    write.csv(do.call(rbind, choices), "output/simulation_choices.csv", row.names = FALSE)
    print(results[[key]])
    rm(preferences)
    gc()
  }
}
