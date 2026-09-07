source("src/simulation_coefficients.R")
source("src/simulation_matching.R")
Rcpp::sourceCpp("src/simulation_preferences.cpp")
base <- "data/original/AEJMicro-2011-0182-Data/matlab"
males <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
females <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
males[is.na(males)] <- females[is.na(females)] <- 0
results <- choices <- list()
for (scenario in c("weighted_handoff", "no_caste_weighted_handoff")) {
  started <- proc.time()[[3]]
  scheme <- "weighted"
  bride_coefficients <- coefficient_sets[[paste(scheme, "T3_1", sep = "_")]]
  groom_coefficients <- coefficient_sets[[paste(scheme, "T4_1", sep = "_")]]
  if (startsWith(scenario, "no_caste")) {
    bride_coefficients[1:18] <- 0
    groom_coefficients[1:18] <- 0
  }
  message("Point estimates: ", scenario)
  preferences <- simulation_preferences(males, females, bride_coefficients, groom_coefficients, TRUE, TRUE)
  message("Preferences built; matching")
  matching <- simulation_match(preferences$male_preferences, preferences$female_ranks)
  stopifnot(matching$blocking_pairs == 0L, anyDuplicated(matching$choice) == 0L)
  moments <- matching_moments(males, females, matching$choice)
  results[[scenario]] <- cbind(
    draw = 0L, scenario = scenario, moments, proposals = matching$proposals,
    blocking_pairs = matching$blocking_pairs, elapsed_seconds = proc.time()[[3]] - started
  )
  choices[[scenario]] <- data.frame(draw = 0L, scenario = scenario, man = seq_len(nrow(males)), woman = matching$choice)
  write.csv(do.call(rbind, results), "output/simulation_handoff_sensitivity.csv", row.names = FALSE)
  write.csv(do.call(rbind, choices), "output/simulation_handoff_choices.csv", row.names = FALSE)
  print(results[[scenario]])
  rm(preferences)
  gc()
}
