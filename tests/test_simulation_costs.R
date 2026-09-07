library(testthat)
source("src/simulation_costs.R")

test_that("source extraction preserves all Table8-style conditional commands", {
  specifications <- read_cost_specifications(
    "data/original/AEJMicro-2011-0182-Data/do/correlations_results.do"
  )
  expect_length(specifications, 35L)
  expect_match(specifications$beta_inc_male_long$command, "^reg logincome_male highercaste samecaste")
  expect_equal(specifications$beta_inc_male_long$coefficient, "samecaste")
  expect_equal(specifications$beta_edu_male_long_inc$coefficient, "edu_max_male")
  expect_match(specifications$beta_edu_female_long$command, "highercaste_female samecaste")
})

make_cost_test_data <- function() {
  same_caste <- rep(c(1, 0, 0), 40)
  higher_caste <- rep(c(0, 1, 0), 40)
  male_rank <- ifelse(higher_caste == 1, 1, ifelse(same_caste == 1, 2, rep(c(2, 3), 60)))
  covariate <- seq_along(same_caste) / 120
  data.frame(
    samecaste = same_caste, highercaste = higher_caste, highercaste_female = as.numeric(male_rank > 2),
    main_caste_rank_male = male_rank, main_caste_rank_female = 2,
    noedu_male = 0, nocaste_male = 0, nocaste_female = 0, covariate = covariate,
    edu_max_male = 5 + 2 * same_caste + 3 * higher_caste + 4 * covariate
  )
}

test_that("conditional coefficients recover known effects and expose equal-rank reference pairs", {
  data <- make_cost_test_data()
  specification <- list(
    command = "reg edu_max_male highercaste samecaste covariate if noedu_male==0;",
    coefficient = "samecaste", output_name = "synthetic", source_line = 1
  )
  result <- estimate_cost(data, specification, rep(TRUE, nrow(data)))
  expect_equal(result$estimate, 2, tolerance = 1e-10)
  expect_equal(result$reference_n, 40)
  expect_equal(result$reference_equal_rank_n, 20)
  expect_equal(result$reference_lower_rank_n, 20)
  specification$coefficient <- "highercaste"
  expect_equal(estimate_cost(data, specification, rep(TRUE, nrow(data)))$estimate, 3, tolerance = 1e-10)
})

test_that("unidentified coefficients are not reported as zero costs", {
  data <- make_cost_test_data()
  data$duplicate_caste <- data$samecaste
  specification <- list(
    command = "reg edu_max_male highercaste samecaste covariate duplicate_caste if noedu_male==0;",
    coefficient = "samecaste", output_name = "synthetic", source_line = 1
  )
  result <- estimate_cost(data, specification, rep(TRUE, nrow(data)))
  expect_false(result$coefficient_estimable)
  expect_true(is.na(result$estimate))
  specification$coefficient <- "covariate"
  result <- estimate_cost(data, specification, rep(TRUE, nrow(data)))
  expect_true(result$coefficient_estimable)
  expect_equal(result$estimate, 4, tolerance = 1e-10)
})

test_that("the original coding allows different subcastes with equal broad rank in the reference", {
  male_path <- "data/original/AEJMicro-2011-0182-Data/matlab/all_males_matlab.csv"
  female_path <- "data/original/AEJMicro-2011-0182-Data/matlab/all_females_matlab.csv"
  men <- read_cost_people(male_path, "male")[1, ]
  women <- read_cost_people(female_path, "female")[1, ]
  raw_males <- as.matrix(read.csv(male_path, header = FALSE))[1, , drop = FALSE]
  raw_females <- as.matrix(read.csv(female_path, header = FALSE))[1, , drop = FALSE]
  raw_males[, c(5, 6, 31)] <- c(4, 0, 24)
  raw_females[, c(5, 6, 31)] <- c(4, 0, 83)
  men$main_caste_rank_male <- women$main_caste_rank_female <- 4
  men$nocaste_male <- women$nocaste_female <- 0
  men$caste_male <- 24
  women$caste_female <- 83
  men$logincome_male <- 10000
  men$noincome_male <- 0
  couples <- build_cost_couples(men, women, 1L, raw_males, raw_females)
  expect_equal(couples$samecaste, 0)
  expect_equal(couples$highercaste, 0)
  expect_equal(couples$highercaste_female, 0)
  expect_equal(couples$logincome_male, 10000)
  men$noincome_male <- 1
  couples <- build_cost_couples(men, women, 1L, raw_males, raw_females)
  expect_equal(couples$logincome_male, 0)
})

test_that("selected real coefficient agrees with independently residualized least squares", {
  base <- "data/original/AEJMicro-2011-0182-Data/matlab"
  male_path <- file.path(base, "all_males_matlab.csv")
  female_path <- file.path(base, "all_females_matlab.csv")
  choices <- subset(read.csv("output/simulation_handoff_choices.csv"), scenario == "weighted_handoff")
  couples <- build_cost_couples(
    read_cost_people(male_path, "male"), read_cost_people(female_path, "female"), choices$woman,
    as.matrix(read.csv(male_path, header = FALSE)), as.matrix(read.csv(female_path, header = FALSE))
  )
  specification <- read_cost_specifications(
    "data/original/AEJMicro-2011-0182-Data/do/correlations_results.do"
  )$beta_inc_male_long
  command <- sub(";$", "", sub("^reg ", "", specification$command))
  pieces <- strsplit(command, " if ", fixed = TRUE)[[1]]
  terms <- expand_cost_terms(sub("^[^ ]+ ", "", pieces[1]))
  data <- couples[which(eval(parse(text = pieces[2]), envir = couples)), ]
  data <- data[complete.cases(data[, c("logincome_male", terms)]), ]
  nuisance <- cbind(1, as.matrix(data[, setdiff(terms, "samecaste")]))
  income_residual <- lm.fit(nuisance, data$logincome_male)$residuals
  caste_residual <- lm.fit(nuisance, data$samecaste)$residuals
  expected <- sum(income_residual * caste_residual) / sum(caste_residual^2)
  result <- estimate_cost(couples, specification, rep(TRUE, nrow(couples)))
  expect_equal(result$estimate, expected, tolerance = 1e-8)
  expect_equal(result$reference_n, result$reference_lower_rank_n + result$reference_equal_rank_n)
})
