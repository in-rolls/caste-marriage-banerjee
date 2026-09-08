mar_tools <- new.env()
sys.source("src/simulation_income_sacrifice.R", envir = mar_tools)

income_imputation_data <- function(men) {
  data.frame(
    income = ifelse(men[, 26] == 0, exp(men[, 25]), NA_real_),
    education = factor(ifelse(men[, 19] == 1, 0, men[, 17])),
    age = ifelse(men[, 10] == 1, 0, men[, 3]), no_age = men[, 10],
    age_squared = ifelse(men[, 10] == 1, 0, men[, 3]^2),
    log_wage = ifelse(men[, 28] == 1, 0, men[, 27]), no_wage = men[, 28],
    caste = factor(ifelse(men[, 6] == 1, 0, men[, 5])),
    residence = factor(ifelse(men[, 9] == 1, 0, men[, 2])),
    origin = factor(ifelse(men[, 7] == 1, -1, men[, 1]))
  )
}

impute_market_income <- function(data, draws, seed, log_scale = TRUE) {
  observed <- !is.na(data$income)
  stopifnot(all(data$income[observed] > 0), draws >= 2L)
  design <- model.matrix(~ . - income, data = transform(data, income = 0))
  stopifnot(qr(design[observed, ])$rank == ncol(design))
  if (log_scale) data$income <- log(data$income)
  methods <- setNames(rep("", ncol(data)), names(data))
  methods["income"] <- "pmm"
  predictors <- matrix(0L, ncol(data), ncol(data), dimnames = list(names(data), names(data)))
  predictors["income", names(data) != "income"] <- 1L
  imputations <- mice::mice(data,
    m = draws, maxit = 1L, method = methods,
    predictorMatrix = predictors, printFlag = FALSE, seed = seed, donors = 5L,
    remove.constant = FALSE, remove.collinear = FALSE
  )
  if (!is.null(imputations$loggedEvents)) stop("Inspect imputation diagnostics before accepting results")
  result <- matrix(rep(data$income, draws), ncol = draws)
  result[!observed, ] <- as.matrix(imputations$imp$income)
  if (log_scale) result <- exp(result)
  stopifnot(all(is.finite(result)), all(result > 0))
  result
}

income_pair_indices <- function(men, women, choices, interview_women) {
  scenarios <- list(
    supplied_original = c("original", "no_caste_original"),
    supplied_residence_repaired = c("residence_corrected", "no_caste_residence_corrected"),
    unweighted_residence_repaired = c("unweighted", "no_caste_unweighted"),
    weighted_residence_repaired = c("weighted", "no_caste_weighted"),
    weighted_all_repairs = c("weighted_handoff", "no_caste_weighted_handoff")
  )
  pairs <- list()
  for (comparison in names(scenarios)) {
    before <- choices[choices$scenario == scenarios[[comparison]][1], ]
    after <- choices[choices$scenario == scenarios[[comparison]][2], ]
    draw <- min(intersect(before$draw, after$draw))
    before <- before[before$draw == draw, ]
    after <- after[after$draw == draw, ]
    before_husband <- after_husband <- integer(nrow(women))
    before_husband[before$woman] <- before$man
    after_husband[after$woman] <- after$man
    common <- which(before_husband > 0 & after_husband > 0)
    before_caste <- mar_tools$income_tools$caste_outcomes(
      men[before_husband[common], ], women[common, ]
    )$reported_caste
    populations <- list(
      all_common_women = rep(TRUE, length(common)),
      same_caste_before = !is.na(before_caste) & before_caste == 1,
      outside_caste_before = !is.na(before_caste) & before_caste == 0,
      verified_interview_women = interview_women[common]
    )
    for (population in names(populations)) {
      keep <- populations[[population]]
      pairs[[paste(comparison, population)]] <- data.frame(
        comparison = comparison, population = population, woman = common[keep],
        before_man = before_husband[common[keep]], after_man = after_husband[common[keep]]
      )
    }
  }
  pairs
}

