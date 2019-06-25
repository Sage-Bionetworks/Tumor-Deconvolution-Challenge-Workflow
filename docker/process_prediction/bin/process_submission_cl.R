library(argparse)
library(rjson)

#source("process_submission_file.R")
source("/usr/local/bin/process_submission_file.R")

parser = ArgumentParser()

parser$add_argument(
    "--submission_file",
    type = "character",
    required = TRUE
)
parser$add_argument(
    "--validation_file",
    type = "character",
    required = TRUE
)
parser$add_argument(
    "--score_submission",
    action = "store_true"
)

args <- parser$parse_args()

result <- process_submission_file(
    args$submission_file,
    args$validation_file, 
    args$score_submission
)

annotation_json <- 
    list(
        "prediction_file_status" = result$status
    ) %>%  
    rjson::toJSON() %>% 
    write("annotation.json")

result_json <- 
    list(
        "status" = result$status,
        "invalid_reason_string" = result$reason,
        "annotation_string" = ""
    ) %>%  
    rjson::toJSON() %>% 
    write("results.json")

