library(digest)

parse_batch_options <- function(arguments) {
  options <- list(
    workers = "2", draws = "1:250", scenarios = "original,feature_corrected",
    run_root = "output/simulation_runs", men = "0", women = "0"
  )
  for (argument in arguments) {
    stopifnot(startsWith(argument, "--"), grepl("=", argument, fixed = TRUE))
    parts <- strsplit(sub("^--", "", argument), "=", fixed = TRUE)[[1]]
    key <- gsub("-", "_", parts[1], fixed = TRUE)
    if (!key %in% names(options) || length(parts) != 2L) stop("Unknown or malformed batch option: ", argument)
    options[[key]] <- parts[2]
  }
  for (key in c("workers", "men", "women")) options[[key]] <- as.integer(options[[key]])
  stopifnot(options$workers >= 1L, options$workers <= 4L, options$men >= 0L, options$women >= 0L)
  options$draws <- if (grepl(":", options$draws, fixed = TRUE)) {
    endpoints <- as.integer(strsplit(options$draws, ":", fixed = TRUE)[[1]])
    stopifnot(length(endpoints) == 2L, endpoints[1] <= endpoints[2])
    seq(endpoints[1], endpoints[2])
  } else {
    as.integer(strsplit(options$draws, ",", fixed = TRUE)[[1]])
  }
  options$scenarios <- strsplit(options$scenarios, ",", fixed = TRUE)[[1]]
  stopifnot(
    all(options$draws >= 1L & options$draws <= 250L), !anyDuplicated(options$draws),
    all(options$scenarios %in% c("original", "feature_corrected")), !anyDuplicated(options$scenarios)
  )
  options
}

batch_source_files <- function() {
  c(
    "src/simulation_batch.R", "src/simulation_preferences.cpp", "src/simulation_matching.R",
    "src/simulation_features.R", paste0("data/original/AEJMicro-2011-0182-Data/matlab/", c(
      "all_males_matlab.csv", "all_females_matlab.csv", "beta_brides_sigma.csv", "beta_grooms_sigma.csv"
    ))
  )
}

hash_batch_sources <- function(root) {
  paths <- batch_source_files()
  setNames(vapply(file.path(root, paths), digest, character(1), algo = "sha256", file = TRUE), paths)
}

write_atomic_rds <- function(value, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- tempfile(paste0(basename(path), "."), tmpdir = dirname(path))
  on.exit(unlink(temporary), add = TRUE)
  saveRDS(value, temporary)
  if (!file.rename(temporary, path)) stop("Could not atomically install checkpoint: ", path)
}

write_atomic_csv <- function(value, path) {
  temporary <- tempfile(paste0(basename(path), "."), tmpdir = dirname(path))
  on.exit(unlink(temporary), add = TRUE)
  write.csv(value, temporary, row.names = FALSE)
  if (!file.rename(temporary, path)) stop("Could not atomically install manifest: ", path)
}

batch_checkpoint_path <- function(run_directory, scenario, draw) {
  file.path(run_directory, scenario, sprintf("draw_%04d.rds", draw))
}

validate_batch_checkpoint <- function(record, configuration_hash, scenario, draw, n_men, n_women) {
  stopifnot(
    identical(record$configuration_hash, configuration_hash), identical(record$scenario, scenario),
    identical(as.integer(record$draw), as.integer(draw)), length(record$choice) == n_men,
    all(is.finite(record$choice)), all(record$choice == as.integer(record$choice)),
    all(record$choice >= 1L & record$choice <= n_women), !anyDuplicated(record$choice),
    identical(record$choice_sha256, digest(record$choice, algo = "sha256")),
    identical(as.integer(record$blocking_pairs), 0L),
    identical(as.integer(record$independent_blocking_pairs), 0L),
    length(record$elapsed_seconds) == 1L, is.finite(record$elapsed_seconds), record$elapsed_seconds >= 0
  )
  TRUE
}

load_batch_inputs <- function(configuration) {
  base <- file.path(configuration$root, "data/original/AEJMicro-2011-0182-Data/matlab")
  read_matrix <- function(file) as.matrix(read.csv(file.path(base, file), header = FALSE))
  males <- read_matrix("all_males_matlab.csv")[seq_len(configuration$n_men), , drop = FALSE]
  females <- read_matrix("all_females_matlab.csv")[seq_len(configuration$n_women), , drop = FALSE]
  males[is.na(males)] <- females[is.na(females)] <- 0
  stopifnot(all(is.finite(males)), all(is.finite(females)))
  list(
    males = males, females = females, beta_brides = read_matrix("beta_brides_sigma.csv"),
    beta_grooms = read_matrix("beta_grooms_sigma.csv")
  )
}

