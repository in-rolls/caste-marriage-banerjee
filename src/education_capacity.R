source("src/simulation_matching.R")
market_path <- "data/original/AEJMicro-2011-0182-Data/matlab"
men <- as.matrix(read.csv(file.path(market_path, "all_males_matlab.csv"), header = FALSE))
women <- as.matrix(read.csv(file.path(market_path, "all_females_matlab.csv"), header = FALSE))
compress_profiles <- function(people) {
  keep <- people[, 6] == 0 & !is.na(people[, 31]) & people[, 19] == 0 & people[, 17] %in% 1:6
  people <- people[keep, , drop = FALSE]
  keys <- apply(people[, c(5, 6, 17, 31), drop = FALSE], 1, paste, collapse = ":")
  first <- !duplicated(keys)
  list(
    people = people[first, , drop = FALSE],
    counts = as.integer(table(factor(keys, levels = keys[first]))), n = nrow(people)
  )
}
male_profiles <- compress_profiles(men)
female_profiles <- compress_profiles(women)
pairs <- expand.grid(
  man = seq_len(nrow(male_profiles$people)), woman = seq_len(nrow(female_profiles$people))
)
same_caste <- matrix(reported_same_caste(
  male_profiles$people[pairs$man, , drop = FALSE], female_profiles$people[pairs$woman, , drop = FALSE]
), nrow = nrow(male_profiles$people))
corrected_caste <- same_caste
corrected_caste[outer(male_profiles$people[, 31] %in% c(17, 100), female_profiles$people[, 31] == 16, "&")] <- 1
same_education <- outer(male_profiles$people[, 17], female_profiles$people[, 17], "==")
stopifnot(!anyNA(same_caste))
results <- flows <- list()
for (scenario in c("unrestricted", "within_caste", "within_caste_typo_corrected")) {
  allowed <- switch(scenario,
    unrestricted = matrix(TRUE, nrow(same_caste), ncol(same_caste)),
    within_caste = same_caste == 1,
    within_caste_typo_corrected = corrected_caste == 1
  )
  # One additional couple outweighs every possible improvement in educational matching.
  match_bonus <- min(male_profiles$n, female_profiles$n) + 1
  objective <- ifelse(allowed, match_bonus + same_education, -match_bonus)
  fit <- lpSolve::lp.transport(objective, "max",
    rep("<=", length(male_profiles$counts)), male_profiles$counts,
    rep("<=", length(female_profiles$counts)), female_profiles$counts,
    integers = NULL
  )
  stopifnot(fit$status == 0, max(abs(fit$solution - round(fit$solution))) < 1e-6)
  matches <- round(fit$solution)
  stopifnot(
    all(rowSums(matches) <= male_profiles$counts), all(colSums(matches) <= female_profiles$counts),
    sum(matches[!allowed]) == 0
  )
  results[[scenario]] <- data.frame(
    scenario = scenario, source_men = nrow(men), source_women = nrow(women),
    men = male_profiles$n, women = female_profiles$n,
    couples = sum(matches), same_education_couples = sum(matches * same_education),
    same_education_share = sum(matches * same_education) / sum(matches),
    unmatched_men = male_profiles$n - sum(matches), unmatched_women = female_profiles$n - sum(matches)
  )
  used <- which(matches > 0, arr.ind = TRUE)
  flows[[scenario]] <- data.frame(
    scenario = scenario, male_caste = male_profiles$people[used[, 1], 31],
    female_caste = female_profiles$people[used[, 2], 31],
    male_education = male_profiles$people[used[, 1], 17],
    female_education = female_profiles$people[used[, 2], 17], couples = matches[used]
  )
  if (scenario == "unrestricted") {
    male_counts <- tapply(male_profiles$counts, factor(male_profiles$people[, 17], levels = 1:6), sum)
    female_counts <- tapply(female_profiles$counts, factor(female_profiles$people[, 17], levels = 1:6), sum)
    same_education_bound <- sum(pmin(male_counts, female_counts))
    stopifnot(sum(matches) == min(male_profiles$n, female_profiles$n))
    stopifnot(sum(matches * same_education) == same_education_bound)
  }
}
results <- do.call(rbind, results)
write.csv(results, "output/education_capacity.csv", row.names = FALSE)
write.csv(do.call(rbind, flows), "output/education_capacity_flows.csv", row.names = FALSE)
write.csv(data.frame(education = 1:6, men = male_counts, women = female_counts),
  "output/education_capacity_counts.csv",
  row.names = FALSE
)
print(results)
