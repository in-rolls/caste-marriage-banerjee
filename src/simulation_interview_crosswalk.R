library(haven)
all_ads <- as.data.frame(read_dta("data/original/AEJMicro-2011-0182-Data/data/allads_AEJ.dta"))
interview_ads <- readRDS("output/prepared.rds")$ads
identified_ads <- all_ads[!is.na(all_ads$SI) & !is.na(all_ads$brides), ]
parse_identifier <- function(identifier, interview_id) {
  if (!nzchar(trimws(identifier))) return(c(interview_id, 0, 0, 0))
  pieces <- strsplit(trimws(identifier), "/", fixed = TRUE)[[1]]
  stopifnot(length(pieces) == 3L)
  suffix_present <- as.numeric(grepl("[A-Za-z]", pieces[3]))
  c(as.numeric(gsub("[A-Za-z]", "", pieces)), suffix_present)
}
identifiers <- t(mapply(parse_identifier, identified_ads$id, identified_ads$SI))
identified_ads$identifier_key <- apply(identifiers, 1, paste, collapse = ":")
identified_ads$sex <- ifelse(identified_ads$brides == 0, "male", "female")
identified_ads$expected_sex <- ifelse(interview_ads$brides[match(identified_ads$SI, interview_ads$SI)] == 0,
  "male", "female"
)
identified_ads$duplicate_interview_id <- duplicated(identified_ads$SI) |
  duplicated(identified_ads$SI, fromLast = TRUE)
identified_ads$key <- paste(identified_ads$sex, identified_ads$identifier_key)
identified_ads$ambiguous_identifier <- duplicated(identified_ads$key) |
  duplicated(identified_ads$key, fromLast = TRUE)
stopifnot(!anyNA(identified_ads$expected_sex))

crosswalk <- lapply(c("male", "female"), function(sex) {
  simulation_data <- as.matrix(read.csv(paste0(
    "data/original/AEJMicro-2011-0182-Data/matlab/all_", sex, "s_matlab.csv"
  ), header = FALSE))
  simulation_keys <- paste(sex, apply(simulation_data[, 32:35], 1, paste, collapse = ":"))
  source_rows <- match(simulation_keys, identified_ads$key)
  matched <- !is.na(source_rows)
  matched_rows <- source_rows[matched]
  attribute_columns <- c(family_origin = 1L, resstatus = 2L, age = 3L, main_caste_rank = 5L,
    height = 11L, edu_max = 17L
  )
  attribute_matches <- vapply(names(attribute_columns), function(attribute) {
    original_value <- identified_ads[[attribute]][matched_rows]
    simulation_value <- simulation_data[matched, attribute_columns[[attribute]]]
    !is.na(original_value) & abs(original_value - simulation_value) < 1e-4
  }, logical(sum(matched)))
  attributes_agree <- rep(NA, nrow(simulation_data))
  attributes_agree[matched] <- rowSums(attribute_matches) == ncol(attribute_matches)
  sex_agrees <- rep(NA, nrow(simulation_data))
  sex_agrees[matched] <- identified_ads$sex[matched_rows] == identified_ads$expected_sex[matched_rows]
  status <- rep("no_interview_identifier", nrow(simulation_data))
  status[matched] <- "verified_identifier_and_attributes"
  status[matched & !attributes_agree] <- "attribute_disagreement"
  status[matched & !sex_agrees] <- "interview_sex_disagreement"
  ambiguous_identifier <- identified_ads$ambiguous_identifier[source_rows]
  status[matched & ambiguous_identifier] <- "ambiguous_interview_identifier"
  interview_ids <- identified_ads$SI[source_rows]
  interview_ids[matched & ambiguous_identifier] <- NA_real_
  data.frame(
    sex = sex, simulation_row = seq_len(nrow(simulation_data)),
    SI = interview_ids, original_id = identified_ads$id[source_rows],
    status = status, attributes_agree = attributes_agree, interview_sex_agrees = sex_agrees,
    duplicate_interview_id_in_source = identified_ads$duplicate_interview_id[source_rows]
  )
})
crosswalk <- do.call(rbind, crosswalk)
verified <- crosswalk[crosswalk$status == "verified_identifier_and_attributes", ]
stopifnot(!anyDuplicated(verified$SI))
write.csv(crosswalk, "output/simulation_interview_crosswalk.csv", row.names = FALSE)
write.csv(as.data.frame(table(crosswalk$sex, crosswalk$status)),
  "output/simulation_interview_crosswalk_counts.csv", row.names = FALSE
)
print(table(crosswalk$sex, crosswalk$status))
print(crosswalk[!is.na(crosswalk$SI) & crosswalk$status != "verified_identifier_and_attributes", ])
cat("Unique verified interview IDs:", nrow(verified), "of", nrow(interview_ads), "\n")
