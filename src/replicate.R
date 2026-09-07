library(fixest)
library(survival)
setFixest_nthreads(1)
x <- readRDS("output/prepared.rds")
d <- x$pairs
commands <- readLines("data/original/AEJMicro-2011-0182-Data/do/Data_analysis.do", warn = FALSE)
expand_vars <- function(text) {
  tokens <- strsplit(trimws(text), " +")[[1]]
  unlist(lapply(tokens, function(v) {
    if (!grepl("-", v, fixed = TRUE)) {
      return(v)
    }
    ends <- strsplit(v, "-", fixed = TRUE)[[1]]
    prefix <- sub("[0-9]+$", "", ends[1])
    paste0(prefix, seq(
      as.integer(sub(prefix, "", ends[1], fixed = TRUE)),
      as.integer(sub(prefix, "", ends[2], fixed = TRUE))
    ))
  }), use.names = FALSE)
}
get_vars <- function(line) expand_vars(sub(" if.*$", "", sub("^[a-z]+ [a-z]+ ", "", line)))
lines <- c(506, 509, 511, 446, 449, 451)
models <- list()
results <- list()
for (i in seq_along(lines)) {
  id <- paste0(ifelse(i <= 3, "T3_", "T4_"), (i - 1) %% 3 + 1)
  vars <- get_vars(commands[lines[i]])
  dd <- d[which(d$brides == as.integer(i > 3) & d$match != 1), ]
  fml <- as.formula(paste("considered ~", paste(vars, collapse = "+"), "| SI"))
  f <- feols(fml,
    data = dd, weights = ~weight, fixef.rm = "none", vcov = "iid",
    ssc = ssc(K.fixef = "full"), notes = FALSE
  )
  models[[id]] <- list(fit = f, data = dd, vars = vars)
  tab <- coeftable(f)
  results[[id]] <- data.frame(model = id, term = rownames(tab), estimate = tab[, 1], se = tab[, 2], p = tab[
    ,
    4
  ], n = nobs(f))
}
write.csv(do.call(rbind, results), "output/regressions.csv", row.names = FALSE)
for (i in 1:2) {
  id <- paste0("T", i + 2, "_5")
  m <- models[[paste0("T", i + 2, "_1")]]
  dd <- m$data
  fml <- reformulate(c(m$vars, "strata(SI)"), response = "considered")
  f <- clogit(fml, dd, method = "exact")
  tab <- summary(f)$coefficients
  results[[id]] <- data.frame(model = id, term = rownames(tab), estimate = tab[, 1], se = tab[, 3], p = tab[
    ,
    5
  ], n = f$n)
  models[[id]] <- list(fit = f, data = dd, vars = m$vars)
}
write.csv(do.call(rbind, results), "output/regressions.csv", row.names = FALSE)
saveRDS(models, "output/models.rds")
print(do.call(rbind, results)[do.call(rbind, results)$term == "samecaste", ])
