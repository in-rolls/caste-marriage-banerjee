# Published Table 7 (Fisman et al. 2008, p. 127); contrasts reverse the table's sign.
fisman_comparisons <- data.frame(
  decision_maker = rep(c("White woman", "White man"), each = 3),
  alternative_partner = rep(c("Black", "Hispanic", "Asian"), 2),
  white_partner_advantage = c(.123, .092, .075, -.004, -.013, -.051),
  published_standard_error = c(.044, .031, .027, .046, .029, .034),
  observations = rep(c(1765L, 2070L), each = 3),
  overall_yes_rate = rep(c(.33, .46), each = 3)
)
fisman_comparisons$lower <- fisman_comparisons$white_partner_advantage -
  qnorm(.975) * fisman_comparisons$published_standard_error
fisman_comparisons$upper <- fisman_comparisons$white_partner_advantage +
  qnorm(.975) * fisman_comparisons$published_standard_error
fisman_comparisons$source <- "https://sites.bu.edu/fisman/files/2015/11/RES08-racial_preferences.pdf"
write.csv(fisman_comparisons, "output/us_fisman_comparison.csv", row.names = FALSE)

# Published Table 3, columns 1 and 3 (Hitsch et al. 2010 AER, p. 147).
hitsch_comparisons <- data.frame(
  decision_maker = rep(c("White woman", "White man"), each = 3),
  alternative_partner = rep(c("Black", "Hispanic", "Asian"), 2),
  alternative_log_odds = c(-.743, -.5752, -1.5952, -.8301, -.2821, -.4952),
  published_standard_error = c(.1195, .0897, .2408, .0861, .0367, .0436)
)
hitsch_comparisons$white_partner_odds_ratio <- exp(-hitsch_comparisons$alternative_log_odds)
hitsch_comparisons$lower <- exp(
  -hitsch_comparisons$alternative_log_odds - qnorm(.975) * hitsch_comparisons$published_standard_error
)
hitsch_comparisons$upper <- exp(
  -hitsch_comparisons$alternative_log_odds + qnorm(.975) * hitsch_comparisons$published_standard_error
)
hitsch_comparisons$source <- paste0(
  "https://www.tau.ac.il/~weiss/fam_econ/Matching%20and%20Sorting%20in%20Online%20Dating%20-%20Hitsch.pdf"
)
write.csv(hitsch_comparisons, "output/us_hitsch_comparison.csv", row.names = FALSE)
