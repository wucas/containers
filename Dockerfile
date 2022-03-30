# stable or latest
#ARG STABLE_OR_LATEST=stable
# full or minimal
#ARG CONTAINER_VERSION=full
# the base image contains all packages that are necessary to compile GAP
# and the GAP User
FROM ubuntu:21.10 AS base

LABEL maintainer="The GAP Group <support@gap-system.org>"

ENV DEBIAN_FRONTEND noninteractive

# Prerequisites
RUN    apt-get update -qq \
    && apt-get -qq install -y \
            autoconf \
            autogen \
            automake \
            build-essential \
            cmake \
            curl \
            g++ \
            gcc \
            git \
            libgmp-dev \
            libreadline6-dev \
            libtool \
            m4 \
            sudo \
            unzip \
            wget

# add gap user
RUN    adduser --quiet --shell /bin/bash --gecos "GAP user,101,," --disabled-password gap \
    && adduser gap sudo \
    && chown -R gap:gap /home/gap/ \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && cd /home/gap \
    && touch .sudo_as_admin_successful

ENV LD_LIBRARY_PATH /usr/local/lib:${LD_LIBRARY_PATH}

# Set up new user and home directory in environment.
USER gap
ENV HOME /home/gap

# Note that WORKDIR will not expand environment variables in docker versions < 1.3.1.
# See docker issue 2637: https://github.com/docker/docker/issues/2637
# Start at $HOME.
WORKDIR /home/gap

# Start from a BASH shell.
CMD ["bash"]


##########################################################################################
# all-deps has all packages installed that are needed to compile all GAP packages
FROM base AS all-deps

LABEL maintainer="The GAP Group <support@gap-system.org>"

ENV DEBIAN_FRONTEND noninteractive

USER root
ENV HOME /home/root

# Prerequisites
RUN    apt-get -qq install -y \
        gcc-multilib \
        libcdd-dev \
        libcurl4-openssl-dev \
        libflint-dev \
        libglpk-dev \
        libgmpxx4ldbl \
        libmpc-dev \
        libmpfi-dev \
        libmpfr-dev \
        libncurses5-dev \
        libntl-dev \
        libxml2-dev \
        libzmq3-dev \
        libx11-dev \
        libxaw7-dev \
        libxt-dev

USER gap
ENV HOME /home/gap


##########################################################################################
# intermediary stage with only core gap compiled
FROM base AS gap-only-minimal-stable

LABEL maintainer="The GAP Group <support@gap-system.org>"

ARG GAP_VERSION
ARG DEBUG

# download and build GAP
RUN    mkdir /home/gap/inst/ \
    && cd /home/gap/inst/ \
    && wget https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/gap-${GAP_VERSION}-core.zip \
    && unzip gap-${GAP_VERSION}-core.zip \
    && rm gap-${GAP_VERSION}-core.zip \
    && cd gap-${GAP_VERSION} \
    && ./autogen.sh \
    && if [[ "DEBUG" -eq 0 ]] ; then ./configure ; else ./configure --enable-debug ; fi\
    && make \
    && cp bin/gap.sh bin/gap


##########################################################################################
# intermediary stage with only core gap compiled
FROM all-deps AS gap-only-full-stable

LABEL maintainer="The GAP Group <support@gap-system.org>"

ARG GAP_VERSION
ARG DEBUG

# download and build GAP
RUN    mkdir /home/gap/inst/ \
    && cd /home/gap/inst/ \
    && wget https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/gap-${GAP_VERSION}-core.zip \
    && unzip gap-${GAP_VERSION}-core.zip \
    && rm gap-${GAP_VERSION}-core.zip \
    && cd gap-${GAP_VERSION} \
    && ./autogen.sh \
    && if [[ "DEBUG" -eq 0 ]] ; then ./configure ; else ./configure --enable-debug ; fi\
    && make \
    && cp bin/gap.sh bin/gap


##########################################################################################
# intermediary stage with only core gap compiled
FROM base AS gap-only-minimal-latest

LABEL maintainer="The GAP Group <support@gap-system.org>"

ARG GAP_VERSION
ARG DEBUG

# download and build GAP
RUN    mkdir /home/gap/inst/ \
    && cd /home/gap/inst/ \
    && git clone --depth=1 -b ${GAP_VERSION} https://github.com/gap-system/gap gap-${GAP_VERSION} \
    && cd gap-${GAP_VERSION} \
    && ./autogen.sh \
    && if [[ "DEBUG" -eq 0 ]] ; then ./configure ; else ./configure --enable-debug ; fi \
    && make \
    && cp bin/gap.sh bin/gap


