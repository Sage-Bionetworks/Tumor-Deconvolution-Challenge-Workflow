library(argparse)
library(rjson)

source("/usr/local/bin/process_submission_file.R")
#source("process_submission_file.R")

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
# args <- list(
#     validation_file = "lb_coarse_r1.csv",
#     submission_file = "predictions.csv",
#     score_submission = T
# )

result <- process_submission_file(
    args$submission_file,
    args$validation_file, 
    args$score_submission
)

annotation_json <- 
    list(
        "prediction_file_status" = result$status,
        "validation_error" = result$reason
    ) %>%  
    c(result$annotations) %>% 
    rjson::toJSON() %>% 
    write("annotation.json")

result_json <- 
    list(
        "status" = result$status,
        "invalid_reason_string" = result$reason,
        "annotation_string" =  result$annotations %>% 
            purrr::keep(stringr::str_detect(names(.), "rounded")) %>% 
            purrr::keep(stringr::str_detect(names(.), "[:print:]+_[:print:]+_[:print:]+_[:print:]+")) %>% 
            magrittr::set_names(stringr::str_remove_all(names(.), "_rounded")) %>% 
            purrr::imap(~stringr::str_c(.y, .x, sep = ":")) %>%
            stringr::str_c(collapse = ";")
    ) %>%  
    rjson::toJSON() %>% 
    write("results.json")

