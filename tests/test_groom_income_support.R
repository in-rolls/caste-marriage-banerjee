library(testthat)
source("src/groom_income_support.R")
audit <- groom_income_support()

test_that("the actual groom earnings fit identifies all fourteen coefficients", {
  expect_equal(nrow(audit$training_matrix), 1929L)
  expect_equal(ncol(audit$training_matrix), 14L)
  expect_equal(qr(audit$training_matrix)$rank, 14L)
  expect_false(anyNA(audit$r_predictions))
  expect_equal(nrow(audit$prediction_matrix), 5629L)
  expect_lt(max(audit$projection_error), 1e-10)
  expect_length(attr(audit$r_predictions, "non-estim"), 0L)
})

test_that("changing coefficient order does not change downstream income predictions", {
  expect_equal(as.numeric(audit$reordered_predictions), as.numeric(audit$r_predictions), tolerance = 1e-10)
})

test_that("the saved counts and point estimate reproduce", {
  saved <- read.csv("output/groom_income_support_counts.csv")
  expect_equal(saved, audit$counts, tolerance = 1e-10)
  premium <- audit$counts$value[audit$counts$quantity == "outside_income_premium"]
  expect_equal(round(100 * premium), 49)
})
