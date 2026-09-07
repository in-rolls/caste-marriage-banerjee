source("src/simulation_matching.R")

read_cost_people <- function(path, sex) {
  people <- as.data.frame(read.csv(path, header = FALSE))
  names(people) <- c(
    "family_origin", "resstatus", "age", "skinrank", "main_caste_rank", "nocaste", "nofamily",
    "calcutta", "nores", "noage", "height", "noheight", "noskin", "vbeautiful", "beautiful",
    "nobeauty", "edu_max", "other_edu", "noedu", "human", "comm", "science", "otherfield",
    "nofield", "logincome", "noincome", "logwage", "nowage", "casteimportant", "castenotimp",
    "caste", "id1", "id2", "id3", "id4"
  )
  # The original reporting program exponentiates this column before the cost regressions.
  people$logincome <- exp(people$logincome)
  for (entry in list(c("age", "noage"), c("height", "noheight"))) {
    people[[entry[1]]][people[[entry[2]]] == 1] <- NA_real_
  }
  names(people) <- paste0(names(people), "_", sex)
  people
}

build_cost_couples <- function(men, women, choices, raw_males, raw_females) {
  couples <- cbind(men, women[choices, , drop = FALSE])
  couples$samecaste <- reported_same_caste( # nolint: object_usage_linter.
    raw_males, raw_females[choices, , drop = FALSE]
  )
  couples$diff_age <- couples$age_male - couples$age_female
  couples$diff_height <- couples$height_male - couples$height_female
  for (sex in c("male", "female")) {
    variable <- function(name) paste0(name, "_", sex)
    recodes <- list(
      c("main_caste_rank", "nocaste"), c("edu_max", "noedu"), c("age", "noage"),
      c("height", "noheight"), c("science", "nofield"), c("comm", "nofield"),
      c("otherfield", "nofield"), c("logincome", "noincome"), c("logwage", "nowage"),
      c("family_origin", "nofamily"), c("other_edu", "noedu")
    )
    if (sex == "female") {
      recodes <- c(recodes, list(
        c("vbeautiful", "nobeauty"), c("beautiful", "nobeauty"), c("skinrank", "noskin")
      ))
    }
    for (entry in recodes) {
      couples[[variable(entry[1])]][couples[[variable(entry[2])]] == 1] <- 0
    }
    for (rank in 2:8) {
      name <- paste0(if (sex == "male") "caste_no" else "caste_nof", rank + 1L)
      couples[[name]] <- as.numeric(couples[[variable("main_caste_rank")]] == rank)
    }
    residence <- couples[[variable("resstatus")]]
    residence[couples[[variable("nores")]] == 1] <- NA_real_
    couples[[variable("city")]] <- as.numeric(!is.na(residence) & residence == 3)
    couples[[variable("wbengal")]] <- as.numeric(!is.na(residence) & residence == 4)
    couples[[variable("otherres")]] <- as.numeric(!is.na(residence) & residence %in% c(5, 6))
  }
  known_caste <- couples$nocaste_male == 0 & couples$nocaste_female == 0
  couples$highercaste <- as.numeric(known_caste & couples$main_caste_rank_male < couples$main_caste_rank_female)
  couples$highercaste_female <- as.numeric(known_caste & couples$main_caste_rank_female < couples$main_caste_rank_male)
  couples$samecaste[!known_caste] <- 0
  couples
}

read_cost_specifications <- function(path) {
  commands <- readLines(path, warn = FALSE)
  commands <- trimws(commands)
  start <- which(grepl("^reg edu_max_male highercaste samecaste caste_nof3", commands))[1]
  end <- which(grepl("^collapse", commands) & seq_along(commands) > start)[1]
  specifications <- list()
  active <- NULL
  for (line in start:(end - 1L)) {
    command <- commands[line]
    if (startsWith(command, "reg ")) active <- list(command = command, source_line = line)
    if (grepl("^gen beta_.*=_b\\[", command)) {
      coefficient <- sub(".*_b\\[([^]]+)\\].*", "\\1", command)
      output_name <- sub("^gen ([^=]+)=.*", "\\1", command)
      if (grepl("_long", output_name)) {
        specifications[[output_name]] <- c(active, list(coefficient = coefficient, output_name = output_name))
      }
    }
  }
  specifications
}

expand_cost_terms <- function(terms) {
  tokens <- strsplit(terms, " +")[[1]]
  unlist(lapply(tokens, function(term) {
    if (!grepl("-", term, fixed = TRUE)) {
      return(term)
    }
    endpoints <- strsplit(term, "-", fixed = TRUE)[[1]]
    prefix <- sub("[0-9]+$", "", endpoints[1])
    paste0(prefix, seq(
      as.integer(sub(prefix, "", endpoints[1], fixed = TRUE)),
      as.integer(sub(prefix, "", endpoints[2], fixed = TRUE))
    ))
  }), use.names = FALSE)
}

