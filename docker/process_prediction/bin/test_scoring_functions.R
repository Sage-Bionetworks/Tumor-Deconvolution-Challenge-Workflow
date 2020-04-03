library(testthat)
library(tibble)
library(stringr)
source("scoring_functions.R")


VAL1  <- readr::read_csv(
    "../../../example_files/example_gold_standard/fast_lane_course.csv"
)
VAL2  <- readr::read_csv(
    "../../../example_files/example_gold_standard/fast_lane_course_missing_neutrophils.csv"
)

SUB1 <- readr::read_csv(
    "../../../example_files/output_example/predictions.csv"
)
SUB2 <- readr::read_csv(
    "../../../example_files/incorrect_output_examples/missing_fibroblasts.csv"
)
COMB1 <- dplyr::full_join(SUB1, VAL1)
COMB2 <- dplyr::full_join(SUB2, VAL1)
COMB3 <- dplyr::full_join(SUB1, VAL2)


test_that("summarize_by_dataset_and_cell_type",{
    res1 <- summarize_by_dataset_and_cell_type(COMB1)
    expect_equal(res1$pearson, rep(1, 16))
    expect_equal(res1$spearman, rep(1, 16))
    res2 <- summarize_by_dataset_and_cell_type(COMB2)
    expect_equal(tidyr::drop_na(res2)$pearson, rep(1, 14))
    expect_equal(tidyr::drop_na(res2)$spearman, rep(1, 14))
    res3 <- summarize_by_dataset_and_cell_type(COMB3)
})

test_that("score_correlation",{
    expect_equal(
        score_correlation(c(1,2,3), c(NA,NA,NA)),
        NA
    )
    expect_equal(
        score_correlation(c(1,2,3), c(4,5,6)),
        cor(c(1,2,3), c(4,5,6))
    )
    expect_equal(
        score_correlation(c(0,0,0), c(4,5,6)),
        0
    )
    expect_equal(
        score_correlation(c(0,0,0), c(0,0,0)),
        0
    )
    expect_equal(
        score_correlation(c(1,2,3), c(4,5,6), method = "spearman"),
        cor(c(1,2,3), c(4,5,6))
    )
    expect_equal(
        score_correlation(c(0,0,0), c(4,5,6), method = "spearman"),
        0
    )
    expect_equal(
        score_correlation(c(0,0,0), c(0,0,0), method = "spearman"),
        0
    )
})

