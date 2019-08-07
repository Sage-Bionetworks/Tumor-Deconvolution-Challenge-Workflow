FROM python:3.7.4-stretch

RUN pip3 install synapseclient
RUN pip3 install pandas

COPY bin/* /usr/local/bin/
RUN chmod a+x /usr/local/bin/*
