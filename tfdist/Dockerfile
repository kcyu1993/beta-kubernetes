FROM docker.io/kcyu2014/k8s-masterpiece:tfpod-v1

MAINTAINER Kaicheng Yu <kaicheng.yu@epfl.ch>

# Add the distributed enviornment
USER root


# Locale update
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    bzip2 \
    locales \
    fonts-liberation \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Pick up the dependencies for horovod
RUN apt-get update && apt-get install -y --no-install-recommends \
        # For distributed tensorflow framework, install NCCL2
        libnccl2 \
        libnccl-dev \
        gosu \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# compile and install OpenMPI
COPY openmpi-3.0.0.tar.gz /root/
WORKDIR /root/
RUN gunzip -c openmpi-3.0.0.tar.gz | tar xf -  && \
    cd openmpi-3.0.0 && \
    chmod +x configure && \
    ./configure --with-cuda --prefix=/usr/local && \
    make all install && \
    ldconfig \




