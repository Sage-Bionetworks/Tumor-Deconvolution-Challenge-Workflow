library(testthat)
library(tibble)
library(stringr)
source("scoring_functions.R")
context("Scoring functions")

VAL <- readr::read_csv( "../../../example_files/example_gold_standard/fast_lane_course.csv")
SUB <- readr::read_csv("../../../example_files/example_submission/output/predictions.csv")
COMB <- dplyr::inner_join(SUB, VAL)

# test_that("score_submission",{

test_that("summarise_by_dataset",{
    df <- COMB %>% 
        summarise_by_cell_type() %>%
        summarise_by_dataset()
    expect_equal(df$median_pearson, rep(1, 2))
    expect_equal(df$median_spearman, rep(1, 2))
})


test_that("summarise_by_cell_type",{
    df <- summarise_by_cell_type(COMB)
    expect_equal(df$pearson, rep(1, 16))
    expect_equal(df$spearman, rep(1, 16))
})

test_that("summarise_by", {
    df1 <- summarise_by(
        SUB, 
        avg = round(mean(prediction)), 
        med = round(median(prediction)), 
        group_cols = "dataset.name"
    )
    expect_equal(df1$avg, c(710, 498))
    expect_equal(df1$med, c(243, 201))
    df2 <- summarise_by(
        SUB, 
        max = round(max(prediction)), 
        min = round(min(prediction)), 
        group_cols = c("dataset.name", "sample.id")
    )
    expect_equal(df2$max, c(3756, 2810, 863, 3101, 1377))
    expect_equal(df2$min, c(75, 41, 58, 102, 24))
})


test_that("score_correlation",{
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

