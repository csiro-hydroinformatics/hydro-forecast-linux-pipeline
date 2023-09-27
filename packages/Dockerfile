# FROM debian:bullseye-slim
# FROM debian:bullseye-20220711-slim
FROM ubuntu:22.04

LABEL au.csiro.image.authors="per202@csiro.au"

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Canberra
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


ARG CURRENT_UID_ARG
ENV CURRENT_UID=${CURRENT_UID_ARG}

WORKDIR /internal

COPY ./entrypoint.sh /internal
COPY ./build_debian_pkgs.sh /internal
COPY ./build_python_pkgs.sh /internal
COPY ./build_r_pkgs.sh /internal

# NOTE
# parallel make to build swift C++
# placing early to make it obvious, in case this needs adjustment for the pipeline build
# ENV MAKE_CMD="make -j 6"

RUN apt-get update && apt-get install -y \
  git \
  ssh-client \
  cmake \
  catch \
  g++ \
  nano \
  p7zip-full \
  curl \
  libboost-system-dev \
  libboost-date-time-dev \
  libboost-regex-dev \
  libboost-filesystem-dev \
  libboost-graph-dev \
  libboost-thread-dev \
  libtbb-dev \
  libnetcdf-dev \
  libudunits2-dev \
  libeigen3-dev \
  libyaml-cpp-dev \
  libjsoncpp-dev \
  r-cran-knitr \
  r-cran-lubridate \
  r-cran-zoo \
  r-cran-xts \
  r-cran-ggplot2 \
  r-cran-dplyr \
  r-cran-mvtnorm \
  r-cran-plyr \
  r-cran-ncdf4 \
  r-cran-udunits2 \
  r-cran-igraph \
  r-cran-roxygen2 \
  r-cran-markdown \
  r-cran-stringr \
  r-cran-devtools \
  r-cran-readr \
  r-cran-tibble \
  r-cran-cpp11 \
  r-cran-rlang \
  r-cran-tidyselect \
  r-cran-lifecycle \
  r-cran-pillar \
  r-cran-viridis \
  r-cran-viridislite \
  r-cran-gridextra \
  r-cran-downloader \
  r-cran-htmltools \
  r-cran-glue \
  pandoc \
  pandoc-citeproc \
  python3 \
  python3-venv\
  python3-pip \
  dh-make  \
  equivs \
  devscripts  \
  dh-cmake 


# Ubuntu packaging seems to require some of these explicitely: 

RUN apt-get install -y \
  libtbb2 \
  libnetcdf19 \
  libyaml-cpp0.7 \
  libyaml-0-2 

RUN ls -l /usr/lib/x86_64-linux-gnu/libtbb*

ENTRYPOINT ["./entrypoint.sh"]
