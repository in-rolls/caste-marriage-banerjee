base <- "data/original/AEJMicro-2011-0182-Data/matlab"
male <- as.matrix(read.csv(file.path(base, "all_males_matlab.csv"), header = FALSE))
female <- as.matrix(read.csv(file.path(base, "all_females_matlab.csv"), header = FALSE))
# Aggregate exact pair counts without allocating the full marriage market.
m <- aggregate(rep(1, nrow(male)), data.frame(residence = male[, 2], missing = male[, 9], origin = male[, 1]), sum)
f <- aggregate(rep(1, nrow(female)), data.frame(residence = female[, 2], missing = female[, 9]), sum)
counts <- c(total = 0, changed = 0, false_positive = 0, false_negative = 0)
for (i in seq_len(nrow(m))) {
  for (j in seq_len(nrow(f))) {
    original <- f$missing[j] != 1 && m$origin[i] != 1 && m$missing[i] == f$residence[j]
    corrected <- f$missing[j] != 1 && m$missing[i] != 1 && m$residence[i] == f$residence[j]
    n <- m$x[i] * f$x[j]
    counts <- counts + n * c(1, original != corrected, original && !corrected, !original && corrected)
  }
}
write.csv(data.frame(check = names(counts), pairs = counts, fraction = counts / counts["total"]),
  "output/residence_feature_error.csv",
  row.names = FALSE
)
quality <- list()
for (sex in c("male", "female")) {
  d <- if (sex == "male") male else female
  b <- if (sex == "male") {
    c(-.1749361, -.2561849, -.231943, -.1441574, -.1197571)
  } else {
    c(
      .0408597, -.2146535,
      -.0895027, -.0898811, .0738442
    )
  }
  original <- corrected <- rep(0, nrow(d))
  for (j in seq_along(b)) {
    original <- original + as.numeric(b[j] * d[, 17] == j + 1)
    corrected <- corrected + b[j] * as.numeric(d[, 17] == j + 1)
  }
  quality[[sex]] <- data.frame(
    sex = sex, people = nrow(d), changed = sum(original != corrected),
    mean_change = mean(corrected - original), minimum_change = min(corrected - original),
    maximum_change = max(corrected - original)
  )
}
write.csv(do.call(rbind, quality), "output/quality_education_error.csv", row.names = FALSE)
# Transcribed Table 6 values assess reported fit, not a rerun of matching.
labels <- c(
  "Age difference", "Age correlation", "Height difference", "Height correlation", "Same caste",
  "Caste difference", "Caste correlation", "Same education", "Education difference", "Education correlation",
  "Same family origin", "Family origin difference", "Family origin correlation", "Same residence",
  "Location correlation", "Log wage difference", "Log wage correlation", "Income difference",
  "Income correlation", "Quality difference", "Quality correlation"
)
a <- c(5.90, .88, .11, .86, .93, .21, .85, .56, -.25, .39, 1, 0, 1, .77, .24, -.33, .13, 20855, .29, .14, .27)
lo <- c(5.55, .80, .11, .81, .83, -.02, .50, .23, -.50, .18, .99, 0, .98, .30, -.25, -.55, -.21, -10000, -1, .13, .10)
hi <- c(6.34, .92, .12, .90, .99, .64, 1, .79, 0, .57, 1, .01, 1, 1, .98, -.12, .43, 115501, 1, .15, .44)
y <- c(5.70, .65, .12, .39, .69, .01, .76, .44, .29, .36, .76, .04, .51, .48, -.06, .25, .19, 28374, .45, .12, .20)
ylo <- c(5.35, .57, .11, .29, .64, -.14, .69, .38, .14, .24, .71, -.02, .39, .38, -.22, .13, -.13, -16, .08, .11, .07)
yhi <- c(6.05, .73, .13, .49, .75, .16, .83, .50, .44, .47, .82, .11, .64, .58, .21, .36, .50, 56764, .81, .13, .32)
tab <- data.frame(
  statistic = labels, simulated = a, lower = lo, upper = hi, observed = y, observed_lower = ylo, observed_upper = yhi,
  observed_point_in_simulation_interval = y >= lo & y <= hi, intervals_overlap = yhi >= lo & ylo <= hi
)
write.csv(tab, "output/published_matching_fit.csv", row.names = FALSE)
print(counts)
print(do.call(rbind, quality))
print(colSums(tab[, 8:9]))
