library(testthat)
source("src/simulation_batch.R")

test_that("batch options reject invalid draw sets and bound concurrency", {
  options <- parse_batch_options(c("--workers=2", "--draws=1:3", "--scenarios=original"))
  expect_equal(options$draws, 1:3)
  expect_equal(options$workers, 2)
  expect_error(parse_batch_options("--draws=1,1"))
  expect_error(parse_batch_options("--draws=251"))
  expect_error(parse_batch_options("--workers=8"))
  expect_error(parse_batch_options("--scenarios=unknown"))
})

test_that("checkpoint validation rejects wrong sources, corruption, and absent stability evidence", {
  record <- list(
    configuration_hash = "expected", scenario = "original", draw = 1L,
    choice = c(2L, 1L), proposals = 3, blocking_pairs = 0L,
    independent_blocking_pairs = 0L, elapsed_seconds = 1
  )
  record$choice_sha256 <- digest(record$choice, algo = "sha256")
  expect_true(validate_batch_checkpoint(record, "expected", "original", 1L, 2L, 3L))
  expect_error(validate_batch_checkpoint(record, "other", "original", 1L, 2L, 3L))
  corrupt <- record
  corrupt$choice[1] <- 1L
  expect_error(validate_batch_checkpoint(corrupt, "expected", "original", 1L, 2L, 3L))
  corrupt <- record
  corrupt$blocking_pairs <- NULL
  expect_error(validate_batch_checkpoint(corrupt, "expected", "original", 1L, 2L, 3L))
})

test_that("two-worker checkpoints resume without recomputing completed tiny markets", {
  run_root <- tempfile("simulation_batch_test_")
  options <- parse_batch_options(c(
    "--workers=2", "--draws=1:2", "--men=8", "--women=12",
    paste0("--run-root=", run_root)
  ))
  run_directory <- run_simulation_batch(options)
  manifest <- read.csv(file.path(run_directory, "manifest.csv"))
  expect_equal(nrow(manifest), 4L)
  expect_true(all(manifest$status == "complete"))
  original_times <- file.info(manifest$checkpoint)$mtime
  checksums <- vapply(manifest$checkpoint, digest, character(1), algo = "sha256", file = TRUE)
  resumed_directory <- run_simulation_batch(options)
  expect_identical(resumed_directory, run_directory)
  expect_identical(file.info(manifest$checkpoint)$mtime, original_times)
  expect_identical(vapply(manifest$checkpoint, digest, character(1), algo = "sha256", file = TRUE), checksums)
  expect_equal(read.csv(file.path(run_directory, "status.csv"))$completed, 4L)
  configuration <- readRDS(file.path(run_directory, "configuration.rds"))
  configuration_hash <- digest(configuration, algo = "sha256")
  for (row in seq_len(nrow(manifest))) {
    record <- readRDS(manifest$checkpoint[row])
    expect_true(validate_batch_checkpoint(
      record, configuration_hash, manifest$scenario[row],
      manifest$draw[row], 8L, 12L
    ))
  }
  assign("batch_configuration", c(configuration, list(
    configuration_hash = configuration_hash,
    run_directory = run_directory
  )), envir = .GlobalEnv)
  assign("batch_inputs", load_batch_inputs(configuration), envir = .GlobalEnv)
  batch_configuration$source_hashes[1] <- "changed_source"
  assign("batch_configuration", batch_configuration, envir = .GlobalEnv)
  result <- run_batch_draw(list(scenario = "original", draw = 3L))
  expect_equal(result$status, "failed")
  expect_false(file.exists(batch_checkpoint_path(run_directory, "original", 3L)))
  expect_length(list.files(file.path(run_directory, "failures")), 1L)
})


test_that("an active batch cannot be launched twice", {
  directory <- tempfile("simulation_batch_lock_")
  dir.create(directory)
  lock_directory <- acquire_batch_lock(directory)
  expect_error(acquire_batch_lock(directory), "active coordinator")
  expect_true(dir.exists(lock_directory))
  unlink(directory, recursive = TRUE)
})
