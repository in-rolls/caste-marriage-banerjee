# Feature ordering is a direct translation of algorithm_new.m, lines 35–100 and 143–212.
bride_features <- function(candidates, chooser, correct_bride_handoff = FALSE) {
  features <- matrix(0, nrow(candidates), 57)
  features[, 1] <- candidates[, 5] == 2
  features[, 2] <- candidates[, 5] == 3
  features[, 3] <- candidates[, 5] == 4
  features[, 4] <- candidates[, 5] == 5
  features[, 5] <- candidates[, 5] == 6
  features[, 6] <- candidates[, 5] == 7
  features[, 7] <- candidates[, 5] == 8
  features[, 11] <- candidates[, 6]
  features[, 23] <- candidates[, 10]
  features[, 29] <- candidates[, 12]
  features[, 31] <- candidates[, 17] == 2
  features[, 32] <- candidates[, 17] == 3
  features[, 33] <- candidates[, 17] == 4
  features[, 34] <- candidates[, 17] == 5
  features[, 35] <- candidates[, 17] == 6
  features[, 38] <- candidates[, 18]
  features[, 39] <- candidates[, 22]
  features[, 40] <- candidates[, 21]
  features[, 41] <- candidates[, 23]
  features[, 42] <- candidates[, 19]
  features[, 44] <- candidates[, 24]
  features[, 45] <- candidates[, 25]
  features[, 46] <- candidates[, 26]
  features[, 47] <- candidates[, 2] == 2
  features[, 49] <- candidates[, 9]
  features[, 51] <- candidates[, 1]
  features[, 53] <- candidates[, 7]
  features[, 55] <- candidates[, 27]
  features[, 56] <- candidates[, 28]
  features[, 57] <- rep(1, nrow(candidates))
  candidate_attributes <- cbind(
    candidates[, 5],
    candidates[, 17],
    candidates[, 2],
    candidates[, 31],
    candidates[, 3],
    candidates[, 11]
  )
  chooser_features <- cbind(
    rep(
      chooser[5],
      nrow(candidates)
    ),
    rep(
      chooser[6],
      nrow(candidates)
    ),
    rep(
      chooser[3],
      nrow(candidates)
    ),
    rep(
      chooser[10],
      nrow(candidates)
    ),
    rep(
      chooser[11],
      nrow(candidates)
    ),
    rep(
      chooser[12],
      nrow(candidates)
    ),
    rep(
      chooser[17],
      nrow(candidates)
    ),
    rep(
      chooser[18],
      nrow(candidates)
    ),
    rep(
      chooser[19],
      nrow(candidates)
    ),
    rep(
      chooser[4],
      nrow(candidates)
    ),
    rep(
      chooser[13],
      nrow(candidates)
    ),
    rep(
      chooser[2],
      nrow(candidates)
    ),
    rep(
      chooser[9],
      nrow(candidates)
    ),
    rep(
      chooser[1],
      nrow(candidates)
    ),
    rep(
      chooser[7],
      nrow(candidates)
    ),
    rep(
      chooser[15],
      nrow(candidates)
    ),
    rep(
      chooser[14],
      nrow(candidates)
    ),
    rep(
      chooser[16],
      nrow(candidates)
    ),
    rep(
      chooser[29],
      nrow(candidates)
    ),
    rep(
      chooser[30],
      nrow(candidates)
    ),
    rep(
      chooser[31],
      nrow(candidates)
    )
  )
  features[, 8] <- candidate_attributes[, 4] == chooser_features[, 21] |
    (candidate_attributes[, 4] == 1 & chooser_features[, 1] == 1) |
    (candidate_attributes[, 4] == 18 & chooser_features[, 1] == 2) |
    (candidate_attributes[, 4] == 9 & chooser_features[, 1] == 3) |
    (candidate_attributes[, 4] == 20 &
       chooser_features[, 1] == 4 &
       chooser_features[, 21] != 24 &
       chooser_features[, 21] != 83 &
       chooser_features[, 21] != 87 &
       chooser_features[, 21] != 105) |
    (candidate_attributes[, 4] == 16 & (chooser_features[, 21] == 17 |
                                          chooser_features[, 21] == 100)) |
    (candidate_attributes[, 4] == 25 & ((chooser_features[, 21] >= 26 & chooser_features[, 21] <= 30) |
                                          chooser_features[, 21] == 35 |
                                          chooser_features[, 21] == 37 |
                                          chooser_features[, 21] == 39 |
                                          chooser_features[, 21] == 100 |
                                          chooser_features[, 21] == 105 |
                                          chooser_features[, 21] == 107)) |
    (candidate_attributes[, 4] == 31 & (chooser_features[, 21] == 32 |
                                          chooser_features[, 21] == 33 |
                                          chooser_features[, 21] == 40 |
                                          chooser_features[, 21] == 41 |
                                          chooser_features[, 21] == 85)) |
    (candidate_attributes[, 4] == 34 & chooser_features[, 21] == 35) |
    (candidate_attributes[, 4] == 36 & chooser_features[, 21] == 37) |
    (candidate_attributes[, 4] == 38 & chooser_features[, 21] == 39) |
    (candidate_attributes[, 4] == 42 & chooser_features[, 21] == 43) |
    (candidate_attributes[, 4] == 44 & (chooser_features[, 21] == 45 |
                                          chooser_features[, 21] == 46)) |
    (candidate_attributes[, 4] == 53 & chooser_features[, 21] == 54) |
    (candidate_attributes[, 4] == 56 & chooser_features[, 21] == 57) |
    (candidate_attributes[, 4] == 58 & (chooser_features[, 21] >= 59 & chooser_features[, 21] <= 63)) |
    (candidate_attributes[, 4] == 79 & chooser_features[, 1] == 8) |
    (chooser_features[, 21] == 1 & candidate_attributes[, 1] == 1) |
    (candidate_attributes[, 1] == 2 & chooser_features[, 21] == 18) |
    (candidate_attributes[, 1] == 3 & chooser_features[, 21] == 9) |
    (candidate_attributes[, 1] == 4 &
       chooser_features[, 21] == 20 &
       candidate_attributes[, 4] != 24 &
       candidate_attributes[, 4] != 83 &
       candidate_attributes[, 4] != 87 &
       candidate_attributes[, 4] != 105) |
    ((candidate_attributes[, 4] == 17 |
        candidate_attributes[, 4] == 100) & chooser_features[, 21] == 16) |
    (chooser_features[, 21] == 25 & ((candidate_attributes[, 4] >= 26 & candidate_attributes[, 4] <= 30) |
                                       candidate_attributes[, 4] == 35 |
                                       candidate_attributes[, 4] == 37 |
                                       candidate_attributes[, 4] == 39 |
                                       candidate_attributes[, 4] == 100 |
                                       candidate_attributes[, 4] == 105 |
                                       candidate_attributes[, 4] == 107)) |
    (chooser_features[, 21] == 31 & (candidate_attributes[, 4] == 32 |
                                       candidate_attributes[, 4] == 33 |
                                       candidate_attributes[, 4] == 40 |
                                       candidate_attributes[, 4] == 41 |
                                       candidate_attributes[, 4] == 85)) |
    (candidate_attributes[, 4] == 35 & chooser_features[, 21] == 34) |
    (candidate_attributes[, 4] == 37 & chooser_features[, 21] == 36) |
    (candidate_attributes[, 4] == 39 & chooser_features[, 21] == 38) |
    (candidate_attributes[, 4] == 43 & chooser_features[, 21] == 42) |
    (chooser_features[, 21] == 44 & (candidate_attributes[, 4] == 45 |
                                       candidate_attributes[, 4] == 46)) |
    (candidate_attributes[, 4] == 54 & chooser_features[, 21] == 53) |
    (candidate_attributes[, 4] == 57 & chooser_features[, 21] == 56) |
    (chooser_features[, 21] == 58 & (candidate_attributes[, 4] >= 59 & candidate_attributes[, 4] <= 63)) |
    (candidate_attributes[, 1] == 8 & chooser_features[, 21] == 79)
  features[, 9] <- (candidate_attributes[, 1] - chooser_features[, 1]) *
    (candidate_attributes[, 1] < chooser_features[, 1]) *
    (candidate_attributes[, 1] != 0)
  features[, 10] <- (candidate_attributes[, 1] - chooser_features[, 1]) *
    (candidate_attributes[, 1] > chooser_features[, 1]) *
    (chooser_features[, 1] != 0)
  features[, 12] <- chooser_features[, 2] * features[, 11]
  features[, 13] <- chooser_features[, 19] * features[, 8]
  features[, 14] <- chooser_features[, 19] * (features[, 9] + features[, 10])
  features[, 15] <- chooser_features[, 19] * features[, 11]
  features[, 16] <- chooser_features[, 20] * features[, 8]
  features[, 17] <- chooser_features[, 20] * (features[, 9] + features[, 10])
  features[, 18] <- chooser_features[, 20] * features[, 11]
  features[, 19] <- chooser_features[, 4] * candidate_attributes[, 5]
  features[, 20] <- features[, 23] * chooser_features[, 3]
  features[, 21] <- (chooser_features[, 4] != 1 &
                       features[, 23] != 1) * ((candidate_attributes[, 5] - chooser_features[, 3]))
  features[, 22] <- features[, 21]^2
  features[, 24] <- chooser_features[, 4] * features[, 23]
  features[, 25] <- chooser_features[, 6] * candidate_attributes[, 6]
  features[, 26] <- features[, 29] * chooser_features[, 5]
  features[, 27] <- (chooser_features[, 6] != 1 &
                       features[, 29] != 1) * ((candidate_attributes[, 6] - chooser_features[, 5]))
  features[, 28] <- features[, 27]^2
  features[, 30] <- chooser_features[, 6] * features[, 29]
  features[, 36] <- (chooser_features[, 9] != 1 &
                       features[, 42] != 1) * (candidate_attributes[, 2] == chooser_features[, 7])
  features[, 37] <- (chooser_features[, 9] != 1 &
                       features[, 42] != 1) * (candidate_attributes[, 2] > chooser_features[, 7])
  features[, 43] <- chooser_features[, 9] * features[, 42]
  features[, 48] <- (features[, 49] != 1 &
                       chooser_features[, 13] != 1) * (chooser_features[, 12] == candidate_attributes[, 3])
  features[, 50] <- chooser_features[, 13] * features[, 49]
  features[, 52] <- (features[, 53] != 1 & chooser_features[, 15] != 1) * (features[, 51] == chooser_features[, 14])
  features[, 54] <- chooser_features[, 15] * features[, 53]
  if (correct_bride_handoff) {
    features[, c(9, 10, 14, 17)] <- -features[, c(9, 10, 14, 17)]
    features[, c(19, 20)] <- features[, c(20, 19)]
    features[, c(25, 26)] <- features[, c(26, 25)]
  }
  features
}

