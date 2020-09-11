synapser::synLogin()

devtools::source_url(
    "https://raw.githubusercontent.com/Sage-Bionetworks/synapse_tidy_utils/master/utils.R"
)

"select * from syn21822681 where objectId = 0" %>% 
    query_synapse_table(row_data = T) %>% 
    synapser::synDelete()

"select * from syn21822682 where objectId = 0" %>% 
    query_synapse_table(row_data = T) %>% 
    synapser::synDelete()
    
coarse <- "coarse_results.json" %>% 
    jsonlite::read_json() %>% 
    purrr::pluck("annotation_string") %>% 
    stringr::str_split(";") %>% 
    unlist() %>% 
    dplyr::tibble("result" = .) %>% 
    tidyr::separate("result", into = c("result", "metric_value"), sep = ":") %>% 
    tidyr::separate("result", into = c("dataset", "celltype", "metric"), sep = "_", fill = "left") %>% 
    dplyr::mutate(
        "celltype" = dplyr::if_else(
            is.na(.data$celltype),
            "Grand mean",
            .data$celltype
        ),
        "dataset" = dplyr::if_else(
            .data$celltype == "Grand mean",
            "Grand mean",
            .data$dataset
        ),
        "dataset" = dplyr::if_else(
            is.na(.data$dataset),
            "Celltype mean",
            .data$dataset
        )
    ) %>% 
    dplyr::mutate(
        "objectId" = 0L,
        "submitterId" = 3360851L,
        "repo_name" = "baseline_method7",
        "submitter" = "andrewelamb",
        "is_latest" = T,
        "metric_value" = as.numeric(.data$metric_value)
    ) %>%
    synapser::Table("syn21822681", .) %>%
    synapser::synStore()

fine <- "fine_results.json" %>% 
    jsonlite::read_json() %>% 
    purrr::pluck("annotation_string") %>% 
    stringr::str_split(";") %>% 
    unlist() %>% 
    dplyr::tibble("result" = .) %>% 
    tidyr::separate("result", into = c("result", "metric_value"), sep = ":") %>% 
    tidyr::separate("result", into = c("dataset", "celltype", "metric"), sep = "_", fill = "left") %>% 
    dplyr::mutate(
        "celltype" = dplyr::if_else(
            is.na(.data$celltype),
            "Grand mean",
            .data$celltype
        ),
        "dataset" = dplyr::if_else(
            .data$celltype == "Grand mean",
            "Grand mean",
            .data$dataset
        ),
        "dataset" = dplyr::if_else(
            is.na(.data$dataset),
            "Celltype mean",
            .data$dataset
        )
    ) %>% 
    dplyr::mutate(
        "objectId" = 0L,
        "submitterId" = 3360851L,
        "repo_name" = "baseline_method7",
        "submitter" = "andrewelamb",
        "is_latest" = T,
        "metric_value" = as.numeric(.data$metric_value)
    ) %>%
    synapser::Table("syn21822682", .) %>%
    synapser::synStore()

