source("src/simulation_features.R")

# Complete preference lists, men propose, and index order resolves equal scores.
match_preferences <- function(male_preferences, female_ranks) {
  n_men <- ncol(male_preferences)
  n_women <- nrow(male_preferences)
  choice <- integer(n_men)
  husbands <- integer(n_women)
  next_rank <- integer(n_men)
  for (initial_man in seq_len(n_men)) {
    man <- initial_man
    while (man > 0L) {
      next_rank[man] <- next_rank[man] + 1L
      stopifnot(next_rank[man] <= n_women)
      woman <- male_preferences[next_rank[man], man]
      incumbent <- husbands[woman]
      if (incumbent == 0L || female_ranks[man, woman] < female_ranks[incumbent, woman]) {
        husbands[woman] <- man
        choice[man] <- woman
        if (incumbent > 0L) choice[incumbent] <- 0L
        man <- incumbent
      }
    }
  }
  list(choice = choice, proposals = sum(next_rank))
}

round_single <- function(values) {
  dimensions <- dim(values)
  values <- readBin(writeBin(as.numeric(values), raw(), size = 4L), "numeric", n = length(values), size = 4L)
  if (!is.null(dimensions)) dim(values) <- dimensions
  values
}

build_female_ranks <- function(males, females, beta_brides) {
  ranks <- matrix(0L, nrow(males), nrow(females))
  for (woman in seq_len(nrow(females))) {
    features <- round_single(bride_features(males, females[woman, ])) # nolint: object_usage_linter.
    utility <- round_single(10000 * features %*% beta_brides)
    ranks[order(-utility, method = "radix"), woman] <- seq_len(nrow(males))
    if (woman %% 2000L == 0L) message("Women ranked: ", woman)
  }
  ranks
}

build_male_preferences <- function(males, females, beta_grooms, correct_residence = FALSE) {
  preferences <- matrix(0L, nrow(females), nrow(males))
  for (man in seq_len(nrow(males))) {
    features <- round_single(groom_features(females, males[man, ], correct_residence)) # nolint: object_usage_linter.
    utility <- round_single(10000 * features %*% beta_grooms)
    preferences[, man] <- order(-utility, method = "radix")
    if (man %% 2000L == 0L) message("Men ranked: ", man)
  }
  preferences
}

matching_moments <- function(males, females, choice) {
  wives <- females[choice, , drop = FALSE]
  same_caste <- vapply(seq_len(nrow(males)), function(man) {
    bride_features(males[man, , drop = FALSE], wives[man, ])[, 8] # nolint: object_usage_linter.
  }, numeric(1))
  known_caste <- males[, 6] == 0 & wives[, 6] == 0
  known_residence <- males[, 9] == 0 & wives[, 9] == 0
  known_origin <- males[, 7] == 0 & wives[, 7] == 0
  known_height <- males[, 12] == 0 & wives[, 12] == 0
  data.frame(
    men = nrow(males), women = nrow(females),
    same_caste = mean(same_caste[known_caste]), caste_known_n = sum(known_caste),
    same_residence = mean(males[known_residence, 2] == wives[known_residence, 2]),
    residence_known_n = sum(known_residence),
    same_origin = mean(males[known_origin, 1] == wives[known_origin, 1]), origin_known_n = sum(known_origin),
    height_correlation = cor(males[known_height, 11], wives[known_height, 11]), height_known_n = sum(known_height)
  )
}

check_stability <- function(male_preferences, female_ranks, choice) {
  husbands <- integer(nrow(male_preferences))
  husbands[choice] <- seq_along(choice)
  blocking_pairs <- 0L
  for (man in seq_along(choice)) {
    preference_rank <- match(choice[man], male_preferences[, man])
    if (preference_rank == 1L) next
    preferred <- male_preferences[seq_len(preference_rank - 1L), man]
    incumbents <- husbands[preferred]
    blocking_pairs <- blocking_pairs + sum(incumbents == 0L)
    occupied <- incumbents > 0L
    blocking_pairs <- blocking_pairs + sum(
      female_ranks[cbind(man, preferred[occupied])] <
        female_ranks[cbind(incumbents[occupied], preferred[occupied])]
    )
  }
  blocking_pairs
}

