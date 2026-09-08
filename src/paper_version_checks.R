pdftotext <- Sys.which("pdftotext")
if (!nzchar(pdftotext)) stop("Install Poppler to provide pdftotext.")
final_fit <- read.csv("output/published_matching_fit.csv")
expected_labels <- c(
  "Age diff.", "Age corr.", "Height diff.", "Height corr.", "Same caste",
  "Caste diff.", "Caste corr.", "Same education", "Education diff.",
  "Education corr.", "Same family origin", "Family origin diff.",
  "Family origin corr.", "Same residence", "Location corr.",
  "Log wage diff.", "Log wage corr.", "Income diff.", "Income corr.",
  "Quality diff.", "Quality corr."
)
versions <- c(
  nber_2009 = "sources/paper_2009_nber.pdf",
  november_2010 = "sources/paper_2010_11.pdf"
)
comparisons <- list()
for (version in names(versions)) {
  extracted_text <- tempfile(fileext = ".txt")
  status <- system2(pdftotext, c("-layout", shQuote(versions[[version]]), shQuote(extracted_text)))
  if (status != 0L) stop("PDF extraction failed: ", version)
  lines <- readLines(extracted_text, warn = FALSE)
  unlink(extracted_text)
  start <- grep("Table [0-9]+: Couples. characteristics, simulated and observed", lines)
  stopifnot(length(start) == 1L)
  end <- start + grep("Panel B: With search frictions", lines[(start + 1L):length(lines)])[1]
  rows <- lines[start:end]
  rows <- rows[grepl("^[[:space:]]*[A-Za-z]", rows)]
  values <- lapply(regmatches(rows, gregexpr("-?[0-9]+(?:\\.[0-9]+)?", rows, perl = TRUE)), as.numeric)
  keep <- lengths(values) == 8L
  labels <- trimws(sub("[[:space:]]+-?[0-9].*$", "", rows[keep]))
  stopifnot(identical(labels, expected_labels))
  values <- do.call(rbind, values[keep])
  comparisons[[version]] <- data.frame(
    version = version, source = versions[[version]], statistic = final_fit$statistic,
    lower = values[, 1], upper = values[, 2], observed = values[, 6],
    observed_lower = values[, 7], observed_upper = values[, 8]
  )
}
comparisons$final_2013 <- data.frame(
  version = "final_2013", source = "sources/paper.pdf",
  final_fit[, c("statistic", "lower", "upper", "observed", "observed_lower", "observed_upper")]
)
comparison <- do.call(rbind, comparisons)
stopifnot(all(comparison$lower <= comparison$upper))
stopifnot(all(comparison$observed_lower <= comparison$observed_upper))
comparison$point_inside <- with(comparison, observed >= lower & observed <= upper)
comparison$intervals_overlap <- with(comparison, observed_upper >= lower & observed_lower <= upper)
write.csv(comparison, "output/paper_version_fit_checks.csv", row.names = FALSE)
summary <- aggregate(cbind(point_inside, intervals_overlap) ~ version, comparison, sum)
summary$statistics <- as.integer(table(comparison$version)[summary$version])
summary$text_claim_inside <- 14L
summary$text_claim_overlap <- 15L
write.csv(summary, "output/paper_version_fit_summary.csv", row.names = FALSE)
print(summary)
