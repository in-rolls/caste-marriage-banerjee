source("src/simulation_matching.R")
base <- "data/original/AEJMicro-2011-0182-Data/matlab"
raw_males <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
raw_females <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
males <- raw_males
females <- raw_females
males[is.na(males)] <- females[is.na(females)] <- 0
analysis <- Sys.getenv("SIMULATION_ANALYSIS", "draws")
stopifnot(analysis %in% c("draws", "weighting", "handoff"))
file_prefix <- switch(analysis,
  weighting = "simulation_weighting",
  handoff = "simulation_handoff",
  draws = "simulation"
)
choices <- read.csv(file.path("output", paste0(file_prefix, "_choices.csv")))
if (analysis == "handoff") {
  reference <- read.csv("output/simulation_weighting_choices.csv")
  reference <- reference[reference$scenario %in% c("weighted", "no_caste_weighted"), ]
  choices <- rbind(reference, choices)
}
crosswalk <- read.csv("output/simulation_interview_crosswalk.csv")
verified <- crosswalk[crosswalk$status == "verified_identifier_and_attributes", ]
interview_men <- verified$simulation_row[verified$sex == "male"]
interview_women <- verified$simulation_row[verified$sex == "female"]
results <- list()
for (key in unique(paste(choices$draw, choices$scenario))) {
  selected <- choices[paste(choices$draw, choices$scenario) == key, ]
  selected <- selected[order(selected$man), ]
  stopifnot(identical(selected$man, seq_len(nrow(males))))
  wives <- selected$woman
  for (population in c("full_market", "verified_interview_subset")) {
    keep <- if (population == "full_market") {
      rep(TRUE, nrow(males))
    } else {
      seq_len(nrow(males)) %in% interview_men | wives %in% interview_women
    }
    matched_men <- males[keep, , drop = FALSE]
    matched_women <- females[wives[keep], , drop = FALSE]
    moments <- matching_moments(matched_men, females, wives[keep])
    names(moments)[names(moments) == "same_caste"] <- "same_caste_utility_known"
    reported_caste <- reported_same_caste(
      raw_males[keep, , drop = FALSE], raw_females[wives[keep], , drop = FALSE]
    )
    moments$same_caste_reported <- mean(reported_caste, na.rm = TRUE)
    moments$reported_caste_n <- sum(!is.na(reported_caste))
    male_quality_original <- quality_index(matched_men, "male")
    female_quality_original <- quality_index(matched_women, "female")
    male_quality_corrected <- quality_index(matched_men, "male", TRUE)
    female_quality_corrected <- quality_index(matched_women, "female", TRUE)
    moments$quality_gap_original <- mean(male_quality_original - female_quality_original)
    moments$quality_gap_corrected <- mean(male_quality_corrected - female_quality_corrected)
    moments$quality_correlation_original <- cor(male_quality_original, female_quality_original)
    moments$quality_correlation_corrected <- cor(male_quality_corrected, female_quality_corrected)
    results[[paste(key, population)]] <- cbind(
      draw = selected$draw[1], scenario = selected$scenario[1], population = population, moments
    )
  }
}
write.csv(do.call(rbind, results), file.path("output", paste0(file_prefix, "_moments.csv")), row.names = FALSE)

choice_sets <- split(choices, paste(choices$draw, choices$scenario, sep = "_"))
draw_ids <- unique(choices$draw)
comparisons <- list()
for (draw in draw_ids) {
  comparison_pairs <- if (analysis == "handoff") {
    list(
      handoff = c("weighted", "weighted_handoff"),
      no_caste_handoff = c("weighted_handoff", "no_caste_weighted_handoff"),
      handoff_no_caste = c("no_caste_weighted", "no_caste_weighted_handoff")
    )
  } else if (analysis == "weighting") {
    list(
      weighting = c("unweighted", "weighted"),
      no_caste_unweighted = c("unweighted", "no_caste_unweighted"),
      no_caste_weighted = c("weighted", "no_caste_weighted")
    )
  } else {
    list(
      residence = c("original", "residence_corrected"),
      no_caste_original = c("original", "no_caste_original"),
      no_caste_corrected = c("residence_corrected", "no_caste_residence_corrected")
    )
  }
  for (comparison in names(comparison_pairs)) {
    from <- comparison_pairs[[comparison]][1]
    to <- comparison_pairs[[comparison]][2]
    previous <- choice_sets[[paste(draw, from, sep = "_")]]$woman
    current <- choice_sets[[paste(draw, to, sep = "_")]]$woman
    old_husbands <- new_husbands <- integer(nrow(females))
    old_husbands[previous] <- new_husbands[current] <- seq_len(nrow(males))
    common_women <- which(old_husbands > 0 & new_husbands > 0)
    known_residence <- males[, 9] == 0 & females[previous, 9] == 0 & females[current, 9] == 0
    previous_men <- males[old_husbands[common_women], , drop = FALSE]
    current_men <- males[new_husbands[common_women], , drop = FALSE]
    known_education <- previous_men[, 19] == 0 & current_men[, 19] == 0
    known_income <- previous_men[, 26] == 0 & current_men[, 26] == 0
    income_changes <- exp(current_men[known_income, 25]) - exp(previous_men[known_income, 25])
    education_changes <- current_men[known_education, 17] - previous_men[known_education, 17]
    comparisons[[paste(draw, comparison)]] <- data.frame(
      draw = draw, comparison = comparison, changed_matches = sum(previous != current),
      changed_share = mean(previous != current), women_matched_in_both = length(common_women),
      common_residence_n = sum(known_residence),
      same_residence_before_common = mean(males[known_residence, 2] == females[previous[known_residence], 2]),
      same_residence_after_common = mean(males[known_residence, 2] == females[current[known_residence], 2]),
      husband_education_n = sum(known_education),
      husband_education_change = mean(current_men[known_education, 17] - previous_men[known_education, 17]),
      husband_education_changed_share = mean(current_men[known_education, 17] != previous_men[known_education, 17]),
      husband_education_absolute_change = mean(abs(
        current_men[known_education, 17] - previous_men[known_education, 17]
      )),
      husband_income_n = sum(known_income),
      husband_income_median_absolute_change = median(abs(income_changes)),
      husband_income_p95_absolute_change = unname(quantile(abs(income_changes), .95)),
      husband_income_max_absolute_change = max(abs(income_changes)),
      husband_income_increase_share = mean(income_changes > 0),
      husband_income_decrease_share = mean(income_changes < 0),
      husband_education_increase_share = mean(education_changes > 0),
      husband_education_decrease_share = mean(education_changes < 0),
      husband_income_change = mean(exp(current_men[known_income, 25]) - exp(previous_men[known_income, 25])),
      husband_income_absolute_change = mean(abs(
        exp(current_men[known_income, 25]) - exp(previous_men[known_income, 25])
      )),
      husband_quality_absolute_change = mean(abs(quality_index(current_men, "male", TRUE) -
                                                   quality_index(previous_men, "male", TRUE))),
      husband_quality_change = mean(quality_index(current_men, "male", TRUE) -
                                      quality_index(previous_men, "male", TRUE))
    )
  }
}
write.csv(do.call(rbind, comparisons), file.path("output", paste0(file_prefix, "_comparisons.csv")), row.names = FALSE)
