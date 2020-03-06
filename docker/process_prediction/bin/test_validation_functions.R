library(testthat)
library(tibble)
library(stringr)
source("validation_functions.R")
context("Validation functions")

test_that("validate_submission", {
    correct_prediction_tbl <- readr::read_csv(
        "../../../example_files/output_example/predictions.csv"
    )
    incorrect_prediction_tbl1 <- readr::read_csv(
        "../../../example_files/incorrect_output_examples/extra_predictions.csv"
    )
    incorrect_prediction_tbl2 <- readr::read_csv(
        "../../../example_files/incorrect_output_examples/missing_predictions.csv"
    )
    gold_standard_tbl <- readr::read_csv(
        "../../../example_files/example_gold_standard/fast_lane_course.csv"
    )
    key_cols <- c("cell.type", "dataset.name", "sample.id")
    expect_null(
        validate_submission(correct_prediction_tbl, gold_standard_tbl, key_cols)
    )
    expect_error(
        validate_submission(
            incorrect_prediction_tbl1, gold_standard_tbl, key_cols
        ),
    )
    expect_error(
        validate_submission(
            incorrect_prediction_tbl2, gold_standard_tbl, key_cols
        ),
    )
    expect_error(
        validate_submission(
            incorrect_prediction_tbl1, 
            gold_standard_tbl, 
            key_cols, 
            fail_missing = F
        ),
    )
    expect_null(
        validate_submission(
            incorrect_prediction_tbl2, 
            gold_standard_tbl, 
            key_cols, 
            fail_missing = F
        ),
    )
})


test_that("prediction_df_rows_to_error_message",{
    df <- tibble::tribble(
        ~col1, ~col2,
        "A", 1,
        "C", 2
    )
    df2 <- tibble::tibble(
        col1 = 1:50
    )
    expect_equal(
        prediction_df_rows_to_error_message(df, "col1", "Incorrect rows: "),
        "Incorrect rows: [A, C].")
    expect_equal(
        prediction_df_rows_to_error_message(df, "col2", "Incorrect values: "),
        "Incorrect values: [1, 2].")
    expect_equal(
        prediction_df_rows_to_error_message(df2, "col1", "Incorrect values: "),
        paste0(
            "Incorrect values: First 30: ", 
            values_to_list_string(1:30), "."
        )
    )
})

test_that("values_to_list_string", {
    expect_equal(
        values_to_list_string(c("A;B;C", "X;Y;Z")),
        "[A;B;C, X;Y;Z]")
    expect_equal(
        values_to_list_string(list("A;B;C", "X;Y;Z")),
        "[A;B;C, X;Y;Z]")
    expect_equal(
        values_to_list_string(c(8, 9, 10)),
        "[8, 9, 10]")
})

# test_that("validate_correct_columns", {
#     correct_columns <- c("dataset.name", "sample.id")
#     df1 <- tibble::tribble(~dataset.name, ~sample.id)
#     df2 <- tibble::tribble(~sample.id, ~dataset.name)
#     df3 <- tibble::tribble(~dataset.name, ~sample.id, ~sample.id)
#     df4 <- tibble::tribble(~dataset.name)
#     df5 <- tibble::tribble(~dataset.name, ~sample_id)
#     df6 <- tibble::tribble(~dataset.name, ~dataset.name)
# 
#     expect_null(validate_correct_columns(df1, correct_columns))
#     expect_null(validate_correct_columns(df2, correct_columns))
#     expect_s3_class(
#         catch_cnd(validate_correct_columns(df3, correct_columns)),
#         "error_incorrect_columns")
#     expect_s3_class(
#         catch_cnd(validate_correct_columns(df4, correct_columns)),
#         "error_incorrect_columns")
#     expect_s3_class(
#         catch_cnd(validate_correct_columns(df5, correct_columns)),
#         "error_incorrect_columns")
#     expect_s3_class(
#         catch_cnd(validate_correct_columns(df6, correct_columns)),
#         "error_incorrect_columns")
# })

test_that("create_column_names_message", {
    expect_equal(
        create_column_names_message(c("col1", "col2"), c("col1", "col3")),
        stringr::str_c(
            "Prediction file has incorrect column names: [col1, col2], ",
            "but is required to have: [col1, col3]."
        )
    )
})

# test_that("validate_complete_df", {
#     df <- tibble::tribble(
#         ~col1, ~col2,
#         "A", "C",
#         "B", NA
#     )
#     expect_null(validate_complete_df(df, "col1"))
#     expect_equal(
#         validate_complete_df(df, "col2"), 
#         "Prediction file contains NA values")
# })

# test_that("validate_no_duplicates",{
#     df <- tibble::tribble(
#         ~col1, ~col2, 
#         "A", "C",
#         "B", "C"
#     )
#     expect_null(validate_no_duplicates(df, "col1"))
#     expect_equal(
#         validate_no_duplicates(df, "col2"),
#         "Prediction file contains duplicate predictions: [C].")
# })

test_that("filter_column_for_duplicates",{
    df <- tibble::tribble(
        ~key,
        "A",
        "B",
        "D",
        "D",
        "E"
    )
    expect_equal(
        filter_column_for_duplicates(df),
        dplyr::tibble(key = "D"))
})