run_batch_draw <- function(job) {
  configuration <- get("batch_configuration", envir = .GlobalEnv)
  inputs <- get("batch_inputs", envir = .GlobalEnv)
  destination <- batch_checkpoint_path(configuration$run_directory, job$scenario, job$draw)
  started <- proc.time()[[3]]
  tryCatch(
    {
      stopifnot(identical(hash_batch_sources(configuration$root), configuration$source_hashes))
      if (file.exists(destination)) {
        record <- readRDS(destination)
        validate_batch_checkpoint(
          record, configuration$configuration_hash, job$scenario, job$draw,
          configuration$n_men, configuration$n_women
        )
        return(list(status = "cached", scenario = job$scenario, draw = job$draw, elapsed_seconds = 0))
      }
      message(format(Sys.time(), tz = "UTC", usetz = TRUE), " started ", job$scenario, " draw ", job$draw)
      corrected <- job$scenario == "feature_corrected"
      stopifnot(
        all(is.finite(inputs$beta_brides[job$draw, 1:57])),
        all(is.finite(inputs$beta_grooms[job$draw, 1:58]))
      )
      preferences <- get("simulation_preferences", envir = .GlobalEnv)(
        inputs$males, inputs$females, inputs$beta_brides[job$draw, 1:57],
        inputs$beta_grooms[job$draw, 1:58], corrected, corrected
      )
      matching <- get("simulation_match", envir = .GlobalEnv)(preferences$male_preferences, preferences$female_ranks)
      independent_blocks <- get("check_stability", envir = .GlobalEnv)(
        preferences$male_preferences, preferences$female_ranks, matching$choice
      )
      record <- list(
        configuration_hash = configuration$configuration_hash, scenario = job$scenario, draw = as.integer(job$draw),
        choice = matching$choice, choice_sha256 = digest(matching$choice, algo = "sha256"),
        proposals = matching$proposals, blocking_pairs = matching$blocking_pairs,
        independent_blocking_pairs = independent_blocks, elapsed_seconds = proc.time()[[3]] - started,
        completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
        coefficient_sha256 = digest(list(
          inputs$beta_brides[job$draw, 1:57],
          inputs$beta_grooms[job$draw, 1:58]
        ), algo = "sha256")
      )
      validate_batch_checkpoint(
        record, configuration$configuration_hash, job$scenario, job$draw,
        configuration$n_men, configuration$n_women
      )
      write_atomic_rds(record, destination)
      message(
        record$completed_utc, " completed ", job$scenario, " draw ", job$draw,
        " in ", round(record$elapsed_seconds, 1), " seconds"
      )
      rm(preferences, matching)
      gc()
      list(status = "complete", scenario = job$scenario, draw = job$draw, elapsed_seconds = record$elapsed_seconds)
    },
    error = function(error) {
      failure <- list(
        configuration_hash = configuration$configuration_hash, scenario = job$scenario,
        draw = job$draw, error = conditionMessage(error),
        failed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
      )
      failure_path <- file.path(
        configuration$run_directory, "failures",
        paste0(job$scenario, "_", job$draw, "_", Sys.getpid(), ".rds")
      )
      write_atomic_rds(failure, failure_path)
      message("FAILED ", job$scenario, " draw ", job$draw, ": ", failure$error)
      list(status = "failed", scenario = job$scenario, draw = job$draw, error = failure$error)
    }
  )
}

acquire_batch_lock <- function(run_directory) {
  lock_directory <- file.path(run_directory, "coordinator.lock")
  owner_path <- file.path(lock_directory, "owner.rds")
  if (dir.exists(lock_directory)) {
    if (!file.exists(owner_path)) stop("A batch lock has no owner record; inspect ", lock_directory)
    owner <- readRDS(owner_path)
    if (isTRUE(suppressWarnings(tools::pskill(owner$pid, signal = 0L)))) {
      stop("An active coordinator already owns this batch: PID ", owner$pid)
    }
    unlink(lock_directory, recursive = TRUE)
  }
  if (!dir.create(lock_directory, showWarnings = FALSE)) stop("Another coordinator acquired this batch")
  write_atomic_rds(list(pid = Sys.getpid(), started_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)), owner_path)
  lock_directory
}

