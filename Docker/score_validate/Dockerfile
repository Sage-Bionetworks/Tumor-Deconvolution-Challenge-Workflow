## Start from this Docker image
FROM ubuntu

## Install R in Docker image
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y r-base

## Install R packages in Docker image
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('rjson')"
RUN Rscript -e "install.packages('readr')"
RUN Rscript -e "install.packages('tidyr')"
RUN Rscript -e "install.packages('dplyr')"
RUN Rscript -e "install.packages('magrittr')"
RUN Rscript -e "install.packages('stringr')"
RUN Rscript -e "install.packages('tibble')"

## Copy your files into Docker image
COPY *.R /usr/local/bin/
RUN chmod a+x /usr/local/bin/*
ENV PATH /opt/rnaseqSim/fusion_create:$PATH


