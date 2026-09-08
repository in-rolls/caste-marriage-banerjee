batch_summary_tools <- new.env()
sys.source("src/simulation_batch_costs.R", envir = batch_summary_tools)

caste_outcomes <- function(men, women) {
  known <- men[, 6] == 0 & women[, 6] == 0
  known[is.na(known)] <- FALSE
  narrow <- batch_summary_tools$simulation_tools$reported_same_caste(men, women)
  narrow[!known] <- NA_real_
  broad <- as.numeric(men[, 5] == women[, 5])
  broad[!known] <- NA_real_
  list(reported_caste = narrow, broad_caste = broad)
}

summarize_paired_values <- function(before, after, keep) {
  stopifnot(length(before) == length(after), length(keep) == length(before), !anyNA(keep))
  common <- keep & !is.na(before) & !is.na(after)
  n <- sum(common)
  data.frame(
    eligible_n = sum(keep), common_n = n,
    before = if (n) mean(before[common]) else NA_real_,
    after = if (n) mean(after[common]) else NA_real_,
    change = if (n) mean(after[common] - before[common]) else NA_real_,
    same_to_out = sum(before[common] == 1 & after[common] == 0),
    out_to_same = sum(before[common] == 0 & after[common] == 1)
  )
}

summarize_draw_distribution <- function(data, groups, value) {
  keys <- interaction(data[, groups, drop = FALSE], drop = TRUE, lex.order = TRUE)
  do.call(rbind, lapply(split(data, keys), function(group) {
    values <- group[[value]][is.finite(group[[value]])]
    interval <- if (length(values)) quantile(values, c(.025, .975), type = 2, names = FALSE) else c(NA, NA)
    cbind(group[1, groups, drop = FALSE],
      statistic = value, requested_pairs = nrow(group),
      valid_pairs = length(values), mean = if (length(values)) mean(values) else NA_real_,
      median = if (length(values)) median(values) else NA_real_, p025 = interval[1], p975 = interval[2],
      negative_share = if (length(values)) mean(values < 0) else NA_real_,
      positive_share = if (length(values)) mean(values > 0) else NA_real_,
      zero_share = if (length(values)) mean(values == 0) else NA_real_
    )
  }))
}

