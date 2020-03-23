require(magrittr)
require(stringr)
require(dplyr)
require(rlang)
require(tidyr)

validate_submission <- function(
    submission_df, 
    validation_df,
    key_cols = "key",
    pred_col = "prediction",
    meas_col = "measured",
    fail_missing = T
){
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
    validate_combined_df(submission_df2, validation_df2, fail_missing)
}

# utils ----

prediction_df_rows_to_error_message <- function(
    df,
    key = "key",
    message_prefix = "",
    message_suffix = "."
){
    
    if (nrow(df) == 0) return(NA)
    if (nrow(df) > 30) {
        message <- df %>%
            dplyr::slice(1:30) %>% 
            dplyr::pull(key) %>%
            values_to_list_string %>% 
            stringr::str_c(message_prefix, "First 30: ", ., message_suffix)
        return(message)
    } else {
        message <- df %>%
            dplyr::pull(key) %>%
            values_to_list_string %>% 
            stringr::str_c(message_prefix, ., message_suffix)
        return(message)
    }
    
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
    
    if (!identical(columns, correct_columns)) {
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
    if (nrow(df) != nrow(no_na_df)) {
        rlang::abort(
            "validation_error",
            message = "Prediction file contains NA values"
        )
    }
}

# duplicate rows ----

validate_no_duplicate_rows <- function(df, key_col = "key"){
    df <- filter_column_for_duplicates(df, key_col)
    if (nrow(df) > 0) {
        message <- prediction_df_rows_to_error_message(
            df, 
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
    if (length(message) > 0 && message != "") {
        rlang::abort(
            "validation_error",
            message = message
        )
    }
}

validate_prediction_column_by_func <- function(df, func, msg){
    df <- filter_rows_by_func(df, func, filter_col = "prediction")
    if (nrow(df) > 0) {
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

validate_combined_df <- function(sub_df, val_df, fail_missing = T){
    combined_df      <- dplyr::full_join(sub_df, val_df) 
    extra_preds_df   <- dplyr::filter(combined_df, is.na(measured))
    missing_preds_df <- dplyr::filter(combined_df, is.na(prediction))
    if (fail_missing) {
        message <-
            list(extra_preds_df, missing_preds_df) %>% 
            purrr::map2_chr(
                c(
                    "Prediction file has extra predictions: ", 
                    "Prediction file has missing predictions: "),
                ~prediction_df_rows_to_error_message(
                    .x, 
                    message_prefix = .y
                )
            ) %>% 
            purrr::discard(., purrr::map_lgl(., is.na)) %>% 
            stringr::str_c(collapse = " ") 
    } else {
        message <- 
            prediction_df_rows_to_error_message(
                extra_preds_df,
                message_prefix = "Prediction file has extra predictions: "
            ) %>% 
            purrr::discard(., purrr::map_lgl(., is.na)) %>% 
            stringr::str_c(collapse = " ")
    }
    if (length(message) > 0 && message != "") {
        rlang::abort(
            "validation_error",
            message = message
        )
    }
}