run_mar_income <- function(draws = 500L, seed = 114410L) {
  base <- "data/original/AEJMicro-2011-0182-Data/matlab"
  men <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
  women <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
  data <- income_imputation_data(men)
  choices <- rbind(
    read.csv("output/simulation_choices.csv"),
    read.csv("output/simulation_weighting_choices.csv"), read.csv("output/simulation_handoff_choices.csv")
  )
  crosswalk <- read.csv("output/simulation_interview_crosswalk.csv")
  verified <- crosswalk[crosswalk$sex == "female" & crosswalk$status == "verified_identifier_and_attributes", ]
  pairs <- income_pair_indices(men, women, choices, seq_len(nrow(women)) %in% verified$simulation_row)
  summaries <- estimates <- list()
  for (specification in c("pmm_log_income", "pmm_income_levels")) {
    message("Imputing ", specification, " with ", draws, " draws")
    imputed_income <- impute_market_income(data, draws, seed, specification == "pmm_log_income")
    stopifnot(max(abs(imputed_income[!is.na(data$income), ] - data$income[!is.na(data$income)])) < 1e-6)
    for (key in names(pairs)) {
      pair <- pairs[[key]]
      before <- imputed_income[pair$before_man, , drop = FALSE]
      after <- imputed_income[pair$after_man, , drop = FALSE]
      changes <- after - before
      estimate <- data.frame(
        specification = specification, comparison = pair$comparison[1], population = pair$population[1],
        imputation = seq_len(draws), n = nrow(pair), income_with_caste = colMeans(before),
        income_without_caste = colMeans(after), net_income_gain = colMeans(changes),
        gross_gain_per_woman = colMeans(pmax(changes, 0)), gross_loss_per_woman = colMeans(pmax(-changes, 0)),
        gain_share = colMeans(changes > 0), loss_share = colMeans(changes < 0)
      )
      estimate$foregone_income_share <- estimate$net_income_gain / estimate$income_without_caste
      estimates[[paste(specification, key)]] <- estimate
      interval <- quantile(estimate$net_income_gain, c(.025, .975), type = 2, names = FALSE)
      summaries[[paste(specification, key)]] <- data.frame(
        specification = specification, comparison = pair$comparison[1], population = pair$population[1],
        n = nrow(pair), imputations = draws, seed = seed,
        income_with_caste = mean(estimate$income_with_caste),
        income_without_caste = mean(estimate$income_without_caste),
        net_income_gain = mean(estimate$net_income_gain), p025 = interval[1], p975 = interval[2],
        foregone_income_share = mean(estimate$foregone_income_share),
        gross_gain_per_woman = mean(estimate$gross_gain_per_woman),
        gross_loss_per_woman = mean(estimate$gross_loss_per_woman),
        gain_share = mean(estimate$gain_share), loss_share = mean(estimate$loss_share),
        monte_carlo_se = sd(estimate$net_income_gain) / sqrt(draws),
        uncertainty = "Imputation uncertainty conditional on fixed market, preference coefficients, and allocations"
      )
    }
  }
  summaries <- do.call(rbind, summaries)
  estimates <- do.call(rbind, estimates)
  write.csv(summaries, "output/simulation_income_mar_summary.csv", row.names = FALSE)
  write.csv(estimates, "output/simulation_income_mar_draws.csv", row.names = FALSE)
  write.csv(data.frame(
    men = nrow(data), observed_incomes = sum(!is.na(data$income)), imputed_incomes = sum(is.na(data$income)),
    imputations_per_specification = draws, seed = seed, mice_version = as.character(packageVersion("mice")),
    source_sha256 = digest::digest(file = "src/simulation_income_mar.R", algo = "sha256"),
    men_sha256 = digest::digest(file = file.path(base, "all_males_matlab.csv"), algo = "sha256"),
    allocations_sha256 = digest::digest(choices, algo = "sha256"),
    assumption = paste(
      "Income missing at random given education, age, occupation, caste, residence,",
      "origin and missing-profile categories"
    )
  ), "output/simulation_income_mar_provenance.csv", row.names = FALSE)
  print(summaries[summaries$comparison == "weighted_all_repairs", c(
    "specification", "population", "n", "net_income_gain", "p025", "p975", "foregone_income_share"
  )], row.names = FALSE)
  invisible(summaries)
}

if (sys.nframe() == 0L) run_mar_income()