estimate_cost <- function(couples, specification, population) {
  command <- sub(";$", "", sub("^reg ", "", specification$command))
  pieces <- strsplit(command, " if ", fixed = TRUE)[[1]]
  outcome <- strsplit(pieces[1], " ", fixed = TRUE)[[1]][1]
  terms <- expand_cost_terms(sub("^[^ ]+ ", "", pieces[1]))
  selected <- population & eval(parse(text = pieces[2]), envir = couples)
  data <- couples[which(selected), , drop = FALSE]
  data <- data[complete.cases(data[, c(outcome, terms)]), , drop = FALSE]
  design <- cbind(`(Intercept)` = 1, as.matrix(data[, terms, drop = FALSE]))
  fit <- lm.fit(design, data[[outcome]])
  coefficient <- specification$coefficient
  # Stata permits an unambiguous coefficient-name abbreviation in _b[].
  matched_term <- pmatch(coefficient, colnames(design))
  stopifnot(!is.na(matched_term))
  coefficient <- colnames(design)[matched_term]
  coefficient_estimable <- TRUE
  if (fit$rank < ncol(design)) {
    pivot <- fit$qr$pivot
    triangular <- qr.R(fit$qr)
    omitted <- (fit$rank + 1L):ncol(design)
    relation <- backsolve(
      triangular[seq_len(fit$rank), seq_len(fit$rank), drop = FALSE],
      triangular[seq_len(fit$rank), omitted, drop = FALSE]
    )
    null_basis <- rbind(-relation, diag(length(omitted)))
    coefficient_estimable <- max(abs(null_basis[match(matched_term, pivot), ])) < 1e-7
  }
  estimate <- if (coefficient_estimable) unname(fit$coefficients[coefficient]) else NA_real_
  rank_male <- data$main_caste_rank_male
  rank_female <- data$main_caste_rank_female
  partner_is_male <- "highercaste" %in% terms
  caste_model <- any(c("highercaste", "highercaste_female") %in% terms)
  higher <- if (partner_is_male) data$highercaste else data$highercaste_female
  reference <- higher == 0 & data$samecaste == 0
  lower <- if (partner_is_male) rank_male > rank_female else rank_female > rank_male
  equal_rank <- rank_male == rank_female
  data.frame(
    output_name = specification$output_name, outcome = outcome, coefficient = coefficient,
    published_table8_cell = outcome != "logincome_female",
    panel = if (grepl("_male", specification$output_name, fixed = TRUE)) "male_attributes" else "female_attributes",
    estimate = estimate, n = nrow(data), design_columns = ncol(design), design_rank = fit$rank,
    coefficient_estimable = coefficient_estimable,
    caste_model = caste_model,
    same_caste_n = if (caste_model) sum(data$samecaste == 1) else NA_integer_,
    higher_caste_n = if (caste_model) sum(higher == 1) else NA_integer_,
    reference_n = if (caste_model) sum(reference) else NA_integer_,
    reference_lower_rank_n = if (caste_model) sum(reference & lower) else NA_integer_,
    reference_equal_rank_n = if (caste_model) sum(reference & equal_rank) else NA_integer_,
    same_and_higher_n = if (caste_model) sum(data$samecaste == 1 & higher == 1) else NA_integer_,
    source_line = specification$source_line
  )
}

if (sys.nframe() == 0L) {
  base <- "data/original/AEJMicro-2011-0182-Data"
  male_path <- file.path(base, "matlab/all_males_matlab.csv")
  female_path <- file.path(base, "matlab/all_females_matlab.csv")
  men <- read_cost_people(male_path, "male")
  women <- read_cost_people(female_path, "female")
  raw_males <- as.matrix(read.csv(male_path, header = FALSE))
  raw_females <- as.matrix(read.csv(female_path, header = FALSE))
  specifications <- read_cost_specifications(file.path(base, "do/correlations_results.do"))
  write.csv(do.call(rbind, lapply(specifications, as.data.frame)),
    "output/simulation_cost_source_map.csv",
    row.names = FALSE
  )
  crosswalk <- read.csv("output/simulation_interview_crosswalk.csv")
  verified <- crosswalk[crosswalk$status == "verified_identifier_and_attributes", ]
  interview_men <- verified$simulation_row[verified$sex == "male"]
  interview_women <- verified$simulation_row[verified$sex == "female"]
  results <- list()
  allocation_files <- c(
    "simulation_choices.csv", "simulation_weighting_choices.csv", "simulation_handoff_choices.csv"
  )
  for (allocation_file in allocation_files) {
    allocations <- read.csv(file.path("output", allocation_file))
    for (scenario in unique(allocations$scenario)) {
      selected <- allocations[allocations$scenario == scenario, ]
      for (draw in unique(selected$draw)) {
        allocation <- selected[selected$draw == draw, ]
        allocation <- allocation[order(allocation$man), ]
        stopifnot(identical(allocation$man, seq_len(nrow(men))))
        couples <- build_cost_couples(men, women, allocation$woman, raw_males, raw_females)
        for (population in c("full_market", "verified_interview_subset")) {
          keep <- if (population == "full_market") {
            rep(TRUE, nrow(men))
          } else {
            seq_len(nrow(men)) %in% interview_men | allocation$woman %in% interview_women
          }
          for (name in names(specifications)) {
            key <- paste(scenario, draw, population, name)
            results[[key]] <- cbind(
              scenario = scenario, draw = draw, population = population,
              estimate_cost(couples, specifications[[name]], keep)
            )
          }
        }
      }
    }
  }
  write.csv(do.call(rbind, results), "output/simulation_cost_estimates.csv", row.names = FALSE)
}
