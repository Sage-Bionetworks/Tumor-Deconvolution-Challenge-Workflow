
###############################################################################
# This code use MCPCounter to calculate cell type predictions. 
###############################################################################


library(MCPcounter)
library(dplyr)
library(readr)
library(purrr)
library(magrittr)
library(tibble)
library(tidyr)


## Read in the round and sub-Challenge-specific input file 
## listing each of the datasets
input_df <- readr::read_csv("input/input.csv")

## Extract the names of each dataset
dataset_names <- input_df$dataset.name

## Extract the names of the expression files that use 
## Hugo symbols as gene identifiers
expression_files  <- input_df$hugo.expr.file

## Form the paths of the expression files
expression_paths <- paste0("input/", expression_files)

##### MCPcounter example code below ########

## MCPCounter usually downloads these files. Durring the challenge, Docker
## images are isolated from the internet, so these need to be included.
genes <- as.data.frame(readr::read_csv("genes.csv"))
probesets <- as.data.frame(readr::read_csv("probesets.csv"))


## The outputed cell types from MCPCounter mostly match the cell types for
## the course grained sub-challenge, but with different name style.
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

## This function is run once per input dataset
do_mcpcounter <- function(expression_path, dataset_name){
    
    # This reads in the input file and converts to a matrix wich will be
    # inputed to MCPCounter
    expression_matrix <- expression_path %>% 
        readr::read_csv() %>% 
        as.data.frame() %>%
        tibble::column_to_rownames("Gene") %>% 
        as.matrix() 
    
    # We are using the HUGO version of the expression file, so this needs to
    # indicate that here. probests and genes are the dataframes created above.
    result_matrix <- MCPcounter::MCPcounter.estimate(
        expression_matrix,
        probesets = probesets,
        genes = genes,
        featuresType = 'HUGO_symbols')
    
    # Convert the result matrix back to a dataframe
    result_df <- result_matrix %>% 
        as.data.frame() %>% 
        tibble::rownames_to_column("mcpcounter.cell.type") %>% 
        dplyr::as_tibble()
    
    # Stack the predictions into one column
    result_df <- tidyr::gather(
        result_df,
        key = "sample.id", 
        value = "prediction", 
        -mcpcounter.cell.type) 
    
    # Add dataset column
    result_df <- dplyr::mutate(result_df, dataset.name = dataset_name)
}

# Runs the above function on all expression files
result_dfs <- purrr::map2(expression_paths, dataset_names, do_mcpcounter) 

# Combine all results into one df
combined_result_df <- dplyr::bind_rows(result_dfs)

# Translate cell type names
combined_result_df <- combined_result_df %>% 
    dplyr::inner_join(translation_df) %>% 
    dplyr::select(dataset.name, sample.id, cell.type, prediction)

##### MCPcounter example code above ########

# Create the directory the output will go into
dir.create("output")

# Write result into output directory
readr::write_csv(combined_result_df, "output/predictions.csv")
    
