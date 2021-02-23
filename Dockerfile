FROM rocker/rstudio:4.0.3


LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://github.com/DKMS-LSL/dr2s_tutorial" \
      org.label-schema.vendor="DKMS Life Science Lab" \
      maintainer="Steffen Klasberg <klasberg@dkms-lab.de>"

ENV TOOLS=/tools
ENV SCRIPTS=/scripts

## install prequesites for R packages
RUN apt update \
    && apt install -y \
      build-essential \ 
      gcc \
      autoconf \
      libxml2-dev \
      libssl-dev \
      libz-dev \
      libbz2-dev  \
      liblzma-dev \
      wget \
      libncurses5-dev \
      libxt6
COPY ./install_git.sh $SCRIPTS/
RUN $SCRIPTS/install_git.sh

## Install htslib for samtools
WORKDIR $TOOLS
RUN git clone --recurse-submodules https://github.com/samtools/htslib.git
WORKDIR $TOOLS/htslib
RUN autoheader \    
    && autoconf \     
    && ./configure \ 
    && make \
    && make install

## Install samtools
WORKDIR $TOOLS
RUN git clone https://github.com/samtools/samtools.git
WORKDIR $TOOLS/samtools
RUN autoheader \           
    && autoconf -Wno-syntax  \
    && ./configure \
    && make \
    && make install

## Install bwa
WORKDIR $TOOLS
RUN git clone https://github.com/lh3/bwa.git
WORKDIR $TOOLS/bwa
RUN make \ 
    && cp ./bwa /usr/local/bin

## Install minimap2
WORKDIR $TOOLS
RUN git clone https://github.com/lh3/minimap2.git
WORKDIR $TOOLS/minimap2
RUN make \
    && cp ./minimap2 /usr/local/bin

## Install devtools
RUN Rscript -e "install.packages('devtools')"

## Install DR2S
WORKDIR $TOOLS
RUN git clone  https://github.com/DKMS-LSL/dr2s.git  \
#RUN git clone --branch v1.1.21 https://github.com/DKMS-LSL/dr2s.git  \
    && Rscript -e "devtools::install('./dr2s', quick = FALSE, build = TRUE, dependencies = TRUE, build_vignettes = TRUE)"

## Copy dr2sSample data
COPY --chown=rstudio exampleData /home/rstudio/exampleData
COPY --chown=rstudio exampleProject /home/rstudio/exampleProject
COPY --chown=rstudio rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
WORKDIR /home/rstudio

