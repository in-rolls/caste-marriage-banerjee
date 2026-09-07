library(testthat)
source("src/simulation_matching.R")
Rcpp::sourceCpp("src/simulation_preferences.cpp")

test_that("deferred acceptance gives known matches and rejects blocking allocations", {
  male_preferences <- matrix(c(1L, 2L, 1L, 2L), 2L)
  female_ranks <- matrix(c(2L, 1L, 1L, 2L), 2L)
  result <- match_preferences(male_preferences, female_ranks)
  expect_equal(result$choice, c(2L, 1L))
  expect_equal(check_stability(male_preferences, female_ranks, result$choice), 0L)
  compiled <- simulation_match(male_preferences, female_ranks)
  expect_equal(compiled$choice, result$choice)
  expect_equal(compiled$blocking_pairs, 0)
  expect_gt(check_stability(male_preferences, female_ranks, c(1L, 2L)), 0L)
})

test_that("random complete markets have no unmatched men, repeated wives, or blocking pairs", {
  set.seed(114407)
  for (iteration in seq_len(30L)) {
    male_preferences <- replicate(4L, sample.int(7L))
    female_ranks <- replicate(7L, sample.int(4L))
    result <- match_preferences(male_preferences, female_ranks)
    expect_equal(length(result$choice), 4L)
    expect_equal(anyDuplicated(result$choice), 0L)
    expect_equal(check_stability(male_preferences, female_ranks, result$choice), 0L)
    compiled <- simulation_match(male_preferences, female_ranks)
    expect_equal(compiled$choice, result$choice)
    expect_equal(compiled$blocking_pairs, 0)
  }
})

base <- "data/original/AEJMicro-2011-0182-Data/matlab"
males <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
females <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
# Match csvread: empty numeric fields in the original CSV are zeros.
females[is.na(females)] <- 0
males[is.na(males)] <- 0
beta_brides <- as.numeric(read.csv(file.path(base, "beta_brides_sigma.csv"), header = FALSE)[1, 1:57])
beta_grooms <- as.numeric(read.csv(file.path(base, "beta_grooms_sigma.csv"), header = FALSE)[1, 1:58])

test_that("compiled score features agree with the independent R translation", {
  set.seed(114408)
  for (bride_side in c(TRUE, FALSE)) {
    candidates <- if (bride_side) males[sample.int(nrow(males), 60L), ] else females[sample.int(nrow(females), 60L), ]
    chooser_pool <- if (bride_side) females else males
    for (index in sample.int(nrow(chooser_pool), 12L)) {
      chooser <- chooser_pool[index, ]
      beta <- if (bride_side) beta_brides else beta_grooms
      features <- if (bride_side) bride_features(candidates, chooser) else groom_features(candidates, chooser)
      expected <- as.numeric(round_single(10000 * round_single(features) %*% beta))
      actual <- simulation_scores(candidates, chooser, beta, bride_side)
      expect_lt(max(abs(actual - expected)), .01)
    }
  }
})

test_that("residence correction changes the named feature and no other feature", {
  candidates <- females[1:10, ]
  candidates[, 2] <- 2
  candidates[, 9] <- 0
  chooser <- males[1, ]
  chooser[c(1, 2, 9)] <- c(1, 2, 0)
  original <- groom_features(candidates, chooser)
  corrected <- groom_features(candidates, chooser, TRUE)
  expect_equal(original[, 48], rep(0, 10))
  expect_equal(corrected[, 48], rep(1, 10))
  expect_equal(original[, -48], corrected[, -48])
  beta <- rep(0, 58)
  beta[48] <- 1
  expect_equal(simulation_scores(candidates, chooser, beta, FALSE), rep(0, 10))
  expect_equal(simulation_scores(candidates, chooser, beta, FALSE, TRUE), rep(10000, 10))
})

test_that("compiled preferences preserve the original reordering rule for equal scores", {
  men <- males[1:8, ]
  women <- females[1:12, ]
  compiled <- simulation_preferences(men, women, beta_brides, beta_grooms)
  first_ranks <- build_female_ranks(men, women, beta_brides)
  male_order <- order(rowMeans(first_ranks), method = "radix")
  reordered_ranks <- build_female_ranks(men[male_order, ], women, beta_brides)
  expected_ranks <- reordered_ranks[order(male_order), , drop = FALSE]
  expect_equal(compiled$male_order + 1L, male_order)
  expect_equal(compiled$female_ranks, expected_ranks)
  expect_equal(compiled$male_preferences, build_male_preferences(men, women, beta_grooms))
})

test_that("quality correction restores the actual education contribution", {
  people <- males[1:2, ]
  people[, 17] <- c(2, 6)
  expect_equal(quality_index(people, "male", TRUE) - quality_index(people, "male"), c(-.1749361, -.1197571))
})

test_that("simulation point estimates match the separately produced regression results", {
  mapping <- read.csv("output/simulation_weighting_coefficients.csv")
  regression_results <- read.csv("output/robustness.csv")
  for (model_id in c("T3_1", "T4_1")) {
    for (scheme in c("weighted", "unweighted")) {
      coefficients <- mapping[mapping$model == model_id & mapping$scheme == scheme, ]
      variant <- if (scheme == "weighted") "published" else "unweighted"
      expected <- regression_results[
        regression_results$model == model_id & regression_results$variant == variant,
      ]
      positions <- match(expected$term, coefficients$term)
      expect_false(anyNA(positions))
      expect_equal(coefficients$estimate[positions], expected$estimate, tolerance = 1e-10)
      expect_equal(tail(coefficients$term, 1), "common_intercept")
      expect_equal(tail(coefficients$estimate, 1), 0)
      expect_equal(coefficients$term[48], "sameresstatus")
    }
  }
  expect_equal(subset(mapping, model == "T4_1" & scheme == "weighted" & feature_column == 42)$term, "samenoedu")
  expect_equal(subset(mapping, model == "T4_1" & scheme == "weighted" & feature_column == 43)$term, "noedu_female")
})

test_that("bride handoff correction follows the original regression's signed caste and missingness definitions", {
  woman <- females[1, ]
  man <- males[1, , drop = FALSE]
  woman[c(5, 3, 10, 11, 12, 29, 30)] <- c(4, 27, 0, 1.6, 0, 1, 1)
  man[, c(5, 3, 10, 11, 12)] <- c(1, 0, 1, 0, 1)
  original <- bride_features(man, woman)
  corrected <- bride_features(man, woman, TRUE)
  expect_equal(as.numeric(original[, c(9, 10, 14, 17)]), c(-3, 0, -3, -3))
  expect_equal(as.numeric(corrected[, c(9, 10, 14, 17)]), c(3, 0, 3, 3))
  expect_equal(as.numeric(original[, c(19, 20, 25, 26)]), c(0, 27, 0, 1.6))
  expect_equal(as.numeric(corrected[, c(19, 20, 25, 26)]), c(27, 0, 1.6, 0))
  unchanged <- setdiff(seq_len(57), c(9, 10, 14, 17, 19, 20, 25, 26))
  expect_equal(original[, unchanged], corrected[, unchanged])
  for (column in c(9, 10, 14, 17, 19, 20, 25, 26)) {
    beta <- rep(0, 57)
    beta[column] <- 1
    actual <- simulation_scores(man, woman, beta, TRUE, FALSE, TRUE)
    expect_equal(actual, as.numeric(round_single(10000 * corrected[, column])), tolerance = 1e-6)
  }
})