test_that("validate_combined_df", {
    correct_prediction_tbl <- readr::read_csv(
        "../../../example_files/output_example/predictions.csv"
    )
    incorrect_prediction_tbl1 <- readr::read_csv(
        "../../../example_files/incorrect_output_examples/extra_predictions.csv"
    )
    incorrect_prediction_tbl2 <- readr::read_csv(
        "../../../example_files/incorrect_output_examples/missing_predictions.csv"
    )
    gold_standard_tbl <- readr::read_csv(
        "../../../example_files/example_gold_standard/fast_lane_course.csv"
    )
    expect_null(validate_combined_df(correct_prediction_tbl, gold_standard_tbl))
    expect_error(
        validate_combined_df(incorrect_prediction_tbl1, gold_standard_tbl),
    )
    expect_error(
        validate_combined_df(incorrect_prediction_tbl2, gold_standard_tbl),
    )
    expect_error(
        validate_combined_df(incorrect_prediction_tbl1, gold_standard_tbl, fail_missing = F),
    )
    expect_null(
        validate_combined_df(incorrect_prediction_tbl2, gold_standard_tbl, fail_missing = F),
    )
})






# 
# test_that("filter_rows_by_func",{
#     df <- tibble::tribble(
#         ~key, ~col1,
#         "A", 1,
#         "B", NA,
#         "C", Inf,
#         "D", -Inf,
#         "E", NaN
#     )
#     expect_equal(
#         filter_rows_by_func(df, is.na, "col1"),
#         dplyr::tibble(key = c("B", "E")))
#     expect_equal(
#         filter_rows_by_func(df, is.nan, "col1"),
#         dplyr::tibble(key = "E"))
#     expect_equal(
#         filter_rows_by_func(df, is.infinite, "col1"),
#         dplyr::tibble(key = c("C", "D")))
# })
# 

# 

# 
# 

# 
# 
# test_that("validate_correct_rows", {
#     pred_df1 <- tibble::tribble(
#         ~key, ~prediction,
#         "A", 1,
#         "B", 2,
#         "C", 3
#     )
#     pred_df2 <- tibble::tribble(
#         ~key, ~prediction,
#         "A", 1,
#         "C", 3,
#         "B", 2
#     )
#     pred_df3 <- tibble::tribble(
#         ~key, ~prediction,
#         "A", 1,
#         "C", 3
#     )
#     pred_df4 <- tibble::tribble(
#         ~key, ~prediction,
#         "A", 1,
#         "B", 2,
#         "C", 3,
#         "D", 4
#     )
#     pred_df5 <- tibble::tribble(
#         ~key, ~prediction,
#         "A", 1,
#         "B", 2,
#         "C", 3,
#         "C", 3
#     )
#     val_df1 <- tibble::tribble(
#         ~key, ~measured,
#         "A", 4,
#         "B", 5,
#         "C", 6
#     )
#     expect_equal(validate_correct_rows(pred_df1, val_df1), NULL)
#     expect_equal(validate_correct_rows(pred_df2, val_df1), NULL)
#     expect_equal(
#         validate_correct_rows(pred_df3, val_df1), 
#         "Prediction file has missing predictions: [B].")
#     expect_equal(
#         validate_correct_rows(pred_df4, val_df1),
#         "Prediction file has extra predictions: [D].")
#     expect_equal(
#         validate_correct_rows(pred_df5, val_df1),
#         "Prediction file has duplicate predictions: [C]."
#     )
# })
# 
# 
# 
# 
# test_that("df_column_has_na",{
#     df <- tibble::tribble(
#         ~col1, ~col2, 
#         "A", "X", 
#         "B", "NA", 
#         NA, "Z"
#     )
#     expect_true(df_column_has_na(df, "col1"))
#     expect_false(df_column_has_na(df, "col2"))
# })
# 
# 
# test_that("df_column_has_duplicates",{
#     df1 <- tibble::tribble(
#         ~col1, ~col2, 
#         "A", "X", 
#         "B", "Y", 
#         "B", "Z"
#     )
#     df2 <- tibble::tribble(
#         ~col1, ~col2, 
#         "A", "X", 
#         "B", "Y", 
#         "B", "Y"
#     )
#     expect_true(df_column_has_duplicates(df1, "col1"))
#     expect_false(df_column_has_duplicates(df1, "col2"))
#     expect_true(df_column_has_duplicates(df2, "col1"))
#     expect_true(df_column_has_duplicates(df2, "col2"))
# })
# 
# test_that("create_extra_prediction_message",{
#     df <- tibble::tribble(
#         ~key, ~measured, 
#         "A", "X", 
#         "B", "Y", 
#         "C", NA,
#         "D", NA
#     )
#     expect_equal(
#         create_extra_prediction_message(df), 
#         "Prediction file has extra predictions: [C, D]."
#     )
# })
# 
# test_that("create_missing_prediction_message",{
#     df <- tibble::tribble(
#         ~key, ~prediction, 
#         "A", "X", 
#         "B", "Y", 
#         "C", NA,
#         "D", NA
#     )
#     expect_equal(
#         create_missing_prediction_message(df), 
#         "Prediction file has missing predictions: [C, D]."
#     )
# })
# 
# 
# test_that("create_duplicate_rows_message",{
#     df <- tibble::tribble(
#         ~key, 
#         "A",
#         "B",
#         "B",
#         "C",
#         "C"
#     )
#     expect_equal(
#         create_duplicate_rows_message(df), 
#         "Prediction file has duplicate predictions: [B, C]."
#     )
# })
# 
