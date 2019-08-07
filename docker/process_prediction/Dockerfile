FROM rocker/tidyverse:3.6.1

RUN Rscript -e "install.packages('argparse')"
RUN Rscript -e "install.packages('rjson')"

COPY bin/*.R /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.R
