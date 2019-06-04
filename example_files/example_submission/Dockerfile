## Start from this Docker image
FROM rocker/tidyverse:3.6.0

## Install R packages in Docker image
RUN Rscript -e "library(devtools);devtools::install_github('ebecht/MCPcounter', ref = 'a79614eee002c88c64725d69140c7653e7c379b4', subdir = 'Source')"

## Copy your files into Docker image
COPY bin/mcpcounter.R /usr/local/bin/

## Make script executable
RUN chmod a+x /usr/local/bin/mcpcounter.R

## Make Docker container executable
ENTRYPOINT ["Rscript", "/usr/local/bin/mcpcounter.R"]

