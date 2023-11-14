FROM hydrofc/ubuntu-jammy-202310:20231025 

LABEL au.csiro.image.authors="jean-michel.perraud@csiro.au"
LABEL maintainer="J-M <jean-michel.perraud@csiro.au>"
LABEL product="Ubuntu Jammy image used for CI pipeline for streamflow forecasting"
LABEL version="0.1"

USER root

ARG CURRENT_UID_ARG
ENV CURRENT_UID=${CURRENT_UID_ARG}

WORKDIR /internal

COPY ./entrypoint.sh /internal
COPY ./build_debian_pkgs.sh /internal
COPY ./bash_functions /internal
COPY ./test_native_libraries.sh /internal
COPY ./build_python_pkgs.sh /internal
COPY ./build_r_pkgs.sh /internal

# NOTE
# parallel make to build swift C++
# placing early to make it obvious, in case this needs adjustment for the pipeline build
# 2 cores I think on azure devops
ENV MAKE_CMD="make -j 2"

ENTRYPOINT ["./entrypoint.sh"]
