library(testthat)
source("process_submission_file.R")
source("validation_functions.R")
source("scoring_functions.R")


test_that("process_submission_file", {
    prediction_file1 <- "../../../example_files/output_example/predictions.csv"
    prediction_file2 <- "../../../example_files/incorrect_output_examples/missing_fibroblasts.csv"
    prediction_file3 <- "../../../example_files/incorrect_output_examples/extra_predictions.csv"
    prediction_file4 <- "../../../example_files/incorrect_output_examples/predictions_missing_dataset_values.csv"
    score_func <- function(prediction_file, fail_missing){
        process_submission_file(
            prediction_file, 
            "../../../example_files/example_gold_standard/fast_lane_course.csv",
            score_submission = T,
            fail_missing
        )
    }

    result1  <- score_func(prediction_file1, fail_missing = T)
    result2a <- score_func(prediction_file2, fail_missing = T)
    result2b <- score_func(prediction_file2, fail_missing = F)
    result3  <- score_func(prediction_file3, fail_missing = T)
    result4  <- score_func(prediction_file4, fail_missing = T)
    
    expect_equal(result1$status, "SCORED")
    expect_equal(result1$reason, "")
    expect_type(result1$annotations, "double")

    expect_equal(result2a$status, "INVALID")
    expect_equal(
        result2a$reason,
        "Prediction file has missing predictions: [fibroblasts;ds1;Sample_1, fibroblasts;ds1;Sample_2, fibroblasts;ds2;Sample_1, fibroblasts;ds2;Sample_2, fibroblasts;ds2;Sample_3]."
    )
    expect_equal(result2a$annotations, "")
    
    expect_equal(result2b$status, "SCORED")
    expect_equal(result2b$reason, "")
    expect_type(result2b$annotations, "double")
    
    expect_equal(result3$status, "INVALID")
    expect_equal(
        result3$reason,
        "Prediction file has extra predictions: [OTHER_CELL_TYPE;ds2;Sample_3]."
    )
    expect_equal(result3$annotations, "")
    
    print(result4)
    expect_equal(result4$status, "INVALID")
    expect_equal(
        result4$reason,
        "Prediction file contains NA values"
    )
    expect_equal(result4$annotations, "")
})