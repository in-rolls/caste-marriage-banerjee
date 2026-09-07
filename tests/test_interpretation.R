library(testthat)
library(fixest)

analysis_environment <- new.env(parent = globalenv())
sys.source("src/resource_heterogeneity.R", envir = analysis_environment)
analysis_environment$point_estimates <- analysis_environment$fit_heterogeneity(analysis_environment$analysis_data)

test_that("background counts account for the exact limited-model sample", {
  background_counts <- read.csv("output/economic_background_counts.csv")
  expect_equal(sum(background_counts$all_advertisers), 783)
  expect_equal(sum(background_counts$groom_search_advertisers), 506)
  expect_equal(sum(background_counts$groom_search_letters), nobs(analysis_environment$model$fit))
})

test_that("the complete estimation procedure reproduces saved point estimates and bootstrap draws", {
  saved_estimates <- read.csv("output/resource_heterogeneity.csv")
  expect_equal(unname(analysis_environment$point_estimates), saved_estimates$estimate, tolerance = 1e-10)
  saved_draws <- read.csv("output/resource_heterogeneity_draws.csv")
  analysis_data <- analysis_environment$analysis_data
  advertiser_rows <- split(seq_len(nrow(analysis_data)), analysis_data$SI)
  set.seed(114408)
  for (draw in seq_len(5L)) {
    selected_rows <- advertiser_rows[sample(seq_along(advertiser_rows), length(advertiser_rows), replace = TRUE)]
    sample_data <- analysis_data[unlist(selected_rows, use.names = FALSE), ]
    sample_data$SI <- rep(seq_along(selected_rows), lengths(selected_rows))
    recalculated <- analysis_environment$fit_heterogeneity(sample_data)
    expect_equal(unname(recalculated), unname(unlist(saved_draws[draw, ])), tolerance = 1e-10)
  }
})

test_that("the conservative simulation crosswalk never admits an ambiguous identity or wrong sex", {
  crosswalk <- read.csv("output/simulation_interview_crosswalk.csv")
  verified <- crosswalk[crosswalk$status == "verified_identifier_and_attributes", ]
  interview_ads <- readRDS("output/prepared.rds")$ads
  expected_sex <- ifelse(interview_ads$brides[match(verified$SI, interview_ads$SI)] == 0, "male", "female")
  expect_equal(nrow(crosswalk), 22210L)
  expect_false(anyNA(verified$SI))
  expect_equal(anyDuplicated(verified$SI), 0L)
  expect_equal(verified$sex, expected_sex)
  expect_true(all(verified$attributes_agree))
  ambiguous <- crosswalk$status == "ambiguous_interview_identifier"
  expect_true(all(is.na(crosswalk$SI[ambiguous])))
})
