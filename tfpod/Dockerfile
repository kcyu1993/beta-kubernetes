FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04
MAINTAINER Kaicheng Yu <kaicheng.yu@epfl.ch>

RUN "sh" "-c" "echo nameserver 8.8.8.8 >> /etc/resolv.conf"

##########################
#####  Docmuemts #########
##########################

# Build a a light environment with the correct user access to cvlabdata3
# No root access originally, can sudo to get it
# Create to support k8s deployment and pod commmand
# Hope it can work!

############ user: root permission
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

RUN pip --no-cache-dir install \
        Pillow==3.4.2 \
        h5py \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        pandas \
        scipy \
        sklearn \
        && \
    python -m ipykernel.kernelspec

###########################################################################
### Add for keras implementation, may change from code to code
###########################################################################
# Install the cpu version of tensorflow
RUN pip --no-cache-dir install \
        tensorflow \
        && \
    python -m ipykernel.kernelspec


RUN pip install \
        configobj \
        pyyaml \
        && \
    python -m ipykernel.kernelspec


# --- DO NOT EDIT OR DELETE BETWEEN THE LINES --- #
# These lines will be edited automatically by parameterized_docker_build.sh. #
# COPY _PIP_FILE_ /
# RUN pip --no-cache-dir install /_PIP_FILE_
# RUN rm -f /_PIP_FILE_

# Install TensorFlow GPU version.
RUN pip --no-cache-dir install tensorflow-gpu \
    python -m ipykernel.kernelspec
#    http://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-0.0.0-cp27-none-linux_x86_64.whl
# --- ~ DO NOT EDIT OR DELETE BETWEEN THE LINES --- #



############# Configure environment #######################################
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

# Create user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
ADD fix-permissions /usr/local/bin/fix-permissions
RUN chmod +x /usr/local/bin/fix-permissions
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    echo "${NB_USER}:${NB_USER}" | chpasswd && \
    usermod -aG sudo,adm ${NB_USER} && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

############ user: user permission
USER $NB_USER

# Setup work directory for backward-compatibility
RUN mkdir $HOME/notebooks && fix-permissions $HOME

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME $HOME/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions $HOME



############ user: root permission ##############################
USER root
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

# Fix the tty problem


############ user: user permission ##############################
USER $NB_USER

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
