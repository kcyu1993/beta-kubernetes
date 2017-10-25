FROM ubuntu:16.04
MAINTAINER Kaicheng Yu <kaicheng.yu@epfl.ch>

RUN "sh" "-c" "echo nameserver 8.8.8.8 >> /etc/resolv.conf"

##########################
#####  Docmuemts #########
##########################

# Build a minimum enviornment with the correct settings

############ user: root permission
USER root


# Pick up some dependencies (for tensorflow only)
RUN apt-get update && apt-get install -y --no-install-recommends \
        locales \
        build-essential \
        curl \
        libfreetype6-dev \
        libjpeg-turbo8-dev \
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
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen


############# Configure environment #######################################
ENV SHELL=/bin/bash \
    NB_USER=kyu \
    NB_UID=168151 \
    NB_GID=11166 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV HOME=/home/$NB_USER

# Create user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
ADD fix-permissions /usr/local/bin/fix-permissions
RUN chmod +x /usr/local/bin/fix-permissions
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    echo "${NB_USER}:${NB_USER}" | chpasswd && \
    usermod -aG sudo,adm ${NB_USER} && \
    fix-permissions $HOME

############ user: root permission ##############################
USER root

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

############ user: user permission ##############################
USER $NB_USER
WORKDIR $HOME

