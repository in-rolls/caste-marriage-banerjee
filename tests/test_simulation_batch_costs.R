library(testthat)
source("src/simulation_batch_costs.R")

make_postprocessing_fixture <- function() {
  root <- normalizePath(".")
  helpers <- get("simulation_tools", envir = .GlobalEnv)
  configuration <- list(
    root = root, n_men = 8L, n_women = 12L,
    source_hashes = helpers$hash_batch_sources(root), coefficient_weighting = "synthetic_test_fixture"
  )
  hash <- digest::digest(configuration, algo = "sha256")
  directory <- file.path(tempfile("batch_cost_test_"), hash)
  dir.create(directory, recursive = TRUE)
  saveRDS(configuration, file.path(directory, "configuration.rds"))
  inputs <- helpers$load_batch_inputs(configuration)
  record <- list(
    configuration_hash = hash, scenario = "original", draw = 1L,
    choice = 1:8, blocking_pairs = 0L, independent_blocking_pairs = 0L, elapsed_seconds = 1,
    choice_sha256 = digest::digest(1:8, algo = "sha256"),
    coefficient_sha256 = digest::digest(list(
      inputs$beta_brides[1, 1:57], inputs$beta_grooms[1, 1:58]
    ), algo = "sha256")
  )
  checkpoint <- helpers$batch_checkpoint_path(directory, "original", 1L)
  helpers$write_atomic_rds(record, checkpoint)
  manifest <- data.frame(
    draw = 1:2, scenario = "original", status = c("complete", "pending"),
    elapsed_seconds = c(1, NA), checkpoint = c(checkpoint, sub("0001", "0002", checkpoint))
  )
  write.csv(manifest, file.path(directory, "manifest.csv"), row.names = FALSE)
  list(directory = directory, checkpoint = checkpoint, record = record)
}

test_that("postprocessing accepts only manifest-confirmed, hash-consistent completed records", {
  fixture <- make_postprocessing_fixture()
  on.exit(unlink(dirname(fixture$directory), recursive = TRUE))
  batch <- read_completed_batch(fixture$directory)
  expect_length(batch$records, 1L)
  expect_equal(nrow(batch$manifest), 2L)
  corrupt <- fixture$record
  corrupt$coefficient_sha256 <- "wrong coefficient row"
  saveRDS(corrupt, fixture$checkpoint)
  expect_error(read_completed_batch(fixture$directory))
  saveRDS(fixture$record, fixture$checkpoint)
  manifest <- batch$manifest
  manifest$status[1] <- "running"
  write.csv(manifest, file.path(fixture$directory, "manifest.csv"), row.names = FALSE)
  expect_length(read_completed_batch(fixture$directory)$records, 0L)
})

test_that("partial summaries retain unidentified draws and do not invent intervals from one estimate", {
  estimates <- data.frame(
    scenario = "original", population = "full_market", output_name = "synthetic",
    outcome = "income", coefficient = "samecaste", published_table8_cell = TRUE,
    estimate = c(10, NA), estimation_status = c("identified", "unidentified"), n = c(100, 90)
  )
  manifest <- data.frame(scenario = "original", status = c("complete", "complete", "pending"))
  summary <- summarize_batch_costs(estimates, manifest)
  expect_equal(summary$requested_draws, 3L)
  expect_equal(summary$completed_draws, 2L)
  expect_equal(summary$valid_draws, 1L)
  expect_equal(summary$unidentified_draws, 1L)
  expect_false(summary$batch_complete)
  expect_false(summary$all_requested_draws_identified)
  expect_true(is.na(summary$p025))
  estimates$estimate <- c(10, 20)
  estimates$estimation_status <- "identified"
  summary <- summarize_batch_costs(estimates, manifest)
  expect_equal(c(summary$mean, summary$p025, summary$p975), c(15, 10, 20))
})

test_that("tiny allocations produce every requested cost cell with explicit errors and denominators", {
  fixture <- make_postprocessing_fixture()
  on.exit(unlink(dirname(fixture$directory), recursive = TRUE))
  result <- postprocess_batch_costs(fixture$directory)
  expect_equal(nrow(result$estimates), 70L)
  expect_equal(nrow(result$summary), 70L)
  expect_false(result$provenance$batch_complete)
  expect_equal(result$provenance$completed_allocations, 1L)
  expect_equal(result$provenance$requested_allocations, 2L)
  expect_true(all(result$estimates$population_n >= result$estimates$eligible_n))
  expect_true(all(result$estimates$eligible_n >= result$estimates$n))
  classified_draws <- result$summary$valid_draws + result$summary$unidentified_draws +
    result$summary$estimation_error_draws
  expect_equal(classified_draws, result$summary$completed_draws)
  expect_equal(
    result$counts$classified_caste_n + result$counts$missing_caste_classification_n, result$counts$population_n
  )
  expect_true(all(is.na(result$estimates$estimate[result$estimates$estimation_status != "identified"])))
})

test_that("unknown detailed caste is excluded from the share and retained in its denominator audit", {
  men <- women <- matrix(0, nrow = 2, ncol = 35)
  men[, 5] <- women[, 5] <- 4
  men[, 31] <- c(24, NA)
  women[, 31] <- c(24, 83)
  counts <- batch_caste_counts(men, women, 1:2, c(TRUE, TRUE))
  expect_equal(counts$known_broad_caste_n, 2L)
  expect_equal(counts$classified_caste_n, 1L)
  expect_equal(counts$missing_caste_classification_n, 1L)
  expect_equal(counts$same_caste_share, 1)
})
