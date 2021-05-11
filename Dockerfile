FROM ubuntu:20.10
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y git python3-pip python3.6 pkg-config libtool zlib1g-dev libpng-dev libjpeg-dev libopenjp2-7-dev\
       libtiff-dev libglib2.0-dev libcairo-dev libgdk-pixbuf2.0-dev libxml2-dev libsqlite3-dev

RUN git clone https://github.com/NKI-AI/openslide /tmp/openslide
WORKDIR /tmp/openslide

RUN autoreconf -i
RUN ./configure
RUN make
RUN make install
RUN ldconfig

# uncomment:
    # 1 - this additional RUN only if you are facing issues with UTF8 when running your container
    # 2 - all ENV variables in comment

    #RUN apt-get update -y \
    #    && apt-get install --reinstall -y locales \
    #    # uncomment chosen locale to enable it's generation
    #    && sed -i 's/# pl_PL.UTF-8 UTF-8/pl_PL.UTF-8 UTF-8/' /etc/locale.gen \
    #    # generate chosen locale
    #    && locale-gen pl_PL.UTF-8

    ## set system-wide locale settings 
    #ENV LANG pl_PL.UTF-8
    #ENV LANGUAGE pl_PL
    #ENV LC_ALL pl_PL.UTF-8

RUN cd /opt \
    && git clone https://github.com/NKI-AI/HistoQC.git \
    && pip3 install -r /opt/HistoQC/requirements.txt
WORKDIR /opt/HistoQC

# Useful, e.g. with singularity containers
RUN echo '#!/bin/bash\ncd /opt/HistoQC && python3 qc_pipeline.py "$@"' > /usr/bin/qc_pipeline && \
    chmod +x /usr/bin/qc_pipeline

