library(testthat)
library(fixest)
setFixest_nthreads(1)
x <- readRDS("output/prepared.rds")
m <- readRDS("output/models.rds")
test_that("sample sizes and identifiers reproduce the supplied archive", {
  expect_equal(nrow(x$ads), 783L)
  expect_equal(nrow(x$marriages), 289L)
  expect_equal(anyDuplicated(x$ads$SI), 0L)
  expect_equal(nobs(m$T3_1$fit), 5628L)
  expect_equal(nobs(m$T4_1$fit), 3944L)
  expect_equal(m$T3_5$fit$n, 5628L)
})
test_that("displayed caste coefficients and standard errors reproduce", {
  z <- read.csv("output/published_comparison.csv")
  expect_equal(nrow(z), 28L)
  expect_true(all(z$coefficient_matches_rounding))
  expect_equal(sum(z$se_matches_rounding), 27L)
  expect_lt(max(abs(z$published_se - z$reproduced_se)), .0001)
})
test_that("independent weighted within regression agrees", {
  for (id in c("T3_1", "T4_1")) {
    z <- m[[id]]$data
    vars <- m[[id]]$vars
    z <- z[complete.cases(z[, c("considered", "weight", "SI", vars)]) & z$weight > 0, ]
    columns <- c("considered", vars)
    within <- vapply(columns, function(v) {
      z[[v]] - ave(z[[v]] * z$weight, z$SI, FUN = sum) / ave(z$weight, z$SI, FUN = sum)
    }, numeric(nrow(z)))
    fit <- lm.wfit(within[, -1], within[, 1], z$weight)
    expect_equal(unname(fit$coefficients["samecaste"]), unname(coef(m[[id]]$fit)["samecaste"]), tolerance = 1e-7)
  }
})
test_that("reported WTP is the specified coefficient ratio", {
  z <- read.csv("output/income_tradeoffs.csv")
  z <- z[z$model == "T3_1", ]
  expect_equal(z$samecaste, .1395441813, tolerance = 1e-8)
  expect_equal(z$predicted_income, .3477957257, tolerance = 1e-8)
  expect_equal(z$outside_income_premium, exp(z$samecaste / z$predicted_income) - 1)
  expect_equal(z$inside_income_discount, z$outside_income_premium / (1 + z$outside_income_premium))
})
test_that("structural findings count actual affected observations", {
  z <- read.csv("output/residence_feature_error.csv")
  expect_equal(z$pairs[z$check == "total"], 8038 * 14172)
  expect_equal(z$pairs[z$check == "changed"], sum(z$pairs[z$check %in% c("false_positive", "false_negative")]))
  expect_true(all(read.csv("output/caste_typo_impact.csv")$typo_changes == 0))
})
test_that("resampling preserves weights and first-stage uncertainty", {
  z <- read.csv("output/income_bootstrap_draws.csv")
  expect_equal(nrow(z), 1999L)
  expect_true(all(is.finite(as.matrix(z))))
  expect_equal(z$log_tradeoff, z$samecaste / z$predicted_income)
  identities <- read.csv("output/weight_identities.csv")
  expect_lt(max(abs(identities$error), na.rm = TRUE), 1e-8)
})
test_that("original inputs agree with the recorded provenance manifest", {
  manifest <- read.csv("data/manifest.csv")
  hashes <- vapply(manifest$file, function(file) {
    digest::digest(file = file.path("data/original", file), algo = "sha256")
  }, character(1))
  expect_identical(unname(hashes), manifest$sha256)
})
