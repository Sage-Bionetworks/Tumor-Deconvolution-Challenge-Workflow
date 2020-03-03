library(magrittr)
library(dplyr)
library(readr)

try(source("/usr/local/bin/validation_functions.R"))
try(source("/usr/local/bin/scoring_functions.R"))

process_submission_file <- function(
    submission_file, 
    validation_file, 
    score_submission = F,
    fail_missing = T
){
    result <- list(
        "status" = "",
        "reason" = "",
        "annotations" = ""
    )
    validation_df <- readr::read_csv(validation_file)
    read_submission_result <- try(
        readr::read_csv(submission_file), 
        silent = TRUE
    )
    if ( inherits(read_submission_result, 'try-error')) {
        result$status <- "INVALID"
        result$reason = read_submission_result
        submission_df <- NULL
    } else {
        submission_df <- read_submission_result
    }
    
    if (result$status != "INVALID") {
        validate_submission_result <- tryCatch(
            validate_submission(
                submission_df, 
                validation_df, 
                key_cols = c("cell.type", "dataset.name", "sample.id"),
                fail_missing = fail_missing
            ),
            validation_error = function(e) e$message
        )
        if (is.null(validate_submission_result)) {
            result$status <- "VALIDATED"
        } else {
            result$status <- "INVALID"
            result$reason = validate_submission_result
        }
    }
    if (all(result$status == "VALIDATED", score_submission)) {
        result$status <- "SCORED"
        result$annotations <- create_score_annotations(
            submission_df, 
            validation_df)
    }
    return(result)
}

