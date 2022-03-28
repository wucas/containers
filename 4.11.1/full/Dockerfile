FROM gap-base:testv0.5

LABEL maintainer="The GAP Group <support@gap-system.org>"

ENV GAP_VERSION=4.11.1

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

# download and build all GAP packages
RUN    mkdir /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && cd /home/gap/inst/gap-${GAP_VERSION}/pkg \
    && wget https://github.com/gap-system/gap/releases/download/v${GAP_VERSION}/packages-v${GAP_VERSION}.tar.gz \
    && tar xzf packages-v${GAP_VERSION}.tar.gz \
    && rm  packages-v${GAP_VERSION}.tar.gz \
    && ../bin/BuildPackages.sh --parallel

# build JupyterKernel
#RUN    cd /home/gap/inst/gap-${GAP_BRANCH}/pkg \
#    && mv JupyterKernel-* JupyterKernel \
#    && cd JupyterKernel \
#    && pip3 install . --user

#RUN jupyter serverextension enable --py jupyterlab --user

#ENV PATH /home/gap/inst/gap-${GAP_BRANCH}/pkg/JupyterKernel/bin:${PATH}
#ENV JUPYTER_GAP_EXECUTABLE /home/gap/inst/gap-${GAP_BRANCH}/bin/gap.sh

ENV GAP_HOME /home/gap/inst/gap-${GAP_VERSION}
ENV PATH ${GAP_HOME}/bin:${PATH}