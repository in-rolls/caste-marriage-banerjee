income_tools <- new.env()
sys.source("src/simulation_batch_summary.R", envir = income_tools)

summarize_income_changes <- function(before, after, eligible) {
  stopifnot(length(before) == length(after), length(before) == length(eligible), !anyNA(eligible))
  keep <- eligible & is.finite(before) & is.finite(after)
  change <- after[keep] - before[keep]
  data.frame(
    eligible_n = sum(eligible), income_pair_n = sum(keep),
    income_coverage = if (any(eligible)) mean(keep[eligible]) else NA_real_,
    mean_income_with_caste = if (length(change)) mean(before[keep]) else NA_real_,
    mean_income_without_caste = if (length(change)) mean(after[keep]) else NA_real_,
    net_income_gain = if (length(change)) mean(change) else NA_real_,
    gross_gain_per_woman = if (length(change)) mean(pmax(change, 0)) else NA_real_,
    gross_loss_per_woman = if (length(change)) mean(pmax(-change, 0)) else NA_real_,
    median_income_gain = if (length(change)) median(change) else NA_real_,
    gain_share = if (length(change)) mean(change > 0) else NA_real_,
    loss_share = if (length(change)) mean(change < 0) else NA_real_,
    unchanged_share = if (length(change)) mean(change == 0) else NA_real_,
    median_absolute_change = if (length(change)) median(abs(change)) else NA_real_,
    p025_change = if (length(change)) unname(quantile(change, .025, type = 2)) else NA_real_,
    p975_change = if (length(change)) unname(quantile(change, .975, type = 2)) else NA_real_,
    largest_absolute_change = if (length(change)) max(abs(change)) else NA_real_,
    net_without_largest_absolute_change = if (length(change) > 1L) mean(change[-which.max(abs(change))]) else NA_real_
  )
}

compare_income_allocations <- function(men, women, before_choice, after_choice, interview_women) {
  before_husband <- after_husband <- integer(nrow(women))
  before_husband[before_choice] <- after_husband[after_choice] <- seq_len(nrow(men))
  common <- which(before_husband > 0 & after_husband > 0)
  husbands_before <- men[before_husband[common], , drop = FALSE]
  husbands_after <- men[after_husband[common], , drop = FALSE]
  caste_before <- income_tools$caste_outcomes(husbands_before, women[common, , drop = FALSE])$reported_caste
  before_income <- ifelse(husbands_before[, 26] == 0, exp(husbands_before[, 25]), NA_real_)
  after_income <- ifelse(husbands_after[, 26] == 0, exp(husbands_after[, 25]), NA_real_)
  populations <- list(
    all_common_women = rep(TRUE, length(common)),
    same_caste_before = !is.na(caste_before) & caste_before == 1,
    outside_caste_before = !is.na(caste_before) & caste_before == 0,
    verified_interview_women = interview_women[common]
  )
  summary <- do.call(rbind, lapply(names(populations), function(population) {
    cbind(population = population, summarize_income_changes(before_income, after_income, populations[[population]]))
  }))
  summary$women_matched_before <- length(before_choice)
  summary$women_matched_after <- length(after_choice)
  summary$women_matched_in_both <- length(common)
  summary$women_entering_marriage <- sum(before_husband == 0 & after_husband > 0)
  summary$women_leaving_marriage <- sum(before_husband > 0 & after_husband == 0)
  summary
}

run_income_sacrifice <- function() {
  base <- "data/original/AEJMicro-2011-0182-Data/matlab"
  men <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
  women <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
  crosswalk <- read.csv("output/simulation_interview_crosswalk.csv")
  verified <- crosswalk[crosswalk$sex == "female" & crosswalk$status == "verified_identifier_and_attributes", ]
  interview_women <- seq_len(nrow(women)) %in% verified$simulation_row
  choices <- rbind(
    read.csv("output/simulation_choices.csv"), read.csv("output/simulation_weighting_choices.csv"),
    read.csv("output/simulation_handoff_choices.csv")
  )
  comparisons <- list(
    supplied_original = c("original", "no_caste_original"),
    supplied_residence_repaired = c("residence_corrected", "no_caste_residence_corrected"),
    unweighted_residence_repaired = c("unweighted", "no_caste_unweighted"),
    weighted_residence_repaired = c("weighted", "no_caste_weighted"),
    weighted_all_repairs = c("weighted_handoff", "no_caste_weighted_handoff")
  )
  results <- lapply(names(comparisons), function(comparison) {
    scenario <- comparisons[[comparison]]
    selected_before <- choices[choices$scenario == scenario[1], ]
    selected_after <- choices[choices$scenario == scenario[2], ]
    draw <- min(intersect(selected_before$draw, selected_after$draw))
    selected_before <- selected_before[selected_before$draw == draw, ]
    selected_after <- selected_after[selected_after$draw == draw, ]
    selected_before <- selected_before[order(selected_before$man), ]
    selected_after <- selected_after[order(selected_after$man), ]
    stopifnot(
      identical(selected_before$man, seq_len(nrow(men))),
      identical(selected_after$man, seq_len(nrow(men))), !anyDuplicated(selected_before$woman),
      !anyDuplicated(selected_after$woman)
    )
    cbind(comparison = comparison, draw = draw, compare_income_allocations(
      men, women, selected_before$woman, selected_after$woman, interview_women
    ))
  })
  results <- do.call(rbind, results)
  write.csv(results, "output/simulation_income_sacrifice.csv", row.names = FALSE)
  print(results[results$population == "all_common_women", c(
    "comparison", "income_pair_n", "income_coverage", "net_income_gain", "gross_gain_per_woman", "gross_loss_per_woman"
  )], row.names = FALSE)
  invisible(results)
}

if (sys.nframe() == 0L) run_income_sacrifice()
