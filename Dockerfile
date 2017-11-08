FROM debian

RUN apt-get update && apt-get install build-essential curl -y

RUN curl -sSL https://get.haskellstack.org/ | sh

WORKDIR /root

COPY . /root/

RUN ./Shakefile.hs package