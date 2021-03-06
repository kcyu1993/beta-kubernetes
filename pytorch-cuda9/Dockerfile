FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
MAINTAINER Kaicheng Yu <kaicheng.yu@epfl.ch>

RUN "sh" "-c" "echo nameserver 8.8.8.8 >> /etc/resolv.conf"

##########################
#####  Docmuemts #########
##########################

# Build a a light environment with the correct user access to cvlabdata3
# No root access originally, can sudo to get it
# Create to support k8s deployment and pod commmand
# Hope it can work!


#################################################
############ user: root permission ##############
#################################################

USER root

# Pick up some dependencies (for tensorflow only)
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-tk \
        python-dev \
        psmisc \
        rsync \
        software-properties-common \
        vim \
        sudo \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Locale update
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    bzip2 \
    locales \
    fonts-liberation \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

# Python 3.6 Env.
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \

    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \

    apt-get update && \

    # tools
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        ca-certificates \
        cmake \
        wget \
        git \
        && \

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:jonathonf/python-3.6 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3.6 \
        python3.6-dev \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python3.6 ~/get-pip.py && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python && \
    $PIP_INSTALL \
        setuptools \
        && \
    $PIP_INSTALL \
        numpy \
        scipy \
        pandas \
        scikit-learn \
        matplotlib \
        Cython \
        Pillow\
        h5py \
        ipykernel \
        jupyter \
        matplotlib \
        pandas \
        configobj \
        pyyaml \
        pytest \
        && \

# Install Pytorch.
    $PIP_INSTALL \
        http://download.pytorch.org/whl/cu90/torch-0.3.1-cp36-cp36m-linux_x86_64.whl \
        torchvision \
        && \

# Install tensorflow
    $PIP_INSTALL \
        tensorflow \
        tensorflow-gpu \
        && \

# Clean and config
    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*


#################################################
############# Configure environment #############
#################################################
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=kyu \
    NB_UID=168151 \
    NB_GID=11166 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# Create user with UID=NB_UID and in the 'NB_GID' group
# and make sure these dirs are writable by the `NB_GID` group.
ADD fix-permissions /usr/local/bin/fix-permissions
RUN chmod +x /usr/local/bin/fix-permissions
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    echo "${NB_USER}:${NB_USER}" | chpasswd && \
    usermod -aG sudo,adm ${NB_USER} && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

WORKDIR $HOME/notebooks

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*
COPY jupyter_notebook_config.py /etc/jupyter/
RUN fix-permissions /etc/jupyter/

# Configure container startup
# ENTRYPOINT ["tini", "--"]
# CMD ["start-notebook.sh"]


#################################################
############ user: user permission ##############
#################################################
USER $NB_USER

# Setup work directory for backward-compatibility
RUN fix-permissions $HOME

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME $HOME/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions $HOME

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
#COPY notebooks /notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/notebooks"

CMD ["/usr/local/bin/start-notebook.sh", "--allow-root"]

WORKDIR $HOME/
