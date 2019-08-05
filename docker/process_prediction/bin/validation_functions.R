require(magrittr)
require(stringr)
require(dplyr)
require(rlang)
require(tidyr)

validate_submission <- function(
    submission_df, validation_df,
    key_cols = "key",
    pred_col = "prediction",
    meas_col = "measured"){
    
    validate_correct_columns(submission_df, c(key_cols, pred_col))
    validate_complete_df(submission_df, key_cols)
    submission_df2 <- submission_df %>%
        tidyr::unite("key", key_cols, sep = ";") %>%
        dplyr::select("key", "prediction" = pred_col)
    validation_df2 <- validation_df %>%
        tidyr::unite("key", key_cols, sep = ";") %>%
        dplyr::select("key", "measured" = meas_col) %>% 
        dplyr::mutate(measured = 0)
    validate_no_duplicate_rows(submission_df2)
    validate_prediction_column_complete(submission_df2)
    validate_combined_df(submission_df2, validation_df2)
}

# utils ----

prediction_df_rows_to_error_message <- function(
    df,
    column = "key",
    message_prefix = "",
    message_suffix = "."){
    
    if(nrow(df) == 0) return(NA)
    df %>%
        magrittr::extract2(column) %>%
        values_to_list_string %>%
        stringr::str_c(message_prefix, ., message_suffix)
}

values_to_list_string <- function(values, sep = ", "){
    values %>%
        unlist %>%
        as.character() %>%
        stringr::str_c(collapse = sep) %>%
        stringr::str_c("[", ., "]")
}

# correct columns ----

validate_correct_columns <- function(df, correct_columns){
    columns <- sort(colnames(df))
    correct_columns <- sort(correct_columns)
    
    if(!identical(columns, correct_columns)){
        rlang::abort(
            "validation_error",
            message = create_column_names_message(columns, correct_columns)
        )
    }
}

create_column_names_message <- function(columns, correct_columns){
    stringr::str_c(
        "Prediction file has incorrect column names: ",
        values_to_list_string(columns),
        ", but is required to have: ",
        values_to_list_string(correct_columns),
        "."
    )
}

# key columns not empty ----

validate_complete_df <- function(df, check_columns){
    df <- dplyr::select(df, check_columns)
    no_na_df <- tidyr::drop_na(df)
    if(nrow(df) != nrow(no_na_df)){
        rlang::abort(
            "validation_error",
            message = "Prediction file contains NA values"
        )
    }
}

# duplicate rows ----

validate_no_duplicate_rows <- function(df, key_col = "key"){
    df <- filter_column_for_duplicates(df, key_col)
    if(nrow(df) > 0){
        message <- prediction_df_rows_to_error_message(
            df, 
            column = "key",
            message_prefix = "Prediction file contains duplicate predictions: "
        )
        rlang::abort(
            "validation_error",
            message = message
        )
    }
}

filter_column_for_duplicates <- function(df, key_col = "key"){
    df %>%
        dplyr::select("key" = key_col) %>%
        dplyr::group_by(key) %>%
        dplyr::summarise(count = dplyr::n()) %>%
        dplyr::filter(count > 1) %>%
        dplyr::ungroup() %>%
        dplyr::select(-count)
}

# prediction column ----

validate_prediction_column_complete <- function(df){
    func_list <- list(
        "na" = is.na,
        "nan" = is.nan,
        "inf" = is.infinite
    )
    
    msg_list <- list(
        "na" = "Prediction file contains NA values: ",
        "nan" = "Prediction file contains NaN values: ",
        "inf" = "Prediction file contains Inf values: "
    )
    
    message <- 
        purrr::map2(
            func_list, 
            msg_list,
            ~validate_prediction_column_by_func(df, .x, .y)
        ) %>% 
        purrr::discard(., purrr::map_lgl(., is.na)) %>% 
        stringr::str_c(collapse = " ")
    
    if(length(message) > 0){
        rlang::abort(
            "validation_error",
            message = message
        )
    }
}

validate_prediction_column_by_func <- function(df, func, msg){
    df <- filter_rows_by_func(df, func, filter_col = "prediction")
    if(nrow(df) > 0){
        error <- prediction_df_rows_to_error_message(df, message_prefix = msg)
    } else {
        error <- NA
    }
}

filter_rows_by_func <- function(df, filter_func, filter_col, key_col = "key"){
    df %>%
        dplyr::select(key_col, "FILTER_COLUMN" = filter_col) %>%
        dplyr::filter(filter_func(FILTER_COLUMN)) %>%
        dplyr::select(key_col)
}

# combined df ----

validate_combined_df <- function(sub_df, val_df){
    combined_df <- dplyr::full_join(sub_df, val_df)
    extra_preds_df <- dplyr::filter(combined_df, is.na(measured))
    missing_preds_df <- dplyr::filter(combined_df, is.na(prediction))
    message <- 
        purrr::map2_chr(
            list(extra_preds_df, missing_preds_df),
            c(
                "Prediction file has extra predictions: ", 
                "Prediction file has missing predictions: "),
            ~prediction_df_rows_to_error_message(.x, message_prefix = .y)
        ) %>% 
        purrr::discard(., purrr::map_lgl(., is.na)) %>% 
        stringr::str_c(collapse = " ")
    
    if(length(message) > 0){
        rlang::abort(
            "validation_error",
            message = message
        )
    }
}

# ------

# submission_file <- "../../../example_files/example_submission/output/predictions.csv"
# validation_file <- "../../../example_files/example_submission/validation/gold_standard.csv"
# bad_submission_file1 <- "../../../example_files/example_submission/incorrect_output/predictions_missing_column.csv"
# bad_submission_file2 <- "../../../example_files/example_submission/incorrect_output/predictions_missing_dataset_values.csv"
# bad_submission_file3 <- "../../../example_files/example_submission/incorrect_output/predictions_duplicate_rows.csv"
# bad_submission_file4 <- "../../../example_files/example_submission/incorrect_output/predictions_missing_prediction_value.csv"
# bad_submission_file5 <- "../../../example_files/example_submission/incorrect_output/predictions_missing_extra.csv"
# 
# val_df <- readr::read_csv(validation_file)
# sub_df <- readr::read_csv(submission_file)
# bad_sub_df1 <- readr::read_csv(bad_submission_file1)
# bad_sub_df2 <- readr::read_csv(bad_submission_file2)
# bad_sub_df3 <- readr::read_csv(bad_submission_file3)
# bad_sub_df4 <- readr::read_csv(bad_submission_file4)
# bad_sub_df5 <- readr::read_csv(bad_submission_file5)
# key_cols <- colnames(val_df)[1:3]
# 
# res <- validate_submission(sub_df, val_df, key_cols)
# res1 <- validate_submission(bad_sub_df1, val_df, key_cols)
# res2 <- validate_submission(bad_sub_df2, val_df, key_cols)
# res3 <- validate_submission(bad_sub_df3, val_df, key_cols)
# res4 <- validate_submission(bad_sub_df4, val_df, key_cols)
# res5 <- validate_submission(bad_sub_df5, val_df, key_cols)




