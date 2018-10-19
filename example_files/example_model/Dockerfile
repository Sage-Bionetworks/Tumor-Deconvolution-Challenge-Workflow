## Start from this Docker image
FROM ubuntu

## Install R in Docker image
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y r-base

## Install R packages in Docker image
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("plyr")'
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('readr')"

## Copy your files into Docker image
COPY run_model.R /usr/local/bin/
RUN chmod a+x /usr/local/bin/run_model.R

## Make Docker container executable
ENTRYPOINT ["Rscript", "/usr/local/bin/run_model.R"]

