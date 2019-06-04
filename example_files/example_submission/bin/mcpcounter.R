library(MCPcounter)
library(dplyr)
library(readr)
library(purrr)
library(magrittr)
library(tibble)
library(tidyr)

input_df <- readr::read_csv("input/input.csv")

dataset_names <- input_df$dataset.name

expression_files  <- input_df$hugo.expr.file

expression_paths <- paste0("input/", expression_files)

##### MCPcounter example code below ########

genes <- as.data.frame(readr::read_csv("genes.csv"))
probesets <- as.data.frame(readr::read_csv("probesets.csv"))

translation_df <- tibble::tribble(
    ~cell.type, ~mcpcounter.cell.type,
    "B.cells", "B lineage",
    "CD4.T.cells", "T cells",
    "CD8.T.cells", "CD8 T cells",
    "NK.cells", "NK cells",
    "neutrophils", "Neutrophils",
    "monocytic.lineage", "Monocytic lineage",
    "fibroblasts", "Fibroblasts",
    "endothelial.cells", "Endothelial cells"
)

do_mcpcounter <- function(expression_path, dataset_name){
    expression_path %>% 
        readr::read_csv() %>% 
        as.data.frame() %>%
        tibble::column_to_rownames("Gene") %>% 
        as.matrix() %>% 
        MCPcounter::MCPcounter.estimate(
            probesets = probesets,
            genes = genes,
            featuresType = 'HUGO_symbols') %>% 
        as.data.frame() %>% 
        tibble::rownames_to_column("mcpcounter.cell.type") %>% 
        dplyr::as_tibble() %>% 
        tidyr::gather(key = "sample.id", value = "prediction", -mcpcounter.cell.type) %>% 
        dplyr::mutate(dataset.name = dataset_name)
}

result_df <- 
    purrr::map2(expression_paths, dataset_names, do_mcpcounter) %>% 
    dplyr::bind_rows() %>% 
    dplyr::inner_join(translation_df) %>% 
    dplyr::select(dataset.name, sample.id, cell.type, prediction)

##### MCPcounter example code above ########

dir.create("output")

readr::write_csv(result_df, "output/predictions.csv")
    