quality_index <- function(people, sex, correct_education = FALSE) {
  if (sex == "male") {
    columns <- c(3, 10, 11, 12, 18, 22, 21, 23, 19, 24, 25, 26, 8, 9, 1, 7, 27, 28)
    coefficients <- c(
      -.0050615, -.2065259, .2468846, .4065271, -.1291376, .0434958,
      .0388365, -.0063154, -.1542864, -.0277311, .0552969, .5070267,
      .063535, .0088511, -.0266985, -.0409883, .0840214, .4163589
    )
    education_coefficients <- c(-.1749361, -.2561849, -.231943, -.1441574, -.1197571)
    intercept <- -.705936
  } else {
    columns <- c(3, 10, 11, 12, 18, 22, 21, 23, 19, 24, 8, 9, 1, 7, 15, 14, 16, 4, 13)
    coefficients <- c(
      -.0001938, -.0085176, .2695616, .5419885, .0222511, -.0042995,
      .0878916, .0884398, .0057125, -.1190479, .022267, -.0073315,
      .0261915, -.019183, -.0032535, .0633272, -.0118669, -.0432322, -.0967652
    )
    education_coefficients <- c(.0408597, -.2146535, -.0895027, -.0898811, .0738442)
    intercept <- -.0120357
  }
  quality <- as.numeric(people[, columns, drop = FALSE] %*% coefficients) + intercept
  for (level in seq_along(education_coefficients)) {
    contribution <- if (correct_education) {
      education_coefficients[level] * (people[, 17] == level + 1L)
    } else {
      as.numeric(education_coefficients[level] * people[, 17] == level + 1L)
    }
    quality <- quality + contribution
  }
  quality
}
reported_same_caste <- function(males, females) {
  caste_male <- males[, 31]
  caste_female <- females[, 31]
  main_caste_rank_male <- ifelse(males[, 6] == 1, NA_real_, males[, 5])
  main_caste_rank_female <- ifelse(females[, 6] == 1, NA_real_, females[, 5])
  same_caste <- as.numeric(caste_male == caste_female)
  same_caste[which(caste_male == 1 & main_caste_rank_female == 1)] <- 1
  same_caste[which(caste_female == 1 & main_caste_rank_male == 1)] <- 1
  same_caste[which(caste_male == 18 & main_caste_rank_female == 2)] <- 1
  same_caste[which(caste_female == 18 & main_caste_rank_male == 2)] <- 1
  same_caste[which(caste_male == 9 & main_caste_rank_female == 3)] <- 1
  same_caste[which(caste_female == 9 & main_caste_rank_male == 3)] <- 1
  same_caste[which(caste_male == 20 &
                     main_caste_rank_female == 4 &
                     caste_female != 24 &
                     caste_female != 83 &
                     caste_female != 87 &
                     caste_female != 101)] <- 1
  same_caste[which(caste_female == 20 &
                     main_caste_rank_male == 4 &
                     caste_male != 24 &
                     caste_male != 83 &
                     caste_male != 87 &
                     caste_male != 101)] <- 1
  same_caste[which(caste_male == 16 & (caste_female == 17 | caste_female == 100))] <- 1
  same_caste[which(caste_female == 16 & (caste_male == 17 & caste_male == 100))] <- 1
  same_caste[which(caste_male == 25 &
                     ((caste_female >= 26 &
                         caste_female <= 30) |
                        caste_female == 35 |
                        caste_female == 37 |
                        caste_female == 39 |
                        caste_female == 100 |
                        caste_female == 105))] <- 1
  same_caste[which(caste_female == 25 &
                     ((caste_male >= 26 &
                         caste_male <= 30) |
                        caste_male == 35 |
                        caste_male == 37 |
                        caste_male == 39 |
                        caste_male == 100 |
                        caste_male == 105))] <- 1
  same_caste[which(caste_male == 31 &
                     (caste_female == 32 |
                        caste_female == 33 |
                        caste_female == 40 |
                        caste_female == 41 |
                        caste_female == 85))] <- 1
  same_caste[which(caste_female == 31 &
                     (caste_male == 32 |
                        caste_male == 33 |
                        caste_male == 40 |
                        caste_male == 41 |
                        caste_male == 85))] <- 1
  same_caste[which(caste_male == 34 & caste_female == 35)] <- 1
  same_caste[which(caste_female == 34 & caste_male == 35)] <- 1
  same_caste[which(caste_male == 36 & caste_female == 37)] <- 1
  same_caste[which(caste_female == 36 & caste_male == 37)] <- 1
  same_caste[which(caste_male == 38 & caste_female == 39)] <- 1
  same_caste[which(caste_female == 38 & caste_male == 39)] <- 1
  same_caste[which(caste_male == 42 & caste_female == 43)] <- 1
  same_caste[which(caste_female == 42 & caste_male == 43)] <- 1
  same_caste[which(caste_male == 44 & (caste_female == 45 | caste_female == 46))] <- 1
  same_caste[which(caste_female == 44 & (caste_male == 45 | caste_male == 46))] <- 1
  same_caste[which(caste_male == 53 & caste_female == 54)] <- 1
  same_caste[which(caste_female == 53 & caste_male == 54)] <- 1
  same_caste[which(caste_male == 56 & caste_female == 57)] <- 1
  same_caste[which(caste_female == 56 & caste_male == 57)] <- 1
  same_caste[which(caste_male == 58 & caste_female >= 59 & caste_female <= 63)] <- 1
  same_caste[which(caste_female == 58 & caste_male >= 59 & caste_male <= 63)] <- 1
  same_caste[which(caste_male == 79 & main_caste_rank_female == 8)] <- 1
  same_caste[which(caste_female == 79 & main_caste_rank_male == 8)] <- 1
  same_caste
}
