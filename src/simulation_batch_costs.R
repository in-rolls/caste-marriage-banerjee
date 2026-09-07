simulation_tools <- new.env()
for (path in c("src/simulation_batch.R", "src/simulation_costs.R", "src/simulation_matching.R")) {
  sys.source(path, envir = simulation_tools)
}

read_completed_batch <- function(run_directory) {
  configuration <- readRDS(file.path(run_directory, "configuration.rds"))
  configuration_hash <- digest::digest(configuration, algo = "sha256")
  stopifnot(identical(basename(normalizePath(run_directory)), configuration_hash))
  input_paths <- names(configuration$source_hashes)[startsWith(names(configuration$source_hashes), "data/")]
  actual_hashes <- vapply(file.path(configuration$root, input_paths),
    digest::digest, character(1), algo = "sha256", file = TRUE
  )
  names(actual_hashes) <- input_paths
  stopifnot(identical(actual_hashes, configuration$source_hashes[input_paths]))
  manifest <- read.csv(file.path(run_directory, "manifest.csv"))
  stopifnot(!anyDuplicated(paste(manifest$scenario, manifest$draw)))
  stopifnot(all(manifest$scenario %in% c("original", "feature_corrected")))
  stopifnot(all(manifest$draw %in% 1:250))
  completed <- manifest[manifest$status == "complete", , drop = FALSE]
  inputs <- simulation_tools$load_batch_inputs(configuration)
  records <- lapply(seq_len(nrow(completed)), function(row) {
    expected_path <- simulation_tools$batch_checkpoint_path(run_directory, completed$scenario[row], completed$draw[row])
    stopifnot(identical(normalizePath(completed$checkpoint[row]), normalizePath(expected_path)))
    record <- readRDS(expected_path)
    simulation_tools$validate_batch_checkpoint(
      record, configuration_hash, completed$scenario[row], completed$draw[row],
      configuration$n_men, configuration$n_women
    )
    expected_coefficients <- digest::digest(list(
      inputs$beta_brides[record$draw, 1:57], inputs$beta_grooms[record$draw, 1:58]
    ), algo = "sha256")
    stopifnot(identical(record$coefficient_sha256, expected_coefficients))
    record
  })
  list(configuration = configuration, configuration_hash = configuration_hash, manifest = manifest, records = records)
}

batch_cost_sample <- function(couples, specification, population) {
  command <- sub(";$", "", sub("^reg ", "", specification$command))
  pieces <- strsplit(command, " if ", fixed = TRUE)[[1]]
  outcome <- strsplit(pieces[1], " ", fixed = TRUE)[[1]][1]
  terms <- simulation_tools$expand_cost_terms(sub("^[^ ]+ ", "", pieces[1]))
  eligible <- population & eval(parse(text = pieces[2]), envir = couples)
  eligible[is.na(eligible)] <- FALSE
  complete <- complete.cases(couples[, c(outcome, terms)])
  list(
    outcome = outcome, terms = terms, population_n = sum(population),
    eligible_n = sum(eligible), complete_n = sum(eligible & complete)
  )
}

estimate_batch_cost <- function(couples, specification, population) {
  sample <- batch_cost_sample(couples, specification, population)
  result <- if (sample$complete_n == 0L) {
    simpleError("No complete observations in this reporting population")
  } else {
    tryCatch(simulation_tools$estimate_cost(couples, specification, population), error = identity)
  }
  if (inherits(result, "error")) {
    result <- data.frame(
      output_name = specification$output_name, outcome = sample$outcome, coefficient = specification$coefficient,
      published_table8_cell = sample$outcome != "logincome_female",
      panel = if (grepl("_male", specification$output_name, fixed = TRUE)) "male_attributes" else "female_attributes",
      estimate = NA_real_, n = sample$complete_n, design_columns = length(sample$terms) + 1L,
      design_rank = NA_integer_, coefficient_estimable = FALSE,
      caste_model = any(c("highercaste", "highercaste_female") %in% sample$terms),
      same_caste_n = NA_integer_, higher_caste_n = NA_integer_, reference_n = NA_integer_,
      reference_lower_rank_n = NA_integer_, reference_equal_rank_n = NA_integer_,
      same_and_higher_n = NA_integer_, source_line = specification$source_line,
      estimation_status = "error", estimation_error = conditionMessage(result)
    )
  } else {
    result$estimation_status <- if (result$coefficient_estimable) "identified" else "unidentified"
    result$estimation_error <- NA_character_
  }
  result$population_n <- sample$population_n
  result$eligible_n <- sample$eligible_n
  result$missing_model_values_n <- sample$eligible_n - sample$complete_n
  result$omission_policy <- paste(
    "Unidentified coefficients are NA;", "native Stata omitted-coefficient normalization not reproduced"
  )
  result
}

batch_caste_counts <- function(raw_males, raw_females, choice, population) {
  wives <- raw_females[choice, , drop = FALSE]
  same <- simulation_tools$reported_same_caste(raw_males, wives)
  known_rank <- raw_males[, 6] == 0 & wives[, 6] == 0
  classified <- known_rank & !is.na(same)
  data.frame(
    population_n = sum(population), known_broad_caste_n = sum(population & known_rank),
    classified_caste_n = sum(population & classified),
    missing_caste_classification_n = sum(population & !classified),
    same_caste_n = sum(same[population & classified] == 1),
    same_caste_share = if (any(population & classified)) mean(same[population & classified]) else NA_real_
  )
}

