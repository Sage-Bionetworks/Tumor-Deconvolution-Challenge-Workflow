require(dplyr)
require(tidyr)
require(magrittr)
require(purrr)

create_score_annotations <- function(submission_df, validation_df){
    combined_df <- validation_df %>% 
        tidyr::drop_na() %>% 
        dplyr::left_join(submission_df)
    ct_summary_df <- summarize_by_cell_type(combined_df)
    scores <- df_to_metric_vector(ct_summary_df, dataset.name, cell.type)
    rounded_scores <- round_named_list(scores) 
    c(scores, rounded_scores)
}

summarize_by <- function(.data, .group_cols = rlang::exprs(), ...){
    .data %>%
        dplyr::group_by(!!!.group_cols) %>%
        dplyr::summarize(...) %>% 
        dplyr::ungroup()
}

summarize_by_cell_type <- purrr::partial(
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


