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

compress_caste <- function(people) {
  people <- people[people[, 6] == 0 & !is.na(people[, 31]), , drop = FALSE]
  keys <- apply(people[, c(5, 6, 31), drop = FALSE], 1, paste, collapse = ":")
  first <- !duplicated(keys)
  counts <- as.integer(table(factor(keys, levels = keys[first])))
  list(people = people[first, , drop = FALSE], counts = counts, n = nrow(people))
}
random_caste_share <- function(male_pool, female_pool, caste_rule) {
  male_groups <- compress_caste(male_pool)
  female_groups <- compress_caste(female_pool)
  pairs <- expand.grid(
    man = seq_len(nrow(male_groups$people)), woman = seq_len(nrow(female_groups$people))
  )
  same <- caste_rule(
    male_groups$people[pairs$man, , drop = FALSE], female_groups$people[pairs$woman, , drop = FALSE]
  )
  weights <- male_groups$counts[pairs$man] * female_groups$counts[pairs$woman]
  stopifnot(!anyNA(same), sum(weights) == male_groups$n * female_groups$n)
  data.frame(
    men = male_groups$n, women = female_groups$n,
    source_men = nrow(male_pool), source_women = nrow(female_pool),
    excluded_men = nrow(male_pool) - male_groups$n,
    excluded_women = nrow(female_pool) - female_groups$n,
    same_caste_share = weighted.mean(same, weights)
  )
}
stopifnot(isTRUE(all.equal(random_caste_share(men, women, reported_same_caste)$same_caste_share, mean(random_same))))
market_path <- "data/original/AEJMicro-2011-0182-Data/matlab"
advertiser_men <- as.matrix(read.csv(file.path(market_path, "all_males_matlab.csv"), header = FALSE))
advertiser_women <- as.matrix(read.csv(file.path(market_path, "all_females_matlab.csv"), header = FALSE))
advertiser_benchmark <- random_caste_share(advertiser_men, advertiser_women, reported_same_caste)
write.csv(advertiser_benchmark, "output/advertiser_caste_benchmark.csv", row.names = FALSE)
print(advertiser_benchmark)
