library(rjson)
library(readr)
library(tidyr)
library(dplyr)
library(magrittr)
library(stringr)

source("/usr/local/bin/validation_functions.R")


args = commandArgs(trailingOnly=TRUE)
SUBMISSION_FILE <- args[1]
VALIDATION_FILE <- args[2]
JSON_FILE       <- args[3]


json <- get_submission_status_json(SUBMISSION_FILE, VALIDATION_FILE)
write(json, JSON_FILE)
