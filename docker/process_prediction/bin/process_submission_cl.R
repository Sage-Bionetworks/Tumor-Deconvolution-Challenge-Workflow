library(argparse)
library(rjson)

source("/usr/local/bin/process_submission_file.R")
# source("docker/process_prediction/bin/process_submission_file.R")

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

parser$add_argument(
    "--fail_missing",
    action = "store_true"
)

args <- parser$parse_args()
# args <- list(
#     validation_file = "example_files/example_gold_standard/fast_lane_course.csv",
#     submission_file = "example_files/output_example/predictions.csv",
#     score_submission = T,
#     fail_missing = T
# )

result <- process_submission_file(
    args$submission_file,
    args$validation_file, 
    args$score_submission,
    args$fail_missing
)

annotation_json <- 
    list(
        "prediction_file_status" = result$status,
        "validation_error" = result$reason
    ) %>%  
    c(result$annotations) %>% 
    rjson::toJSON(.) %>% 
    write("annotation.json")

if (length(result$annotations) > 1) {
    result_list <- list(
        "status" = result$status,
        "invalid_reason_string" = result$reason,
        "annotation_string" =  result$annotations %>% 
            purrr::keep(stringr::str_detect(names(.), "rounded")) %>% 
            purrr::discard(., is.na(.)) %>%
            magrittr::set_names(stringr::str_remove_all(
                names(.),
                "_rounded"
            )) %>% 
            purrr::imap(~stringr::str_c(.y, .x, sep = ":")) %>%
            stringr::str_c(collapse = ";")
    )
} else {
    result_list <- list(
        "status" = result$status,
        "invalid_reason_string" = result$reason,
        "annotation_string" =  result$annotations
    )
}

result_list %>%  
    rjson::toJSON(.) %>% 
    write("results.json")

