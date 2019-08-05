require(dplyr)
require(tidyr)
require(magrittr)
require(purrr)

create_score_annotations <- function(submission_df, validation_df){
    combined_df <- validation_df %>% 
        tidyr::drop_na() %>% 
        dplyr::left_join(submission_df)
    ct_summary_df <- summarize_by_cell_type(combined_df)
    ds_summary_df <- summarize_by_dataset(combined_df)
    #ds_summary_df <- summarize_by_dataset(ct_summary_df)
    #sub_summary_df <- summarize_by_submission(ds_summary_df)
    scores <- c(
        df_to_metric_vector(ct_summary_df, dataset.name, cell.type),
        df_to_metric_vector(ds_summary_df, dataset.name)
    )
    # scores <- c(
    #     df_to_metric_vector(ct_summary_df, dataset.name, cell.type),
    #     df_to_metric_vector(ds_summary_df, dataset.name),
    #     df_to_metric_vector2(sub_summary_df)
    # )
    rounded_scores <- round_named_list(scores) 
    c(scores, rounded_scores)
}

summarize_by <- function(.data, .group_cols = exprs(), ...){
    .data %>%
        dplyr::group_by(!!!.group_cols) %>%
        dplyr::summarize(...) %>% 
        dplyr::ungroup()
}

summarize_by_cell_type <- purrr::partial(
    summarize_by,
    .group_cols = exprs(dataset.name, cell.type),
    pearson = score_correlation(prediction, measured),
    spearman = score_correlation(
        prediction,
        measured, 
        method = "spearman"
    )
)

summarize_by_dataset <- purrr::partial(
    summarize_by,
    .group_cols = exprs(dataset.name),
    pearson = score_correlation(prediction, measured),
    spearman = score_correlation(
        prediction,
        measured, 
        method = "spearman"
    )
)

# summarize_by_dataset <- purrr::partial(
#     summarize_by,
#     .group_cols = exprs(dataset.name),
#     median_pearson = median(pearson),
#     median_spearman = median(spearman),
# )

summarize_by_submission <- purrr::partial(
    summarize_by,
    mean_median_pearson = mean(median_pearson),
    mean_median_spearman = mean(median_spearman)
)


score_correlation <- function(v1, v2, ...){
    if(cov(v1, v2) == 0) return(0)
    cor(v1, v2, ...)
}


df_to_metric_vector <- function(.data, ...){
    dots <- rlang::enquos(...)
    .data %>%
        tidyr::gather(metric, value, -c(!!!dots)) %>%
        tidyr::unite(name, c(!!!dots, metric)) %>% 
        tibble::deframe()
}

df_to_metric_vector2 <- function(.data){
    .data %>%
        tidyr::gather(metric, value) %>%
        tibble::deframe()
}

round_named_list <- function(
    lst, 
    digits = 3, 
    prefix = "", 
    suffix = "_rounded"
){
    lst %>% 
        round(digits = digits) %>% 
        purrr::set_names(stringr::str_c(
            prefix,
            names(.), 
            suffix
        ))
}


