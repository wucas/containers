FROM gap-base:testv0.5

LABEL maintainer="The GAP Group <support@gap-system.org>"

ENV DEBIAN_FRONTEND noninteractive

# Prerequisites
RUN    apt-get -qq install -y \
        libcurl4-gnutls-dev \
        gcc-multilib \
        libboost-dev \
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
        libzmq3-dev 