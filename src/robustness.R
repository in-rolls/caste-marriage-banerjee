library(fixest)
library(fwildclusterboot)
setFixest_nthreads(1)
models <- readRDS("output/models.rds")
all_results <- list()
deletions <- list()
wild <- list()
diagnostics <- list()
set.seed(114406)
dqrng::dqset.seed(114406)
for (id in c("T3_1", "T4_1")) {
  m <- models[[id]]
  dd <- m$data
  dd <- dd[complete.cases(dd[, c("considered", "weight", "SI", m$vars)]) & is.finite(dd$weight) & dd$weight > 0, ]
  variants <- c("published", "unweighted", "equal_advertiser", "caste_typo_fixed", "known_caste", "weight_trim99")
  for (variant in variants) {
    z <- dd
    if (variant == "unweighted") z$weight <- 1
    if (variant == "equal_advertiser") z$weight <- z$weight / ave(z$weight, z$SI, FUN = sum)
    if (variant == "weight_trim99") z$weight <- pmin(z$weight, quantile(z$weight, .99))
    if (variant == "known_caste") z <- z[z$nocaste_male == 0 & z$nocaste_female == 0, ]
    if (variant == "caste_typo_fixed") {
      changed <- with(z, caste_female == 16 & caste_male %in% c(17, 100) & samemain_caste_rank == 1 & samecaste == 0)
      changed[is.na(changed)] <- FALSE
      diagnostics[[id]] <- data.frame(
        model = id, eligible_pairs = nrow(z), typo_changes = sum(changed),
        advertisers = length(unique(z$SI))
      )
      z$samecaste[changed] <- 1
      z$casteimportantmatch <- z$demand_caste * z$samecaste
      z$castenotimpmatch <- with(z, (nodem_caste == 0 & demand_caste == 0) * samecaste)
    }
    f <- feols(formula(m$fit),
      data = z, weights = ~weight, fixef.rm = "none", vcov = ~SI,
      ssc = ssc(K.fixef = "nonnested"), notes = FALSE
    )
    ct <- coeftable(f)
    all_results[[paste(id, variant)]] <- data.frame(
      model = id, variant = variant, term = rownames(ct),
      estimate = ct[, 1], se = ct[, 2], p = ct[, 4], n = nobs(f), clusters = length(unique(z$SI))
    )
    if (variant == "published") {
      cat("Wild bootstrap", id, "\n")
      b <- boottest(f,
        param = "samecaste", clustid = "SI", B = 9999, impose_null = TRUE,
        type = "rademacher", engine = "R", conf_int = FALSE, nthreads = 1
      )
      wild[[id]] <- data.frame(model = id, term = "samecaste", B = 9999, p = b$p_val)
      by_id <- lapply(unique(z$SI), function(g) {
        fit <- feols(formula(m$fit),
          data = z[z$SI != g, ], weights = ~weight, fixef.rm = "none", vcov = ~SI,
          notes = FALSE
        )
        cc <- coeftable(fit)["samecaste", ]
        data.frame(model = id, omitted = g, estimate = cc[1], se = cc[2], p = cc[4])
      })
      deletions[[id]] <- do.call(rbind, by_id)
    }
  }
}
out <- do.call(rbind, all_results)
focal <- out[out$variant == "published" & out$term %in% c(
  "samecaste", "diff_above", "diff_below",
  "casteimportantmatch", "castenotimpmatch", "casteimportantdiff", "castenotimpdiff"
), ]
focal$bonferroni <- p.adjust(focal$p, "bonferroni")
focal$BH <- p.adjust(focal$p, "BH")
write.csv(out, "output/robustness.csv", row.names = FALSE)
write.csv(focal, "output/multiplicity.csv", row.names = FALSE)
write.csv(do.call(rbind, deletions), "output/leave_one_advertiser_out.csv", row.names = FALSE)
write.csv(do.call(rbind, wild), "output/wild_bootstrap.csv", row.names = FALSE)
write.csv(do.call(rbind, diagnostics), "output/caste_typo_impact.csv", row.names = FALSE)
print(out[out$term == "samecaste", ])
