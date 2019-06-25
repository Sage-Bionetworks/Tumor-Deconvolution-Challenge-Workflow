library(magrittr)
library(dplyr)
library(readr)

source("/usr/local/bin/validation_functions.R")
#source("validation_functions.R")
#submission_file <- "../example_files/example_submission/output/predictions.csv"
#validation_file <- "../example_files/example_submission/validation/gold_standard.csv"
#score_submission = F


######

process_submission_file <- function(
    submission_file, 
    validation_file, 
    score_submission = F
){
    result <- list(
        "status" = "",
        "reason" = "",
        "annotations" = ""
    )
    validation_df <- read_csv(validation_file)
    read_submission_result <- try(
        readr::read_csv(submission_file), 
        silent = TRUE
    )
    if(inherits(read_submission_result, 'try-error')){
        result$status <- "INVALID"
        result$reason = read_submission_result
        submission_df <- NULL
    } else {
        submission_df <- read_submission_result
    }
    
    if(result$status != "INVALID"){
        validate_submission_result <- tryCatch(
            validate_submission(
                submission_df, 
                validation_df, 
                key_cols = c("cell.type", "dataset.name", "sample.id")),
            validation_error = function(e) e$message
        )
        if(is.null(validate_submission_result)){
            result$status <- "VALIDATED"
        } else {
            result$status <- "INVALID"
            result$reason = validate_submission_result
        }
    }
    # if(all(result$status == "VALIDATED", score_submission)){
    #     # add scoring functionality
    #     result$status <- "SCORED"
    #     result$annotations <- annotations
    # }
    return(result)
}