##########################################################################################
# intermediary stage with only core gap compiled
FROM all-deps AS gap-only-full-latest

LABEL maintainer="The GAP Group <support@gap-system.org>"

ARG GAP_VERSION
ARG DEBUG

# download and build GAP
RUN    mkdir /home/gap/inst/ \
    && cd /home/gap/inst/ \
    && git clone --depth=1 -b ${GAP_VERSION} https://github.com/gap-system/gap gap-${GAP_VERSION} \
    && cd gap-${GAP_VERSION} \
    && ./autogen.sh \
    && if [[ "DEBUG" -eq 0 ]] ; then ./configure ; else ./configure --enable-debug ; fi \
    && make \
    && cp bin/gap.sh bin/gap


##########################################################################################
# download and build GAP with only necessary packages
FROM gap-only-minimal-stable AS gap-minimal-stable

LABEL maintainer="The GAP Group <support@gap-system.org>"

ARG GAP_VERSION

# download and build required GAP packages
RUN    mkdir /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && cd /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && wget -q https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/packages-required-v${GAP_VERSION}.zip \
    && unzip packages-required-v${GAP_VERSION}.zip \
    && rm packages-required-v${GAP_VERSION}.zip 

ENV GAP_HOME /home/gap/inst/gap-${GAP_VERSION}
ENV PATH ${GAP_HOME}/bin:${PATH}


##########################################################################################
# downloads and compiles GAP and all its packages
FROM gap-only-full-stable AS gap-full

LABEL maintainer="The GAP Group <support@gap-system.org>"
#
ARG GAP_VERSION

# download and build all GAP packages
RUN    mkdir /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && cd /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && wget https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/packages-v${GAP_VERSION}.tar.gz \
    && tar xzf packages-v${GAP_VERSION}.tar.gz \
    && rm  packages-v${GAP_VERSION}.tar.gz \
    && ../bin/BuildPackages.sh --parallel

ENV GAP_HOME /home/gap/inst/gap-${GAP_VERSION}
ENV PATH ${GAP_HOME}/bin:${PATH}


##########################################################################################
# add GAPDoc and latex
FROM gap-minimal AS gap-doc

LABEL maintainer="The GAP Group <support@gap-system.org>"

ARG GAP_VERSION

# do stuff here























##########################################################################################
# download and build GAP with only necessary packages
FROM base AS minimal-stable

LABEL maintainer="The GAP Group <support@gap-system.org>"

ARG GAP_VERSION

# download and build GAP
RUN    mkdir /home/gap/inst/ \
    && cd /home/gap/inst/ \
    && wget https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/gap-${GAP_VERSION}-core.zip \
    && unzip gap-${GAP_VERSION}-core.zip \
    && rm gap-${GAP_VERSION}-core.zip \
    && cd gap-${GAP_VERSION} \
    && ./autogen.sh \
    && ./configure \
    && make \
    && cp bin/gap.sh bin/gap

# download and build required GAP packages
RUN    mkdir /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && cd /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && wget -q https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/packages-required-v${GAP_VERSION}.zip \
    && unzip packages-required-v${GAP_VERSION}.zip \
    && rm packages-required-v${GAP_VERSION}.zip 

ENV GAP_HOME /home/gap/inst/gap-${GAP_VERSION}
ENV PATH ${GAP_HOME}/bin:${PATH}


##########################################################################################
# downloads and compiles GAP and all its packages
FROM all-deps AS full-stable

LABEL maintainer="The GAP Group <support@gap-system.org>"

ARG GAP_VERSION

# download and build GAP
RUN    mkdir /home/gap/inst/ \
    && cd /home/gap/inst/ \
    && wget https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/gap-${GAP_VERSION}-core.tar.gz \
    && tar xzf gap-${GAP_VERSION}-core.tar.gz \
    && rm gap-${GAP_VERSION}-core.tar.gz \
    && cd gap-${GAP_VERSION} \
    && ./autogen.sh \
    && ./configure \
    && make \
    && cp bin/gap.sh bin/gap

# download and build all GAP packages
RUN    mkdir /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && cd /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && wget https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/packages-v${GAP_VERSION}.tar.gz \
    && tar xzf packages-v${GAP_VERSION}.tar.gz \
    && rm  packages-v${GAP_VERSION}.tar.gz \
    && ../bin/BuildPackages.sh --parallel

ENV GAP_HOME /home/gap/inst/gap-${GAP_VERSION}
ENV PATH ${GAP_HOME}/bin:${PATH}


##########################################################################################