summarize_batch_costs <- function(estimates, manifest) {
  groups <- split(estimates, interaction(estimates$scenario, estimates$population, estimates$output_name, drop = TRUE))
  do.call(rbind, lapply(groups, function(group) {
    valid <- group$estimation_status == "identified" & is.finite(group$estimate)
    selected <- manifest$scenario == group$scenario[1]
    requested <- sum(selected)
    completed <- sum(selected & manifest$status == "complete")
    values <- group$estimate[valid]
    interval <- if (length(values) >= 2L) quantile(values, c(0.025, 0.975), type = 2, names = FALSE) else c(NA, NA)
    cbind(group[1, c("scenario", "population", "output_name", "outcome", "coefficient", "published_table8_cell")],
      requested_draws = requested, completed_draws = completed, valid_draws = sum(valid),
      unidentified_draws = sum(group$estimation_status == "unidentified"),
      estimation_error_draws = sum(group$estimation_status == "error"),
      batch_complete = requested == completed,
      all_requested_draws_identified = requested == sum(valid),
      mean = if (length(values)) mean(values) else NA_real_, p025 = interval[1], p975 = interval[2],
      n_min = min(group$n), n_max = max(group$n),
      interval_label = "Supplied-draw percentiles among identified coefficients; partial if batch incomplete"
    )
  }))
}

postprocess_batch_costs <- function(run_directory, output_directory = file.path(run_directory, "table8")) {
  batch <- read_completed_batch(run_directory)
  if (!length(batch$records)) stop("No manifest-confirmed completed allocations are available")
  configuration <- batch$configuration
  base <- file.path(configuration$root, "data/original/AEJMicro-2011-0182-Data")
  male_path <- file.path(base, "matlab/all_males_matlab.csv")
  female_path <- file.path(base, "matlab/all_females_matlab.csv")
  men <- simulation_tools$read_cost_people(male_path, "male")[seq_len(configuration$n_men), ]
  women <- simulation_tools$read_cost_people(female_path, "female")[seq_len(configuration$n_women), ]
  raw_males <- as.matrix(read.csv(male_path, header = FALSE))[seq_len(configuration$n_men), , drop = FALSE]
  raw_females <- as.matrix(read.csv(female_path, header = FALSE))[seq_len(configuration$n_women), , drop = FALSE]
  source_path <- file.path(base, "do/correlations_results.do")
  specifications <- simulation_tools$read_cost_specifications(source_path)
  crosswalk_path <- file.path(configuration$root, "output/simulation_interview_crosswalk.csv")
  crosswalk <- read.csv(crosswalk_path)
  verified <- crosswalk[crosswalk$status == "verified_identifier_and_attributes", ]
  interview_men <- verified$simulation_row[verified$sex == "male"]
  interview_women <- verified$simulation_row[verified$sex == "female"]
  results <- counts <- list()
  for (record in batch$records) {
    couples <- simulation_tools$build_cost_couples(men, women, record$choice, raw_males, raw_females)
    for (population in c("full_market", "verified_interview_subset")) {
      keep <- if (population == "full_market") {
        rep(TRUE, nrow(men))
      } else {
        seq_len(nrow(men)) %in% interview_men | record$choice %in% interview_women
      }
      prefix <- data.frame(scenario = record$scenario, draw = record$draw, population = population)
      key <- paste(record$scenario, record$draw, population)
      counts[[key]] <- cbind(prefix, batch_caste_counts(raw_males, raw_females, record$choice, keep))
      for (name in names(specifications)) {
        results[[paste(key, name)]] <- cbind(prefix, estimate_batch_cost(couples, specifications[[name]], keep))
      }
    }
  }
  estimates <- do.call(rbind, results)
  counts <- do.call(rbind, counts)
  summary <- summarize_batch_costs(estimates, batch$manifest)
  provenance_files <- c(
    "src/simulation_batch_costs.R", "src/simulation_costs.R", "src/simulation_matching.R",
    "src/simulation_features.R", "output/simulation_interview_crosswalk.csv"
  )
  postprocessing_hashes <- vapply(file.path(configuration$root, provenance_files),
    digest::digest, character(1), algo = "sha256", file = TRUE
  )
  names(postprocessing_hashes) <- provenance_files
  provenance <- data.frame(
    configuration_hash = batch$configuration_hash,
    requested_allocations = nrow(batch$manifest), completed_allocations = length(batch$records),
    batch_complete = nrow(batch$manifest) == length(batch$records),
    coefficient_weighting = configuration$coefficient_weighting,
    reporting_source_sha256 = digest::digest(source_path, algo = "sha256", file = TRUE),
    postprocessing_sha256 = digest::digest(postprocessing_hashes, algo = "sha256"),
    generated_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
  )
  dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
  for (name in c("estimates", "counts", "summary", "provenance")) {
    destination <- file.path(output_directory, paste0("simulation_batch_cost_", name, ".csv"))
    simulation_tools$write_atomic_csv(get(name), destination)
  }
  message(
    length(batch$records), "/", nrow(batch$manifest), " completed allocations processed; ",
    sum(estimates$estimation_status == "error"), " regression errors; ",
    sum(estimates$estimation_status == "unidentified"), " unidentified requested coefficients"
  )
  invisible(list(estimates = estimates, counts = counts, summary = summary, provenance = provenance))
}

if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(arguments) %in% 1:2)
  if (length(arguments) == 1L) {
    postprocess_batch_costs(arguments[1])
  } else {
    postprocess_batch_costs(arguments[1], arguments[2])
  }
}