run_simulation_batch <- function(options) {
  root <- normalizePath(getwd())
  base <- "data/original/AEJMicro-2011-0182-Data/matlab"
  n_men <- nrow(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
  n_women <- nrow(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
  if (options$men > 0L) n_men <- min(options$men, n_men)
  if (options$women > 0L) n_women <- min(options$women, n_women)
  stopifnot(n_men <= n_women)
  configuration <- list(
    schema_version = 1L, root = root, n_men = n_men, n_women = n_women,
    source_hashes = hash_batch_sources(root), coefficient_weighting = "supplied_unweighted_bootstrap",
    original = "Original utility features in the Rcpp translation; native Matlab equivalence unverified",
    feature_corrected = "Residence correction and confirmed bride-side rank/missing-age/missing-height corrections",
    scoring = "Single-precision feature storage and output scores, double-precision coefficient accumulation",
    r_version = R.version.string, platform = R.version$platform,
    rcpp_version = as.character(utils::packageVersion("Rcpp")),
    digest_version = as.character(utils::packageVersion("digest"))
  )
  configuration_hash <- digest(configuration, algo = "sha256")
  dir.create(options$run_root, recursive = TRUE, showWarnings = FALSE)
  run_directory <- file.path(normalizePath(options$run_root), configuration_hash)
  dir.create(run_directory, showWarnings = FALSE)
  configuration_path <- file.path(run_directory, "configuration.rds")
  if (file.exists(configuration_path)) {
    stopifnot(identical(readRDS(configuration_path), configuration))
  } else {
    write_atomic_rds(configuration, configuration_path)
    dput(configuration, file = file.path(run_directory, "configuration.txt"))
  }
  jobs <- expand.grid(draw = options$draws, scenario = options$scenarios, stringsAsFactors = FALSE)
  # Pair the scenarios for a draw before moving to the next coefficient draw.
  jobs <- jobs[order(jobs$draw, match(jobs$scenario, options$scenarios)), ]
  jobs$status <- "pending"
  jobs$elapsed_seconds <- NA_real_
  jobs$checkpoint <- mapply(batch_checkpoint_path, run_directory, jobs$scenario, jobs$draw, USE.NAMES = FALSE)
  for (row in which(file.exists(jobs$checkpoint))) {
    record <- readRDS(jobs$checkpoint[row])
    validate_batch_checkpoint(record, configuration_hash, jobs$scenario[row], jobs$draw[row], n_men, n_women)
    jobs$status[row] <- "complete"
    jobs$elapsed_seconds[row] <- record$elapsed_seconds
  }
  started <- format(Sys.time(), tz = "UTC", usetz = TRUE)
  write_status <- function(status) {
    write_atomic_csv(jobs, file.path(run_directory, "manifest.csv"))
    write_atomic_csv(data.frame(
      configuration_hash = configuration_hash, status = status, pid = Sys.getpid(),
      requested_allocations = nrow(jobs), completed = sum(jobs$status == "complete"),
      failed = sum(jobs$status == "failed"), workers = options$workers,
      started_utc = started, updated_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ), file.path(run_directory, "status.csv"))
  }
  message("Run directory: ", run_directory)
  pending <- which(jobs$status != "complete")
  if (!length(pending)) {
    write_status("complete")
    return(invisible(run_directory))
  }
  lock_directory <- acquire_batch_lock(run_directory)
  on.exit(unlink(lock_directory, recursive = TRUE), add = TRUE)
  write_status("running")
  completed <- FALSE
  on.exit(if (!completed) write_status("stopped_before_completion"), add = TRUE)
  batch_configuration <- c(configuration, list(configuration_hash = configuration_hash, run_directory = run_directory))
  cluster <- parallel::makePSOCKcluster(options$workers, outfile = file.path(run_directory, "workers.log"))
  on.exit(parallel::stopCluster(cluster), add = TRUE)
  worker_exports <- c(
    "batch_configuration", "batch_source_files", "hash_batch_sources", "write_atomic_rds",
    "batch_checkpoint_path", "validate_batch_checkpoint", "load_batch_inputs", "run_batch_draw"
  )
  parallel::clusterExport(cluster, worker_exports, envir = environment())
  parallel::clusterEvalQ(cluster, {
    library(digest)
    setwd(batch_configuration$root)
    stopifnot(identical(hash_batch_sources(batch_configuration$root), batch_configuration$source_hashes))
    source("src/simulation_matching.R")
    Rcpp::sourceCpp("src/simulation_preferences.cpp",
      cacheDir = file.path(batch_configuration$run_directory, paste0("compiled_", Sys.getpid()))
    )
    assign("batch_inputs", load_batch_inputs(batch_configuration), envir = .GlobalEnv)
    NULL
  })
  batches <- split(pending, ceiling(seq_along(pending) / options$workers))
  for (rows in batches) {
    stopifnot(identical(hash_batch_sources(root), configuration$source_hashes))
    jobs$status[rows] <- "running"
    write_status("running")
    work <- lapply(rows, function(row) list(scenario = jobs$scenario[row], draw = jobs$draw[row]))
    results <- parallel::parLapplyLB(cluster, work, run_batch_draw)
    for (index in seq_along(rows)) {
      row <- rows[index]
      result <- results[[index]]
      jobs$status[row] <- if (result$status %in% c("complete", "cached")) "complete" else "failed"
      if (!is.null(result$elapsed_seconds)) jobs$elapsed_seconds[row] <- result$elapsed_seconds
    }
    write_status("running")
    message(sum(jobs$status == "complete"), "/", nrow(jobs), " allocations complete")
    if (any(jobs$status == "failed")) {
      stop("A worker failed; successful checkpoints are preserved. See failures/ and workers.log")
    }
  }
  completed <- TRUE
  write_status("complete")
  invisible(run_directory)
}

if (sys.nframe() == 0L) {
  run_simulation_batch(parse_batch_options(commandArgs(trailingOnly = TRUE)))
}
