FROM debian:bullseye

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
  r-cran-lubridate \
  r-cran-zoo \
  r-cran-xts \
  r-cran-ggplot2 \
  r-cran-dplyr \
  r-cran-mvtnorm \
  r-cran-plyr \
  r-cran-ncdf4 \
  r-cran-udunits2 \
  r-cran-roxygen2 \
  r-cran-devtools \ 
  python3 \
  python3-venv\
  python3-pip \
  dh-make  \
  equivs \
  devscripts  \
  dh-cmake 


ENTRYPOINT ["./entrypoint.sh"]
