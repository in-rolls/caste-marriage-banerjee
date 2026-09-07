x <- readRDS("output/limited_models.rds")[["T3_1"]]
b <- coef(x$fit)
draws <- read.csv("output/income_coefficient_draws.csv", check.names = FALSE)
names_caste <- c(
  "Brahmin", "Baidya", "Kshatriya", "Kayastha", "Baisya and others", "Sagdope and others",
  "Other castes", "Scheduled castes"
)
contrast_vector <- function(own, lower, category, names) {
  z <- setNames(rep(0, length(names)), names)
  z["samecaste"] <- 1
  if (own > 1) z[paste0("caste_no", own + 1)] <- 1
  z[paste0("caste_no", lower + 1)] <- -1
  z["diff_below"] <- lower - own
  if (category == "only_within") {
    z["casteimportantmatch"] <- 1
    z["casteimportantdiff"] <- lower - own
  }
  if (category == "no_bar") {
    z["castenotimpmatch"] <- 1
    z["castenotimpdiff"] <- lower - own
  }
  z
}
out <- list()
for (own in 1:7) {
  for (lower in seq.int(own + 1, 8)) {
    for (category in c("reference", "only_within", "no_bar")) {
      z <- contrast_vector(own, lower, category, names(b))
      gap <- sum(z * b)
      ratio <- gap / b["predicted_income"]
      keep <- names(z)[z != 0]
      boot_gap <- as.matrix(draws[, keep, drop = FALSE]) %*% z[keep]
      boot_ratio <- boot_gap / draws$predicted_income
      boot_premium <- exp(boot_ratio) - 1
      out[[paste(own, lower, category)]] <- data.frame(
        advertiser_caste = names_caste[own],
        alternative_groom_caste = names_caste[lower], stated_preference = category,
        shortlist_gap = gap, outside_income_premium = exp(ratio) - 1, inside_income_discount = 1 - exp(-ratio),
        premium_lower = quantile(boot_premium, .025, na.rm = TRUE),
        premium_upper = quantile(boot_premium, .975, na.rm = TRUE),
        valid_draws = sum(is.finite(boot_premium))
      )
    }
  }
}
write.csv(do.call(rbind, out), "output/lower_caste_income_contrasts.csv", row.names = FALSE)
print(do.call(rbind, out)[c(1, 7), ])
