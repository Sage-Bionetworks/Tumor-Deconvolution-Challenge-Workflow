library(readr)

input_df <- read_csv("/input/input.csv")

sample_string <- "GSM971958, GSM971959, GSM971960, GSM971961, GSM971962, GSM971964, GSM971967, GSM971968, GSM971969, GSM971970, GSM971971, GSM971972, GSM971974, GSM971979, GSM971980, GSM971982, GSM971983, GSM971984, GSM971987, GSM971992, GSM971996, GSM971997, GSM972000, GSM972004, GSM972005, GSM972006, GSM972008, GSM972010, GSM972011, GSM972012, GSM972013, GSM972015, GSM972016"

samples <- unlist(strsplit(sample_string, ", "))

output_df <- data.frame(
    cell_type = c("CD3", "CD8", "Cytotoxic_lymphocytes", "Macrophages", "Monocytic_lineage", "T_cells")
)

for(sample in samples){
    output_df[,sample] <- runif(6)
}
    
write_csv(output_df, "/output/predictions.csv")