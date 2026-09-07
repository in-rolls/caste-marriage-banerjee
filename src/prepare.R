library(haven)
base <- "data/original/AEJMicro-2011-0182-Data"
read_data <- function(name) as.data.frame(read_dta(file.path(base, "data", paste0(name, "_AEJ.dta"))))
ads <- read_data("ads")
ads$resstatus <- ads$resstatus1
letters <- read_data("letters")
marriages <- read_data("match")
interviews <- read_data("interview")
stopifnot(!anyDuplicated(ads$SI), !anyDuplicated(interviews$SI), !anyDuplicated(marriages$SI))
write.csv(data.frame(
  file = c("ads", "letters", "match", "interview"),
  n = c(nrow(ads), nrow(letters), nrow(marriages), nrow(interviews))
), "output/sample_inventory.csv", row.names = FALSE)
fields <- c(
  "main_caste_rank", "nocaste", "outcaste", "edu_max", "otheredu_dum", "noedu", "age", "noage",
  "height", "noheight", "skinrank", "noskin", "logincome", "noincome", "resstatus", "res", "nores",
  "family_origin", "nofamily_origin", "beauty", "vbeauty", "nobeauty", "logwage", "nowage", "human",
  "comm", "science", "otherfield", "nofield", "nodowry", "caste", "gotra", "nogotra"
)
rename_beauty <- function(d) {
  for (pair in list(c("beauty_fem", "beauty"), c("vbeauty_fem", "vbeauty"), c("nobeauty_fem", "nobeauty"))) {
    if (pair[1] %in% names(d)) names(d)[names(d) == pair[1]] <- pair[2]
  }
  d
}
ads <- rename_beauty(ads)
letters <- rename_beauty(letters)
marriages$skinrank <- ifelse(marriages$brides == 0, 1.293025, NA_real_)
marriages$noskin <- ifelse(marriages$brides == 0, .1432556, NA_real_)
marriages$beauty <- ifelse(marriages$brides == 0, .3326572, NA_real_)
marriages$vbeauty <- ifelse(marriages$brides == 0, .0717546, NA_real_)
marriages$nobeauty <- ifelse(marriages$brides == 0, .3605477, NA_real_)
# Original keep list excludes considered/rank from actual marriages.
marriages$considered <- NA_real_
marriages$rank <- NA_real_
letters$match <- 0
for (v in setdiff(fields, names(marriages))) marriages[[v]] <- NA_real_
cols <- c("SI", "responseid", "considered", "rank", "match", fields)
pairs <- rbind(letters[, cols], marriages[, cols])
ix <- match(pairs$SI, ads$SI)
pairs <- pairs[!is.na(ix), ]
ix <- ix[!is.na(ix)]
a <- ads[ix, ]
pairs$family_origin[pairs$nofamily_origin == 1 & !is.na(pairs$nofamily_origin)] <- 0
# brides is 1 for a male advertiser seeking a bride in the analysis file.
d <- pairs[, c("SI", "responseid", "considered", "rank", "match")]
d$brides <- 1 - a$brides
d$demand_caste <- a$demand_caste
d$nodem_caste <- a$nodem_caste
d$responses_mail <- a$responses_mail
for (v in fields) {
  d[[paste0(v, "_female")]] <- ifelse(a$brides == 1, a[[v]], pairs[[v]])
  d[[paste0(v, "_male")]] <- ifelse(a$brides == 0, a[[v]], pairs[[v]])
}
w <- interviews
w$wc <- with(w, responses_planned / responses_mail * responses_with_info / considered_info)
w$wc[which(w$responses_planned == 0)] <- 0
w$wu <- with(w, responses_with_info / unconsidered_info - considered_info * wc / unconsidered_info)
w$wu[which(w$unconsidered_info == 0 | w$responses_planned == w$responses_mail)] <- 0
wx <- match(d$SI, w$SI)
d$weight <- ifelse(d$considered == 1, w$wc[wx], w$wu[wx])
write.csv(w[, c(
  "SI", "responses_planned", "responses_mail", "responses_with_info", "considered_info",
  "unconsidered_info", "wc", "wu"
)], "output/weights.csv", row.names = FALSE)
recode_missing <- c(
  "main_caste_rank", "nocaste", "noedu", "resstatus", "nores", "nofamily_origin",
  "noage", "noheight", "nofield", "nodowry", "caste"
)
for (v in recode_missing) {
  x <- d[[paste0(v, "_male")]]
  z <- d[[paste0(v, "_female")]]
  d[[paste0("same", v)]] <- as.numeric(x == z & x != 0 & z != 0)
}
# Preserve the supplied caste map literally; corrected alternatives are separate.
commands <- readLines(file.path(base, "do", "Data_analysis.do"), warn = FALSE)
start <- which(grepl("^\\*GENERATE VARIABLES TO CHARACTERIZE", commands))
map <- commands[(start + 1):which(grepl("^tab samecaste", commands))[1]]
map <- map[grepl("^replace samecaste=1 if", map)]
for (line in map) {
  expression <- sub(";.*$", "", sub("^replace samecaste=1 if ", "", line))
  expression <- gsub("~=", "!=", expression, fixed = TRUE)
  ii <- which(eval(parse(text = expression), d))
  d$samecaste[ii] <- 1
}
d$samecaste[which(d$samemain_caste_rank == 0)] <- 0
for (sex in c("male", "female")) {
  z <- paste0(c("human", "science", "comm", "otherfield"), "_", sex)
  d[[paste0("nofield_", sex)]][which(rowSums(d[, z]) == 0)] <- 1
}
d$sameedu_max <- with(d, as.numeric(edu_max_male == edu_max_female & noedu_male != 1 & noedu_female != 1))
d$samefamily_origin <- with(d, as.numeric(
  family_origin_male == family_origin_female &
    nofamily_origin_male != 1 & nofamily_origin_female != 1
))
d$diffcaste <- with(d, ifelse(main_caste_rank_male == 0 | main_caste_rank_female == 0, 0,
  -(main_caste_rank_male - main_caste_rank_female)
))
d$abovecaste <- with(d, as.numeric(
  main_caste_rank_male < main_caste_rank_female & nocaste_female == 0 &
    nocaste_male == 0
))
d$belowcaste <- with(d, as.numeric(
  main_caste_rank_male > main_caste_rank_female & nocaste_female == 0 &
    nocaste_male == 0
))
d$diff_above <- d$diffcaste * d$abovecaste
d$diff_below <- d$diffcaste * d$belowcaste
for (v in c("age", "height")) {
  m <- d[[paste0(v, "_male")]]
  f <- d[[paste0(v, "_female")]]
  d[[paste0("diff", v)]] <- ifelse(m == 0 | f == 0, 0, m - f)
  d[[paste0("diff", v, "sq")]] <- d[[paste0("diff", v)]]^2
  d[[paste0(v, "_no", v)]] <- f * d[[paste0("no", v, "_male")]]
  d[[paste0("no", v, "_", v)]] <- m * d[[paste0("no", v, "_female")]]
}
d$casteimportantmatch <- d$demand_caste * d$samecaste
d$casteimportantdiff <- d$demand_caste * d$diffcaste
notimp <- with(d, as.numeric(nodem_caste == 0 & demand_caste == 0))
d$castenotimpmatch <- notimp * d$samecaste
d$castenotimpdiff <- notimp * d$diffcaste
nocaste <- ifelse(d$brides == 1, d$nocaste_female, d$nocaste_male)
d$casteimportantno <- d$demand_caste * nocaste
d$castenotimpno <- notimp * nocaste
for (sex in c("male", "female")) {
  d[[paste0("calcutta_", sex)]] <- as.numeric(d[[paste0("resstatus_", sex)]] == 1)
  for (spec in list(c("main_caste_rank", ifelse(sex == "male", "caste_no", "caste_nof")), c(
    "edu_max",
    paste0("edu_", sex)
  ))) {
    x <- d[[paste0(spec[1], "_", sex)]]
    levels <- sort(unique(x))
    for (i in seq_along(levels)) d[[paste0(spec[2], i)]] <- as.numeric(x == levels[i])
  }
}
d$moreedu <- with(d, as.numeric(edu_max_male > edu_max_female & edu_max_male != 0 & edu_max_female != 0))
maxrank <- ave(d$rank, d$SI, FUN = function(z) if (all(is.na(z))) NA_real_ else max(z, na.rm = TRUE))
d$rank[which(maxrank >= 16)] <- NA_real_
d$rank <- 16 - d$rank
saveRDS(list(pairs = d, ads = ads, interviews = interviews, marriages = marriages), "output/prepared.rds")
cat("Prepared", nrow(d), "pairs and", length(unique(d$SI)), "advertisers\n")
