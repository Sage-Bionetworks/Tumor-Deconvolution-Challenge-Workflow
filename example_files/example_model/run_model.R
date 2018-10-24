library(readr)

input_df <- read_csv("/input/input.csv")

    
output_df <- data.frame(
    cell_type = c("tcells","bcells","monocytes", "macrophages"),
    sample1 = c(0.5,0.45,0.0, 1.0),
    sample2 = c(2.0,0.5,0.45,0.0),
    sample3 = c(0.0,1.0, 0.5, 5.0)
)    
    
write_csv(output_df, "/output/predictions.csv")