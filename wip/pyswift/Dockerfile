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
# COPY ./build_debian_pkgs.sh /internal
# COPY ./build_python_pkgs.sh /internal
COPY ./pkgs/*.deb /internal/
COPY ./pkgs/*.whl /internal/

RUN apt-get update && apt-get install -y \
  git \
  ssh-client \
  # cmake \
  # catch \
  # g++ \
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
  python3 \
  python3-venv\
  python3-pip

RUN apt-get install -y libyaml-0-2

RUN cd /internal
RUN dpkg -i `ls libmoirai_*_amd64.deb`
RUN dpkg -i `ls libmoirai-dev_*_amd64.deb`
RUN dpkg -i `ls libcinterop-dev_*_amd64.deb`
RUN dpkg -i `ls libboost-threadpool-dev_*_amd64.deb`
RUN dpkg -i `ls libwila-dev_*_amd64.deb `
RUN dpkg -i `ls libsfsl-dev_*_amd64.deb`
RUN dpkg -i `ls libuchronia_*_amd64.deb `
RUN dpkg -i `ls libuchronia-dev_*_amd64.deb `
RUN dpkg -i `ls libswift_*_amd64.deb `
RUN dpkg -i `ls libswift-dev_*_amd64.deb `

#########################################
### TODO: at this point we could have an intermediary image.
#########################################

# ***** Build python-swift stack *****

# Install jupyter python environment
# This assumes we are already running in the python venv setup by easi-dask

# Dont know why this is not reflecting the default ARG statements at the beginning of the file. Nothing if not defined as ENV. 
# workaround for now
ENV PIP_EXTRA_ARGS=""
ENV APT_CACHE_IP=""
ENV APT_CACHE_PROXY=false
# ENV CONSTRAINTS="constraints.txt"
ENV py_env_path=/env
ENV WITH_GPU=false

ENV PATH=${py_env_path}/bin:$PATH

RUN mkdir -p /conf
# COPY ./${CONSTRAINTS} /conf/constraints.txt

RUN echo py_env_path=${py_env_path} \
  && mkdir -p ${py_env_path} \
  && python3 -m venv ${py_env_path} && \
  ${py_env_path}/bin/python -m pip install ${PIP_EXTRA_ARGS} -U pip wheel wheel twine six pytest setuptools camels-aus 

RUN cd /internal
RUN ${py_env_path}/bin/python -m pip install ${PIP_EXTRA_ARGS} refcount-*.whl
RUN ${py_env_path}/bin/python -m pip install ${PIP_EXTRA_ARGS} cinterop-*.whl
RUN ${py_env_path}/bin/python -m pip install ${PIP_EXTRA_ARGS} uchronia-*.whl
RUN ${py_env_path}/bin/python -m pip install ${PIP_EXTRA_ARGS} swift2-*.whl

# ***** End build python-swift stack *****

#########################################
### TODO: at this point we could have an intermediary image.
#########################################


#######################
# # ! Only use this for local builds as the it will be enabled in the image permanently
# RUN if $APT_CACHE_PROXY; then echo "Enabling apt cache proxy" && apt-get update && apt-get install -y squid-deb-proxy-client \
#   && echo "Acquire::http::Proxy \"http://${APT_CACHE_IP}:8000\";" > /etc/apt/apt.conf.d/30autoproxy; sed -i -e 's/http:\/\/archive\.ubuntu\.com\//http:\/\/au\.archive\.ubuntu\.com\//' /etc/apt/sources.list; fi
# LABEL maintainer="CSIRO EASI Jupyter <Robert.Woodcock@csiro.au>"

USER root

RUN apt-get install -y curl

# Install newer node the nodejs package includes npm. This runs apt-get update, but doesn't install
# includes helpers for R and the R install
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get install -y --fix-missing --no-install-recommends \
  nodejs \
  && apt-get install -y --fix-missing --no-install-recommends pandoc texlive-xetex texlive-fonts-recommended texlive-latex-recommended \
  && apt-get install -y --fix-missing --no-install-recommends software-properties-common dirmngr \
	# && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
  && rm -rf /var/lib/apt/lists/*


RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install tslib for holoviews and bokeh et al
RUN npm install --save tslib

RUN . ${py_env_path}/bin/activate

COPY requirements-jupyter-singleserver.txt /conf/

RUN echo "Building python environment: Jupyter Labs" \
  && which pip \
  && pip install --no-cache-dir \
  --no-build-isolation \
  --requirement=/conf/requirements-jupyter-singleserver.txt
  #-c /conf/constraints.txt

RUN rm -rf /root/.cache/pip \
  && echo done

RUN echo "Adding jupyter lab extensions" \
  && jupyter labextension install --no-build ipyevents \
  && jupyter lab build \
  && jupyter labextension list \
  && echo "...done"

RUN jupyter notebook --generate-config

ARG nb_user=jovyan
ARG nb_uid=1000
ARG nb_gid=100

# Configure environment
ENV SHELL=/bin/bash \
  NB_USER=$nb_user \
  NB_UID=$nb_uid \
  NB_GID=$nb_gid \
  HOME=/home/$nb_user \
  PY_ENV_PATH=$py_env_path

# Add a script that we will use to correct permissions after running certain commands
ADD jupyter-singleserver/fix-permissions /usr/local/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

RUN useradd -m -s /bin/bash -N -g $nb_gid -u $nb_uid $nb_user

# WARNING NOTE: just by inference and stackoverflow. No clear understanding of this.
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

COPY with_bootstrap /bin/

USER $nb_uid

ENV PATH=$HOME/.local/bin:$PATH
ENV LC_ALL=C.UTF-8
ENV SHELL=bash

EXPOSE 8888

ENTRYPOINT ["/tini", "-s", "--", "with_bootstrap"]

ENV JUPYTER_ENABLE_LAB=Yes
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY jupyter-singleserver/start.sh jupyter-singleserver/start-notebook.sh jupyter-singleserver/start-singleuser.sh /usr/local/bin/
COPY jupyter-singleserver/jupyter_notebook_config.py /etc/jupyter/

USER root

RUN fix-permissions /etc/jupyter/

USER $nb_user
WORKDIR ${HOME}
