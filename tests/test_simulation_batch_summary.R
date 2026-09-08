library(testthat)
source("src/simulation_batch_summary.R")
source("src/simulation_income_bootstrap.R")

test_that("common-sample changes exclude missing outcomes and retain both transition directions", {
  result <- summarize_paired_values(c(1, 0, 1, NA, 0), c(0, 1, NA, 1, 0), rep(TRUE, 5))
  expect_equal(result$common_n, 3)
  expect_equal(result$before, 1 / 3)
  expect_equal(result$after, 1 / 3)
  expect_equal(result$change, 0)
  expect_equal(result$same_to_out, 1)
  expect_equal(result$out_to_same, 1)
  empty <- summarize_paired_values(NA_real_, 1, TRUE)
  expect_equal(empty$common_n, 0)
  expect_true(is.na(empty$change))
})

test_that("paired uncertainty uses within-draw differences and retains increases", {
  data <- data.frame(population = "test", change = c(-.10, -.04, .02, .12))
  summary <- summarize_draw_distribution(data, "population", "change")
  expect_equal(summary$mean, 0)
  expect_equal(summary$p025, -.10)
  expect_equal(summary$p975, .12)
  expect_equal(summary$negative_share, .5)
  expect_equal(summary$valid_pairs, 4)
})

test_that("unknown caste never counts as a same-caste marriage", {
  men <- women <- matrix(0, 3, 31)
  men[, 5] <- women[, 5] <- c(8, 8, 0)
  men[, 31] <- c(79, 80, NA)
  women[, 31] <- c(79, 81, NA)
  men[3, 6] <- women[3, 6] <- 1
  results <- caste_outcomes(men, women)
  expect_equal(results$broad_caste, c(1, 1, NA))
  expect_equal(results$reported_caste, c(1, 0, NA))
})

test_that("resampling an advertiser twice creates separate fixed effects and preserves letter weights", {
  data <- data.frame(SI = c(10, 10, 20), weight = c(.2, .8, 1), considered = c(0, 1, 1))
  result <- resample_advertisers(data, c(10, 20, 10))
  expect_equal(result$SI, c(1, 1, 2, 3, 3))
  expect_equal(result$weight, c(.2, .8, 1, .2, .8))
  expect_equal(result$considered, c(0, 1, 1, 0, 1))
  expect_error(resample_advertisers(data, 30))
})

test_that("coefficient normalization is not invented when a bootstrap category is absent", {
  data <- data.frame(
    SI = rep(1:3, each = 3), considered = c(0, 1, 0, 1, 0, 1, 0, 0, 1),
    x = rep(c(0, 1, 2), 3), z = c(rep(0, 6), 1, 0, 0), weight = 1
  )
  fit <- feols(considered ~ x + z | SI, data = data, weights = ~weight)
  result <- fit_preference_draw(list(data = data, fit = fit, vars = c("x", "z")), c(1, 1, 2))
  expect_identical(result$omitted_terms, "z")
  expect_true(is.na(result$coefficients["z"]))
  expect_equal(unname(result$coefficients["common_intercept"]), 0)
})

source("src/simulation_income_sacrifice.R")

test_that("income gains and losses reconcile while missing incomes stay outside the denominator", {
  result <- summarize_income_changes(c(10, 30, 20, NA), c(30, 10, 20, 100), rep(TRUE, 4))
  expect_equal(result$income_pair_n, 3)
  expect_equal(result$income_coverage, .75)
  expect_equal(result$net_income_gain, 0)
  expect_equal(result$gross_gain_per_woman, 20 / 3)
  expect_equal(result$gross_loss_per_woman, 20 / 3)
  expect_equal(result$gain_share + result$loss_share + result$unchanged_share, 1)
  expect_equal(result$gross_gain_per_woman - result$gross_loss_per_woman, result$net_income_gain)
  expect_true(is.na(summarize_income_changes(NA, 10, TRUE)$net_income_gain))
})

source("src/simulation_income_mar.R")

test_that("MAR imputation preserves observed incomes, uses real donors, and is reproducible", {
  data <- data.frame(income = c(seq(1000, 20000, 1000), rep(NA_real_, 10)), age = seq_len(30))
  first <- impute_market_income(data, 3L, 123L)
  second <- impute_market_income(data, 3L, 123L)
  expect_equal(first, second)
  expect_equal(dim(first), c(30L, 3L))
  expect_equal(first[1:20, 1], data$income[1:20], tolerance = 1e-10)
  expect_true(all(round(first[21:30, ]) %in% data$income[1:20]))
  original_choice <- 1:30
  alternative_choice <- 30:1
  expect_equal(colSums(first[original_choice, ]) - colSums(first[alternative_choice, ]), rep(0, 3))
})
