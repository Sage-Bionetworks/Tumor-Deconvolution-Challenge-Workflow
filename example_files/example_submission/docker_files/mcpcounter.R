
###############################################################################
## This code uses MCPCounter to calculate cell type predictions for
## the coarse-grained sub-Challenge.
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
print(list.files())
print(getwd())
input_df <- readr::read_csv("input/input.csv")

## Extract the names of each dataset
dataset_names <- input_df$dataset.name

## Extract the names of the expression files that use 
## Hugo symbols as gene identifiers
expression_files  <- input_df$hugo.expr.file

## Form the paths of the expression files
expression_paths <- paste0("input/", expression_files)

##### MCPcounter example code below ########

## MCPcounter.estimate (called below) requires two input data frames
## genes: a data frame indicating the gene HUGO symbols and ENTREZ ids of
##        markers of each cell population
## probesets: a data frame indicating the probesets of
##        markers of each cell population
## By default, MCPcounter.estimate would download these via
## probesets=read.table(curl("http://raw.githubusercontent.com/ebecht/MCPcounter/master/Signatures/probesets.txt"),sep="\t",stringsAsFactors=FALSE,colClasses="character")
## genes=read.table(curl("http://raw.githubusercontent.com/ebecht/MCPcounter/master/Signatures/genes.txt"),sep="\t",stringsAsFactors=FALSE,header=TRUE,colClasses="character",check.names=FALSE)

## However, since internet access is disabled for Dokcer images in this
## Challenge, we have instead included them directly in the Docker image.
## Load them from there now.
genes <- as.data.frame(readr::read_csv("genes.csv"))
probesets <- as.data.frame(readr::read_csv("probesets.csv"))

## Create a table that translates the cell types output by
## MCP-Counter ('mcpcounter.cell.type' column) to the cell types
## required of the course-grained sub-Challenge ('cell.type' column).
## Note that MCP-Counter does not predict CD4 T cells. Instead, we have
## mapped MCP-Counter's T cell output as our CD4 T cell prediction.
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

## Execute MCP-Counter against a dataset.
## Assumes that expression_path points to a CSV whose gene identifiers
## are HUGO symbols.
do_mcpcounter <- function(expression_path, dataset_name){
    
    # This reads in the input file and converts to a matrix which will be
    # input to MCPCounter
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

## Run MCP-Counter on each of the expression files
result_dfs <- purrr::map2(expression_paths, dataset_names, do_mcpcounter) 

## Combine all results into one dataframe
combined_result_df <- dplyr::bind_rows(result_dfs)

## Translate cell type names as output from MCP-Counter to those
## required for the coarse-grained sub-Challenge.
combined_result_df <- combined_result_df %>% 
    dplyr::inner_join(translation_df) %>% 
    dplyr::select(dataset.name, sample.id, cell.type, prediction)

##### MCPcounter example code above ########

## Create the directory the output will go into
dir.create("output")

## Write result into output directory
readr::write_csv(combined_result_df, "output/predictions.csv")

print(list.files("output"))
    
