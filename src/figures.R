r <- read.csv("output/robustness.csv")
z <- r[r$variant == "published" & r$term == "samecaste", ]
png("figs/same-caste.png", width = 1600, height = 950, res = 170)
par(mar = c(6, 11, 3, 2))
plot(z$estimate * 100, 2:1,
  xlim = c(0, 30), ylim = c(.5, 2.5), yaxt = "n", ylab = "",
  xlab = "Difference in consideration (percentage points)", pch = 19, col = "#176880", cex = 1.4,
  main = "Same-caste letters are more likely to be considered"
)
axis(2, at = 2:1, labels = c("Seeking a groom", "Seeking a bride"), las = 1)
ci <- qt(.975, z$clusters - 1) * z$se
segments((z$estimate - ci) * 100, 2:1, (z$estimate + ci) * 100, 2:1, lwd = 2, col = "#176880")
abline(v = 0, col = "grey70", lty = 2)
mtext("95% intervals cluster letters by advertiser; no stated caste preference is the reference group.",
  side = 1, line = 5, cex = .75
)
dev.off()
