library(readr)
library(tidyr)
library(dplyr)
library(tibble)


args = commandArgs(trailingOnly=TRUE)
SUBMISSION_FILE <- args[1]
VALIDATION_FILE <- args[2]
JSON_FILE       <- args[3]
STATUS          <- args[4]


if(STATUS == "VALIDATED"){
    submission_df <- SUBMISSION_FILE %>% 
        readr::read_csv() %>% 
        tidyr::gather(key = "sample", value = "prediction", -cell_type) %>% 
        dplyr::mutate(prediction = as.numeric(prediction))
    
    validation_df <- VALIDATION_FILE %>% 
        readr::read_csv() %>% 
        tidyr::gather(key = "sample", value = "measured", -cell_type) %>% 
        dplyr::mutate(measured = as.numeric(measured))
    
    combined_df <- dplyr::left_join(validation_df, submission_df)
    
    score_df <- combined_df %>% 
        dplyr::group_by(cell_type) %>% 
        dplyr::summarise(spearman = cor(measured, prediction, method = "spearman")) %>% 
        tidyr::drop_na()
    
    mean_spearman <- score_df %>% 
        dplyr::summarise(mean_spearman = mean(spearman, na.rm = T)) %>% 
        magrittr::use_series(mean_spearman)
    
    result_json <- score_df %>% 
        tibble::deframe() %>% 
        as.list() %>% 
        magrittr::inset("mean_spearman", value = mean_spearman) %>% 
        magrittr::inset("prediction_file_status", value = "SCORED") %>% 
        rjson::toJSON()
    
} else {
    
    result_json <- 
        list("prediction_file_status" = STATUS) %>% 
        rjson::toJSON()
}

write(result_json, JSON_FILE)


