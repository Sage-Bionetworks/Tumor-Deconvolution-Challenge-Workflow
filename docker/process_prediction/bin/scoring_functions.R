require(dplyr)
require(tidyr)
require(magrittr)

create_score_annotations <- function(sub_df, val_df){
    combined_df <- dplyr::inner_join(sub_df, val_df)
    ct_summary_df <- summarise_by_cell_type(combined_df)
    ds_summary_df <- summarise_by_dataset(ct_summary_df)
    scores <- ds_summary_df %>% 
        tidyr::gather(key = "metric", value = "value", -dataset.name) %>% 
        tidyr::unite("name", dataset.name, metric) %>% 
        tibble::deframe()
    return(scores)
}

summarise_by <- function(df, ..., group_cols) {
    df %>%
        dplyr::group_by_at(dplyr::vars(group_cols)) %>% 
        dplyr::summarise(...) %>% 
        dplyr::ungroup()
}

summarise_by_cell_type <- function(df){
    summarise_by(
        df,
        pearson = score_correlation(prediction, measured),
        spearman = score_correlation(
            prediction,
            measured, 
            method = "spearman"
        ),
        group_cols = c("dataset.name", "cell.type")
    )
}

summarise_by_dataset <- function(df){
    summarise_by(
        df,
        median_pearson = median(pearson),
        median_spearman = median(spearman),
        group_cols = "dataset.name"
    )
}

score_correlation <- function(v1, v2, ...){
    if(cov(v1, v2) == 0) return(0)
    cor(v1, v2, ...)
}