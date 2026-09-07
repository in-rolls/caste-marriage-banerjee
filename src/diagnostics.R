library(fixest)
setFixest_nthreads(1)
x <- readRDS("output/prepared.rds")
d <- x$pairs
models <- readRDS("output/models.rds")
base <- "data/original/AEJMicro-2011-0182-Data"
# Compare the coefficients supplied to Matlab with weighted and unweighted fits.
handoff <- list()
for (id in c("T3_1", "T4_1")) {
  m <- models[[id]]
  dd <- m$data
  f <- feols(formula(m$fit), dd, fixef.rm = "none", notes = FALSE)
  b <- as.matrix(read.csv(file.path(
    base, "matlab",
    if (id == "T3_1") "beta_brides_sigma.csv" else "beta_grooms_sigma.csv"
  ), header = FALSE))
  handoff[[id]] <- data.frame(
    model = id, term = "samecaste", weighted = coef(m$fit)["samecaste"],
    unweighted = coef(f)["samecaste"], supplied_bootstrap_mean = mean(b[, 8]),
    supplied_bootstrap_sd = sd(b[, 8]), supplied_draws = nrow(b), used_draws = 250
  )
}
write.csv(do.call(rbind, handoff), "output/bootstrap_handoff.csv", row.names = FALSE)
# Sampling identities and actual counts are separate checks.
w <- read.csv("output/weights.csv")
w$mass <- w$considered_info * w$wc + w$unconsidered_info * w$wu
w$error <- w$mass - w$responses_with_info
w$sampled <- as.numeric(table(factor(d$SI[d$match == 0], levels = w$SI)))
write.csv(w, "output/weight_identities.csv", row.names = FALSE)
a <- x$ads
it <- x$interviews
funnel <- do.call(rbind, lapply(0:1, function(b) {
  ids <- a$SI[a$brides == b]
  ii <- it[match(ids, it$SI), ]
  data.frame(
    advertiser = if (b == 1) "female" else "male", interviewed = length(ids),
    found = sum(ii$outcome < 6, na.rm = TRUE), married_or_engaged = sum(ii$outcome < 5, na.rm = TRUE),
    spouse_observed = sum(ids %in% x$marriages$SI)
  )
}))
write.csv(funnel, "output/funnel.csv", row.names = FALSE)
# The comparison holds advertiser covariates fixed in both regressions.
contrasts <- list()
for (id in c("T3_1", "T4_1")) {
  m <- models[[id]]
  dd <- m$data
  dd <- dd[complete.cases(dd[, c("considered", "weight", "SI", m$vars)]) & is.finite(dd$weight) & dd$weight > 0, ]
  f <- feols(formula(m$fit), dd, weights = ~weight, fixef.rm = "none", vcov = ~SI, notes = FALSE)
  for (category in c("reference", "only_within", "no_bar")) {
    cc <- setNames(rep(0, length(coef(f))), names(coef(f)))
    cc["samecaste"] <- 1
    if (category == "only_within") cc["casteimportantmatch"] <- 1
    if (category == "no_bar") cc["castenotimpmatch"] <- 1
    estimate <- sum(cc * coef(f))
    se <- sqrt(drop(t(cc) %*% vcov(f) %*% cc))
    contrasts[[paste(id, category)]] <- data.frame(
      model = id, category = category,
      estimate = estimate, se = se, lower = estimate - qt(.975, length(unique(m$data$SI)) - 1) * se,
      upper = estimate + qt(.975, length(unique(m$data$SI)) - 1) * se
    )
  }
}
write.csv(do.call(rbind, contrasts), "output/caste_group_contrasts.csv", row.names = FALSE)
# Recover the simplified predicted-income specification's point estimates.
limited <- list()
for (id in c("T3_1", "T4_1")) {
  m <- models[[id]]
  dd <- m$data
  sex <- if (id == "T3_1") "male" else "female"
  incvars <- c(paste0("edu_", sex, 3:7), paste0(c(
    "otheredu_dum", "science", "comm", "otherfield", "noedu",
    "nofield", "logwage", "nowage"
  ), "_", sex))
  ff <- lm(reformulate(incvars, paste0("logincome_", sex)), dd,
    weights = weight,
    subset = dd[[paste0("noincome_", sex)]] == 0
  )
  dd$predicted_income <- predict(ff, dd)
  remove <- c(incvars, "sameedu_max", "moreedu", "samenoedu", paste0(c("logincome", "noincome"), "_", sex))
  vv <- c(setdiff(m$vars, remove), "predicted_income")
  fit <- feols(as.formula(paste("considered ~", paste(vv, collapse = "+"), "| SI")), dd,
    weights = ~weight, notes = FALSE, fixef.rm = "none"
  )
  limited[[id]] <- list(fit = fit, first = ff, data = dd, vars = vv, income_vars = incvars)
  cat(id, "limited:", coef(fit)[c("samecaste", "predicted_income")], "\n")
}
saveRDS(limited, "output/limited_models.rds")
lim <- do.call(rbind, lapply(names(limited), function(id) {
  b <- coef(limited[[id]]$fit)
  ratio <- b["samecaste"] / b["predicted_income"]
  data.frame(
    model = id, samecaste = b["samecaste"], predicted_income = b["predicted_income"],
    log_income_tradeoff = ratio, outside_income_premium = exp(ratio) - 1, inside_income_discount = 1 - exp(-ratio)
  )
}))
write.csv(lim, "output/income_tradeoffs.csv", row.names = FALSE)
print(do.call(rbind, handoff))
print(funnel)
print(lim)
