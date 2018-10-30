require(rjson)
require(readr)
require(tidyr)
require(dplyr)
require(magrittr)
require(stringr)


get_submission_status_json <- function(submission_file, validation_file){
    status <- check_submission_file(submission_file, validation_file)
    if(status$status == "VALIDATED"){
        result_list = list(
            'prediction_file_errors' = "",
            'prediction_file_status' = status$status)
    } else {
        result_list = list(
            'prediction_file_errors' = stringr::str_c(
                status$reasons, 
                collapse = "\n"),
            'prediction_file_status' = status$status)
    }
    return(rjson::toJSON(result_list))
}

check_submission_file <- function(submission_file, validation_file){
    validation_df <- readr::read_csv(validation_file)
    
    status <- list("status" = "VALIDATED", "reasons" = c())
    
    status <- check_submission_file_readable(status, submission_file)
    
    if(status$status == "INVALID") return(status)
    
    status <- check_submission_file_has_cell_type_column(
        status, submission_file)
    
    if(status$status == "INVALID") return(status)
    
    submission_df <- readr::read_csv(submission_file)
    
    status <- check_submission_structure(status, validation_df, submission_df)
    
    if(status$status == "INVALID") return(status)
    
    status <- check_submission_values(status, submission_df)
    
    return(status)  
}


check_submission_file_readable <- function(status, submission_file){
    result <- try(readr::read_csv(submission_file), silent = TRUE)
    if (is.data.frame(result)){
        return(status)  
    } else {
        status$status = "INVALID"
        status$reasons = result[[1]]
        return(status)
    }
}

check_submission_file_has_cell_type_column <- function(status, submission_file){
    df <- readr::read_csv(submission_file)
    first_header <- colnames(df)[[1]]
    if(first_header == "cell_type"){
        return(status)  
    } else {
        status$status = "INVALID"
        status$reasons = stringr::str_c(
            "1st column header of submission file is not cell_type: ",
            first_header)
        return(status)
    }
}

check_submission_structure <- function(status, validation_df, submission_df){
    
    submission_cell_types <- submission_df$cell_type
    validation_cell_types <- validation_df$cell_type
    submission_samples <- get_samples_from_df(submission_df)
    validation_samples <- get_samples_from_df(validation_df)
    
    non_unique_cell_types <- submission_df %>% 
        dplyr::mutate(item_col = cell_type) %>% 
        get_non_unique_items
    
    non_unique_samples <- submission_samples %>% 
        dplyr::data_frame("item_col" = .) %>% 
        get_non_unique_items
    
    missing_cell_types <- setdiff(validation_cell_types, submission_cell_types)
    extra_cell_types   <- setdiff(submission_cell_types, validation_cell_types)
    missing_samples    <- setdiff(validation_samples, submission_samples)
    extra_samples      <- setdiff(submission_samples, validation_samples)
    
    invalid_item_list <- list(
        non_unique_cell_types,
        non_unique_samples,
        missing_cell_types,
        extra_cell_types,
        missing_samples,
        extra_samples
    )
    
    error_messages <- c(
        "Submission file has non_unique cell types: ",
        "Submission file has non_unique samples: ",
        "Submission file has missing cell types: ",
        "Submission file has extra cell types: ",
        "Submission file has missing samples: ",
        "Submission file has extra samples: "
    )
    
    for(i in 1:length(error_messages)){
        status <- update_submission_status_and_reasons(
            status,
            invalid_item_list[[i]],
            error_messages[[i]])
    }
    return(status)
}

check_submission_values <- function(status, submission_df){
    prediction_df <- submission_df %>% 
        tidyr::gather(key = "sample", value = "prediction", -cell_type) %>% 
        dplyr::mutate(prediction = as.numeric(prediction))
    contains_na <- prediction_df %>% 
        magrittr::use_series(prediction) %>% 
        is.na() %>% 
        any
    contains_inf <- prediction_df %>% 
        magrittr::use_series(prediction) %>% 
        is.infinite() %>% 
        any
    if(contains_na) {
        status$status = "INVALID"
        status$reasons = "Submission_df missing numeric values" 
    }
    if(contains_inf) {
        status$status = "INVALID"
        status$reasons = c(status$reasons, "Submission_df missing numeric values")
    }
    return(status)
}





get_samples_from_df <- function(df){
    df %>% 
        dplyr::select(-cell_type) %>%
        colnames()
}

get_non_unique_items <- function(df){
    df %>% 
        dplyr::group_by(item_col) %>% 
        dplyr::summarise(count = dplyr::n()) %>% 
        dplyr::filter(count > 1) %>% 
        magrittr::use_series(item_col)
}

update_submission_status_and_reasons <- function(
    current_status, invalid_items, error_message){
    
    if (length(invalid_items) > 0){
        updated_status <- "INVALID"
        updated_reasons <- invalid_items %>%
            stringr::str_c(collapse = ", ") %>%
            stringr::str_c(error_message, .) %>%
            c(current_status$reasons, .)
    } else {
        updated_status <- current_status$status
        updated_reasons <- current_status$reasons
    }
    list("status" = updated_status, "reasons" = updated_reasons)
}
