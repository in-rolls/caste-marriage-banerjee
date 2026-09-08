source("src/simulation_matching.R")
marriages <- subset(readRDS("output/prepared.rds")$pairs, match == 1)
observed <- subset(marriages, nocaste_male == 0 & nocaste_female == 0)
people_matrix <- function(data, sex) {
  people <- matrix(0, nrow(data), 35)
  people[, 5] <- data[[paste0("main_caste_rank_", sex)]]
  people[, 6] <- data[[paste0("nocaste_", sex)]]
  people[, 31] <- data[[paste0("caste_", sex)]]
  people
}
men <- people_matrix(observed, "male")
women <- people_matrix(observed, "female")
observed_same <- reported_same_caste(men, women)
stopifnot(identical(as.numeric(observed$samecaste), observed_same))

# Every woman has probability 1/n of marrying each man under uniform re-pairing.
pair_indices <- expand.grid(man = seq_len(nrow(men)), woman = seq_len(nrow(women)))
random_men <- men[pair_indices$man, , drop = FALSE]
random_women <- women[pair_indices$woman, , drop = FALSE]
random_same <- reported_same_caste(random_men, random_women)
stopifnot(!anyNA(random_same), nrow(men) == nrow(women))
same_caste_pairs <- matrix(random_same, nrow = nrow(men))
stopifnot(identical(diag(same_caste_pairs), observed_same))

corrected_same <- random_same
corrected_same[which(random_women[, 31] == 16 & random_men[, 31] %in% c(17, 100))] <- 1
benchmark <- data.frame(
  comparison = c("observed_couples", "uniform_random_pairing", "random_pairing_typo_corrected"),
  men = nrow(men), women = nrow(women),
  source_couples = nrow(marriages), excluded_missing_caste = nrow(marriages) - nrow(observed),
  same_caste_share = c(mean(observed_same), mean(random_same), mean(corrected_same)),
  same_caste_couples_observed_or_expected = c(
    sum(observed_same), mean(random_same) * nrow(men),
    mean(corrected_same) * nrow(men)
  )
)
write.csv(benchmark, "output/caste_matching_benchmarks.csv", row.names = FALSE)
print(benchmark)
cat("Potential pairs affected by the known caste-map typo:", sum(corrected_same != random_same), "\n")
