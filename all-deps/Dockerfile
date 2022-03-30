FROM gap-base:testv0.6

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