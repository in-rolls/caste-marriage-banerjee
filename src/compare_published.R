r <- read.csv("output/regressions.csv")
terms <- c(
  "samecaste", "diff_above", "diff_below", "casteimportantmatch", "casteimportantdiff",
  "castenotimpmatch", "castenotimpdiff"
)
values <- list(
  T3_1 = c(.1317, -.0119, .0145, .0954, -.0163, -.0560, -.0084),
  T3_3 = c(.1347, -.0276, .0056, .0918, -.0158, -.0549, -.0098),
  T4_1 = c(.1707, -.0175, -.0399, .1234, .0024, -.0565, .0121),
  T4_3 = c(.1769, -.0099, -.0301, .1217, .0010, -.0574, .0118)
)
errors <- list(
  T3_1 = c(.0329, .0151, .0133, .1093, .0400, .0366, .0121),
  T3_3 = c(.0425, .0197, .0160, .1093, .0400, .0367, .0121),
  T4_1 = c(.0351, .0170, .0172, .1409, .0596, .0428, .0151),
  T4_3 = c(.0442, .0232, .0220, .1410, .0596, .0429, .0152)
)
out <- do.call(rbind, lapply(names(values), function(id) {
  z <- r[r$model == id, ]
  z <- z[match(terms, z$term), ]
  data.frame(
    model = id, term = terms, published = values[[id]], reproduced = z$estimate,
    published_se = errors[[id]], reproduced_se = z$se,
    coefficient_matches_rounding = abs(values[[id]] - z$estimate) < .000051,
    se_matches_rounding = abs(errors[[id]] - z$se) < .000051
  )
}))
write.csv(out, "output/published_comparison.csv", row.names = FALSE)
print(out[!out$coefficient_matches_rounding | !out$se_matches_rounding, ])