groom_features <- function(candidates, chooser, correct_residence = FALSE) {
  features <- matrix(0, nrow(candidates), 58)
  features[, 1] <- candidates[, 5] == 2
  features[, 2] <- candidates[, 5] == 3
  features[, 3] <- candidates[, 5] == 4
  features[, 4] <- candidates[, 5] == 5
  features[, 5] <- candidates[, 5] == 6
  features[, 6] <- candidates[, 5] == 7
  features[, 7] <- candidates[, 5] == 8
  features[, 11] <- candidates[, 6]
  features[, 23] <- candidates[, 10]
  features[, 29] <- candidates[, 12]
  features[, 31] <- candidates[, 17] == 2
  features[, 32] <- candidates[, 17] == 3
  features[, 33] <- candidates[, 17] == 4
  features[, 34] <- candidates[, 17] == 5
  features[, 35] <- candidates[, 17] == 6
  features[, 38] <- candidates[, 18]
  features[, 39] <- candidates[, 22]
  features[, 40] <- candidates[, 21]
  features[, 41] <- candidates[, 23]
  features[, 43] <- candidates[, 19]
  features[, 44] <- candidates[, 24]
  features[, 45] <- candidates[, 4]
  features[, 46] <- candidates[, 13]
  features[, 47] <- candidates[, 2] == 2
  features[, 49] <- candidates[, 9]
  features[, 51] <- candidates[, 1]
  features[, 53] <- candidates[, 7]
  features[, 55] <- candidates[, 15]
  features[, 56] <- candidates[, 14]
  features[, 57] <- candidates[, 16]
  features[, 58] <- rep(1, nrow(candidates))
  candidate_attributes <- cbind(
    candidates[, 5],
    candidates[, 17],
    candidates[, 2],
    candidates[, 31],
    candidates[, 3],
    candidates[, 11]
  )
  chooser_features <- cbind(
    rep(
      chooser[5],
      nrow(candidates)
    ),
    rep(
      chooser[6],
      nrow(candidates)
    ),
    rep(
      chooser[29],
      nrow(candidates)
    ),
    rep(
      chooser[30],
      nrow(candidates)
    ),
    rep(
      chooser[3],
      nrow(candidates)
    ),
    rep(
      chooser[10],
      nrow(candidates)
    ),
    rep(
      chooser[11],
      nrow(candidates)
    ),
    rep(
      chooser[12],
      nrow(candidates)
    ),
    rep(
      chooser[17],
      nrow(candidates)
    ),
    rep(
      chooser[19],
      nrow(candidates)
    ),
    rep(
      chooser[2],
      nrow(candidates)
    ),
    rep(
      chooser[9],
      nrow(candidates)
    ),
    rep(
      chooser[1],
      nrow(candidates)
    ),
    rep(
      chooser[7],
      nrow(candidates)
    ),
    rep(
      chooser[31],
      nrow(candidates)
    )
  )
  features[, 8] <- candidate_attributes[, 4] == chooser_features[, 15] |
    (candidate_attributes[, 4] == 1 & chooser_features[, 1] == 1) |
    (candidate_attributes[, 4] == 18 & chooser_features[, 1] == 2) |
    (candidate_attributes[, 4] == 9 & chooser_features[, 1] == 3) |
    (candidate_attributes[, 4] == 20 &
       chooser_features[, 1] == 4 &
       chooser_features[, 15] != 24 &
       chooser_features[, 15] != 83 &
       chooser_features[, 15] != 87 &
       chooser_features[, 15] != 105) |
    (candidate_attributes[, 4] == 16 & (chooser_features[, 15] == 17 |
                                          chooser_features[, 15] == 100)) |
    (candidate_attributes[, 4] == 25 & ((chooser_features[, 15] >= 26 & chooser_features[, 15] <= 30) |
                                          chooser_features[, 15] == 35 |
                                          chooser_features[, 15] == 37 |
                                          chooser_features[, 15] == 39 |
                                          chooser_features[, 15] == 100 |
                                          chooser_features[, 15] == 105 |
                                          chooser_features[, 15] == 107)) |
    (candidate_attributes[, 4] == 31 & (chooser_features[, 15] == 32 |
                                          chooser_features[, 15] == 33 |
                                          chooser_features[, 15] == 40 |
                                          chooser_features[, 15] == 41 |
                                          chooser_features[, 15] == 85)) |
    (candidate_attributes[, 4] == 34 & chooser_features[, 15] == 35) |
    (candidate_attributes[, 4] == 36 & chooser_features[, 15] == 37) |
    (candidate_attributes[, 4] == 38 & chooser_features[, 15] == 39) |
    (candidate_attributes[, 4] == 42 & chooser_features[, 15] == 43) |
    (candidate_attributes[, 4] == 44 & (chooser_features[, 15] == 45 |
                                          chooser_features[, 15] == 46)) |
    (candidate_attributes[, 4] == 53 & chooser_features[, 15] == 54) |
    (candidate_attributes[, 4] == 56 & chooser_features[, 15] == 57) |
    (candidate_attributes[, 4] == 58 & (chooser_features[, 15] >= 59 & chooser_features[, 15] <= 63)) |
    (candidate_attributes[, 4] == 79 & chooser_features[, 1] == 8) |
    (chooser_features[, 15] == 1 & candidate_attributes[, 1] == 1) |
    (candidate_attributes[, 1] == 2 & chooser_features[, 15] == 18) |
    (candidate_attributes[, 1] == 3 & chooser_features[, 15] == 9) |
    (candidate_attributes[, 1] == 4 &
       chooser_features[, 15] == 20 &
       candidate_attributes[, 4] != 24 &
       candidate_attributes[, 4] != 83 &
       candidate_attributes[, 4] != 87 &
       candidate_attributes[, 4] != 105) |
    ((candidate_attributes[, 4] == 17 |
        candidate_attributes[, 4] == 100) & chooser_features[, 15] == 16) |
    (chooser_features[, 15] == 25 & ((candidate_attributes[, 4] >= 26 & candidate_attributes[, 4] <= 30) |
                                       candidate_attributes[, 4] == 35 |
                                       candidate_attributes[, 4] == 37 |
                                       candidate_attributes[, 4] == 39 |
                                       candidate_attributes[, 4] == 100 |
                                       candidate_attributes[, 4] == 105 |
                                       candidate_attributes[, 4] == 107)) |
    (chooser_features[, 15] == 31 & (candidate_attributes[, 4] == 32 |
                                       candidate_attributes[, 4] == 33 |
                                       candidate_attributes[, 4] == 40 |
                                       candidate_attributes[, 4] == 41 |
                                       candidate_attributes[, 4] == 85)) |
    (candidate_attributes[, 4] == 35 & chooser_features[, 15] == 34) |
    (candidate_attributes[, 4] == 37 & chooser_features[, 15] == 36) |
    (candidate_attributes[, 4] == 39 & chooser_features[, 15] == 38) |
    (candidate_attributes[, 4] == 43 & chooser_features[, 15] == 42) |
    (chooser_features[, 15] == 44 & (candidate_attributes[, 4] == 45 |
                                       candidate_attributes[, 4] == 46)) |
    (candidate_attributes[, 4] == 54 & chooser_features[, 15] == 53) |
    (candidate_attributes[, 4] == 57 & chooser_features[, 15] == 56) |
    (chooser_features[, 15] == 58 & (candidate_attributes[, 4] >= 59 & candidate_attributes[, 4] <= 63)) |
    (candidate_attributes[, 1] == 8 & chooser_features[, 15] == 79)
  features[, 9] <- (candidate_attributes[, 1] - chooser_features[, 1]) *
    (candidate_attributes[, 1] > chooser_features[, 1]) *
    (chooser_features[, 1] != 0)
  features[, 10] <- (candidate_attributes[, 1] - chooser_features[, 1]) *
    (candidate_attributes[, 1] < chooser_features[, 1]) *
    (candidate_attributes[, 1] != 0)
  features[, 12] <- chooser_features[, 2] * features[, 11]
  features[, 13] <- chooser_features[, 3] * features[, 8]
  features[, 14] <- chooser_features[, 3] * (features[, 9] + features[, 10])
  features[, 15] <- chooser_features[, 3] * features[, 11]
  features[, 16] <- chooser_features[, 4] * features[, 8]
  features[, 17] <- chooser_features[, 4] * (features[, 9] + features[, 10])
  features[, 18] <- chooser_features[, 4] * features[, 11]
  features[, 19] <- chooser_features[, 6] * candidate_attributes[, 5]
  features[, 20] <- features[, 23] * chooser_features[, 5]
  features[, 21] <- (chooser_features[, 6] != 1 &
                       features[, 23] != 1) * ((chooser_features[, 5] - candidate_attributes[, 5]))
  features[, 22] <- features[, 21]^2
  features[, 24] <- chooser_features[, 6] * features[, 23]
  features[, 25] <- chooser_features[, 8] * candidate_attributes[, 6]
  features[, 26] <- features[, 29] * chooser_features[, 7]
  features[, 27] <- (chooser_features[, 8] != 1 &
                       features[, 29] != 1) * ((chooser_features[, 7] - candidate_attributes[, 6]))
  features[, 28] <- features[, 27]^2
  features[, 30] <- chooser_features[, 8] * features[, 29]
  features[, 36] <- (chooser_features[, 10] != 1 &
                       features[, 43] != 1) * (candidate_attributes[, 2] == chooser_features[, 9])
  features[, 37] <- (chooser_features[, 10] != 1 &
                       features[, 43] != 1) * (candidate_attributes[, 2] < chooser_features[, 9])
  features[, 42] <- chooser_features[, 10] * features[, 43]
  features[, 48] <- (features[, 49] != 1 &
                       chooser_features[, 13] != 1) * (chooser_features[, 12] == candidate_attributes[, 3])
  features[, 50] <- chooser_features[, 12] * features[, 49]
  features[, 52] <- (features[, 53] != 1 & chooser_features[, 14] != 1) * (features[, 51] == chooser_features[, 13])
  features[, 54] <- chooser_features[, 14] * features[, 53]
  if (correct_residence) {
    features[, 48] <- (candidates[, 9] != 1 & chooser[9] != 1) * (chooser[2] == candidates[, 2])
  }
  features
}
