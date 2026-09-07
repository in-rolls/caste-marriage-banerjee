library(fixest)
setFixest_nthreads(1)
x <- readRDS("output/limited_models.rds")[["T3_1"]]
d <- x$data
set.seed(114407)
n_boot <- 1999L
ids <- unique(d$SI)
rows <- split(seq_len(nrow(d)), d$SI)
coefficient_draws <- matrix(NA_real_, n_boot, length(coef(x$fit)), dimnames = list(NULL, names(coef(x$fit))))
results <- matrix(NA_real_, n_boot, 5L,
  dimnames = list(NULL, c("samecaste", "predicted_income", "log_tradeoff", "outside_premium", "inside_discount"))
)
for (i in seq_len(n_boot)) {
  selected <- sample(ids, length(ids), replace = TRUE)
  sampled_rows <- rows[as.character(selected)]
  dd <- d[unlist(sampled_rows, use.names = FALSE), ]
  dd$SI <- rep(seq_along(selected), lengths(sampled_rows))
  first <- lm(formula(x$first), dd, weights = weight, subset = noincome_male == 0)
  dd$predicted_income <- suppressWarnings(predict(first, dd))
  f <- feols(formula(x$fit), dd, weights = ~weight, fixef.rm = "none", notes = FALSE)
  b <- coef(f)
  coefficient_draws[i, names(b)] <- b
  ratio <- b["samecaste"] / b["predicted_income"]
  results[i, ] <- c(b["samecaste"], b["predicted_income"], ratio, exp(ratio) - 1, 1 - exp(-ratio))
}
write.csv(coefficient_draws, "output/income_coefficient_draws.csv", row.names = FALSE)
write.csv(results, "output/income_bootstrap_draws.csv", row.names = FALSE)
b <- coef(x$fit)
ratio <- b["samecaste"] / b["predicted_income"]
point <- c(b["samecaste"], b["predicted_income"], ratio, exp(ratio) - 1, 1 - exp(-ratio))
out <- data.frame(
  statistic = colnames(results), estimate = point,
  lower = apply(results, 2, quantile, .025), upper = apply(results, 2, quantile, .975),
  draws = n_boot, seed = 114407, positive_income_share = mean(results[, "predicted_income"] > 0)
)
write.csv(out, "output/income_bootstrap_summary.csv", row.names = FALSE)
print(out)
