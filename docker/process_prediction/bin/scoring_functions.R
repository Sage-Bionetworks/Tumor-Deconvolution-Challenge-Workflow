require(dplyr)
require(tidyr)
require(magrittr)
require(purrr)

create_score_annotations <- function(submission_df, validation_df){
    combined_df <- validation_df %>% 
        tidyr::drop_na() %>% 
        dplyr::left_join(submission_df)
    ct_summary_df1 <- summarize_by_dataset_and_cell_type(combined_df)
    ct_summary_df2 <- ct_summary_df1 %>% 
        dplyr::group_by(cell.type) %>% 
        dplyr::summarise_if(is.numeric, mean) %>% 
        dplyr::ungroup()
    ct_summary_df3 <- ct_summary_df2 %>% 
        dplyr::summarise_if(is.numeric, mean) %>% 
        dplyr::ungroup()
    scores1 <- df_to_metric_vector(ct_summary_df1, dataset.name, cell.type)
    rounded_scores1 <- round_named_list(scores1)
    scores2 <- df_to_metric_vector(ct_summary_df2, cell.type)
    rounded_scores2 <- round_named_list(scores2)
    scores3 <- df_to_metric_vector2(ct_summary_df3)
    rounded_scores3 <- round_named_list(scores3)
    c(scores1, rounded_scores1, scores2, rounded_scores2, scores3, 
      rounded_scores3
    )
}

summarize_by <- function(.data, .group_cols = rlang::exprs(), ...){
    .data %>%
        dplyr::group_by(!!!.group_cols) %>%
        dplyr::summarize(...) %>% 
        dplyr::ungroup()
}

summarize_by_dataset_and_cell_type <- purrr::partial(
    summarize_by,
    .group_cols = rlang::exprs(dataset.name, cell.type),
    pearson = score_correlation(prediction, measured),
    spearman = score_correlation(
        prediction,
        measured, 
        method = "spearman"
    )
)

score_correlation <- function(v1, v2, ...){
    if (is.na(cov(v1, v2))) return(NA)
    if (cov(v1, v2) == 0) return(0)
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