summarize_matching_batch <- function(run_directory, output_directory = "output") {
  batch <- batch_summary_tools$read_completed_batch(run_directory)
  records <- batch$records
  configuration <- batch$configuration
  base <- file.path(configuration$root, "data/original/AEJMicro-2011-0182-Data/matlab")
  men <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
  women <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
  men <- men[seq_len(configuration$n_men), , drop = FALSE]
  women <- women[seq_len(configuration$n_women), , drop = FALSE]
  crosswalk_path <- "output/simulation_interview_crosswalk.csv"
  crosswalk <- read.csv(crosswalk_path)
  verified <- crosswalk[crosswalk$status == "verified_identifier_and_attributes", ]
  interview_men <- seq_len(nrow(men)) %in% verified$simulation_row[verified$sex == "male"]
  interview_women <- seq_len(nrow(women)) %in% verified$simulation_row[verified$sex == "female"]
  paired_draws <- Reduce(intersect, lapply(c("original", "feature_corrected"), function(scenario) {
    vapply(
      records[vapply(records, function(record) record$scenario == scenario, logical(1))],
      function(record) record$draw, integer(1)
    )
  }))
  if (!length(paired_draws)) stop("No complete original/corrected pairs")
  indexed <- setNames(records, vapply(records, function(record) paste(record$draw, record$scenario), character(1)))
  moments <- pairs <- allocations <- list()
  for (draw in paired_draws) {
    original <- indexed[[paste(draw, "original")]]$choice
    corrected <- indexed[[paste(draw, "feature_corrected")]]$choice
    before <- caste_outcomes(men, women[original, , drop = FALSE])
    after <- caste_outcomes(men, women[corrected, , drop = FALSE])
    before_interview <- interview_men | interview_women[original]
    after_interview <- interview_men | interview_women[corrected]
    for (scenario in c("original", "feature_corrected")) {
      values <- if (scenario == "original") before else after
      interview <- if (scenario == "original") before_interview else after_interview
      for (population in c("full_market", "verified_interview_subset", "verified_interview_men")) {
        keep <- switch(population,
          full_market = rep(TRUE, nrow(men)),
          verified_interview_subset = interview,
          verified_interview_men = interview_men
        )
        for (definition in names(values)) {
          classified <- keep & !is.na(values[[definition]])
          moments[[paste(draw, scenario, population, definition)]] <- data.frame(
            draw = draw, scenario = scenario, population = population, definition = definition,
            eligible_n = sum(keep), classified_n = sum(classified), same_n = sum(values[[definition]][classified]),
            share = mean(values[[definition]][classified])
          )
        }
      }
    }
    populations <- list(
      full_market = rep(TRUE, nrow(men)),
      men_in_both_interview_samples = before_interview & after_interview,
      verified_interview_men = interview_men
    )
    for (rank in sort(unique(men[men[, 6] == 0, 5]))) {
      keep <- men[, 6] == 0 & men[, 5] == rank
      keep[is.na(keep)] <- FALSE
      populations[[paste0("male_caste_rank_", rank)]] <- keep
    }
    for (population in names(populations)) {
      for (definition in names(before)) {
        pairs[[paste(draw, population, definition)]] <- cbind(
          draw = draw, population = population, definition = definition,
          summarize_paired_values(before[[definition]], after[[definition]], populations[[population]])
        )
      }
    }
    old_husbands <- new_husbands <- integer(nrow(women))
    old_husbands[original] <- new_husbands[corrected] <- seq_len(nrow(men))
    common_women <- which(old_husbands > 0 & new_husbands > 0)
    old_women_outcomes <- caste_outcomes(men[old_husbands[common_women], , drop = FALSE], women[common_women, ])
    new_women_outcomes <- caste_outcomes(men[new_husbands[common_women], , drop = FALSE], women[common_women, ])
    for (population in c("common_matched_women", "common_matched_interview_women")) {
      keep <- if (population == "common_matched_women") {
        rep(TRUE, length(common_women))
      } else {
        interview_women[common_women]
      }
      for (definition in names(before)) {
        pairs[[paste(draw, population, definition)]] <- cbind(
          draw = draw, population = population, definition = definition,
          summarize_paired_values(old_women_outcomes[[definition]], new_women_outcomes[[definition]], keep)
        )
      }
    }
    allocations[[as.character(draw)]] <- data.frame(
      draw = draw, men = nrow(men), changed_matches = sum(original != corrected),
      changed_share = mean(original != corrected), women_matched_in_both = length(common_women),
      women_entering_marriage = sum(old_husbands == 0 & new_husbands > 0),
      women_leaving_marriage = sum(old_husbands > 0 & new_husbands == 0)
    )
  }
  moments <- do.call(rbind, moments)
  pairs <- do.call(rbind, pairs)
  allocations <- do.call(rbind, allocations)
  marginal_pairs <- merge(subset(moments, scenario == "original"),
    subset(moments, scenario == "feature_corrected"),
    by = c("draw", "population", "definition"),
    suffixes = c("_original", "_corrected")
  )
  marginal_pairs$change <- marginal_pairs$share_corrected - marginal_pairs$share_original
  summary <- rbind(
    cbind(comparison = "scenario_levels", summarize_draw_distribution(
      moments, c("population", "definition", "scenario"), "share"
    )),
    cbind(comparison = "scenario_difference", scenario = "corrected_minus_original", summarize_draw_distribution(
      marginal_pairs, c("population", "definition"), "change"
    )),
    cbind(comparison = "common_sample_difference", scenario = "corrected_minus_original", summarize_draw_distribution(
      pairs, c("population", "definition"), "change"
    ))
  )
  provenance <- data.frame(
    configuration_hash = batch$configuration_hash, completed_allocations = length(records),
    requested_allocations = nrow(batch$manifest), completed_pairs = length(paired_draws),
    complete = length(records) == nrow(batch$manifest),
    coefficient_weighting = configuration$coefficient_weighting,
    summary_sha256 = digest::digest(file = "src/simulation_batch_summary.R", algo = "sha256"),
    crosswalk_sha256 = digest::digest(file = crosswalk_path, algo = "sha256"),
    generated_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    uncertainty = "2.5/97.5 percentiles across supplied coefficient draws, fixed people and matching assumptions"
  )
  dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
  outputs <- list(
    moments = moments, pairs = pairs, allocations = allocations, summary = summary, provenance = provenance
  )
  for (name in names(outputs)) {
    batch_summary_tools$simulation_tools$write_atomic_csv(
      outputs[[name]], file.path(output_directory, paste0("simulation_batch_", name, ".csv"))
    )
  }
  message(length(paired_draws), " complete paired draws summarized")
  invisible(summary)
}

if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(arguments) == 1L)
  summarize_matching_batch(arguments[1])
}
