FROM fedora:42

RUN dnf install -y langpacks-en glibc-langpack-en glibc-locale-source glibc-common

ENV TZ=America/New_York
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV DISTRO="fedora42"
ENV R_VERSION="4.5.1"
ENV R_SVER="4.5"
ENV QUARTO_VERSION="1.7.32"
ENV QUARTO_DIR=/usr/local/quarto

ENV CODE_SERVER_VERSION="4.102.3"
ENV RSTUDIO_VERSION="2025.05.1-513"

ENV PATH=$QUARTO_DIR/bin:$PATH

# Core & Dev Tools
RUN dnf install -y \
    @development-tools \
    chromium \
    vim \
    nano \
    wget \
    ca-certificates \
    curl-devel \
    openssl-devel \
    gsl-devel \
    llvm \
    llvm-devel \
    htop \
    top \
    flexiblas-* \
    Lmod
    
# Config Lmod for DCC
RUN echo "export MODULEPATH=/opt/apps/modulefiles" > /etc/profile.d/00-modules.sh \
 && echo "setenv MODULEPATH /opt/apps/modulefiles" > /etc/profile.d/00-modules.csh

ENV MODULEPATH=/opt/apps/modulefiles

# Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v$QUARTO_VERSION/quarto-$QUARTO_VERSION-linux-rhel7-amd64.tar.gz \
 && mkdir -p $QUARTO_DIR \
 && tar xvzf quarto-*-linux-rhel7-amd64.tar.gz -C $QUARTO_DIR --strip-components=1 \
 && rm -f quarto-*-linux-rhel7-amd64.tar.gz

# R Stuff
RUN dnf copr enable -y iucar/cran \
 && dnf update -y \
 && dnf install -y --setopt='tsflags=' R \
 && dnf install -y \
    R-flexiblas \
    R-CRAN-tidyverse \
    R-CRAN-devtools \
    R-CRAN-tidymodels \
    R-CRAN-rjags \
    R-CRAN-sf \
    R-CRAN-rstan \
    R-CRAN-brms \
    R-CRAN-bench \
    R-CRAN-ggthemes \
    R-CRAN-ggrepel \
    R-CRAN-GGally \
    R-CRAN-polite \
    R-CRAN-here \
    R-CRAN-RSQLite \
    R-CRAN-pryr \
    R-CRAN-tidyquery \
    R-CRAN-sqldf \
    R-CRAN-duckdb \
    R-CRAN-quarto \
    R-CRAN-thematic \
    R-CRAN-doMC \
    R-CRAN-geosphere \
    R-CRAN-leaflet \
    R-CRAN-lwgeom \
    R-CRAN-rstanarm \
    R-CRAN-DAAG \
    R-CRAN-broom.mixed \
    R-CRAN-glmnet \
    R-CRAN-gt \
    R-CRAN-reticulate \
    R-CRAN-quarto \
    R-CRAN-chromote \
    R-CRAN-reticulate \
    R-CRAN-tidybayes \
    R-CRAN-R2jags \
    R-CRAN-BAS \
    R-CRAN-spBayes \
    R-CRAN-magick \
    R-CRAN-gsl \
    R-CRAN-fable \
    R-CRAN-feasts \
    R-CRAN-tsibbledata \
    R-CRAN-fable.prophet \
    R-CRAN-tsibbletalk \
    R-CRAN-RMySQL \
    R-CRAN-RODBC \
    R-CRAN-RPostgres \
    R-CRAN-RPostgreSQL \
    R-CRAN-RSQLite \
    R-CRAN-data.table \
    R-CRAN-dtplyr \
    R-CRAN-torch \
    R-CRAN-brulee \
    R-CRAN-luz \
    R-CRAN-keras \
    R-CRAN-shiny \
    R-CRAN-bslib

COPY conf/Rprofile.site /usr/lib64/R/etc/Rprofile.site

# R: Site ENV - Add Timezone
RUN echo "TZ='$TZ'" >> /usr/lib64/R/etc/Renviron \
 && sed -i "/^R_PLATFORM=/ c\R_PLATFORM=\${R_PLATFORM-'$DISTRO-x86_64-singularity'}" /usr/lib64/R/etc/Renviron \
 && sed -i "/^R_LIBS_USER=/ c\R_LIBS_USER=\${R_LIBS_USER-'~/R/$DISTRO-x86_64-singularity-library/$R_SVER'}" /usr/lib64/R/etc/Renviron \
 && echo "DOWNLOAD_STATIC_LIBV8='1'" >> /usr/lib64/R/etc/Renviron


# Python Stuff
RUN dnf install -y \
    python3 \
    python3-devel \
    uv \
 && uv pip install --system torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
 && uv pip install --system \
    jupyter \
    numpy \
    pandas \
    polars \
    matplotlib \
    scipy \
    seaborn \
    scikit-learn \
    statsmodels \
    patsy \
    pymc \
    jax \
    numpy \
    numpyro \
    blackjax \
    nutpie \
    cmdstanpy[all]

## Julia Stuff

RUN dnf install -y \
    julia


## Install code-server

RUN curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_SERVER_VERSION/code-server-$CODE_SERVER_VERSION-amd64.rpm \
 && dnf install -y code-server-$CODE_SERVER_VERSION-amd64.rpm \
 && rm -f code-server-$CODE_SERVER_VERSION-amd64.rpm

## Install rstudio

RUN wget https://download2.rstudio.org/server/rhel9/x86_64/rstudio-server-rhel-${RSTUDIO_VERSION}-x86_64.rpm \
 && dnf install -y rstudio-server-rhel-${RSTUDIO_VERSION}-x86_64.rpm \
 && rm -f rstudio-server-rhel-${RSTUDIO_VERSION}-x86_64.rpm


## Install Jupyter kernels

### R (ark) kernel

RUN wget https://github.com/posit-dev/ark/releases/download/0.1.184/ark-0.1.184-linux-x64.zip \
 && unzip -j "ark-*.zip" "ark" -d "/usr/local/bin"\
 && rm -f ark-*.zip\
 && ark --install \
 && cp -r /root/.local/share/jupyter/kernels/ark /usr/local/share/jupyter/kernels/ \
 && rm -rf /root/.local/

### R (IR) kernel
RUN dnf install -y R-CRAN-IRkernel \
 && Rscript -e "IRkernel::installspec(prefix = '/usr/local')"

### Bash kernel
RUN uv pip install --system bash_kernel \
 && JUPYTER_DATA_DIR=/usr/local/share/jupyter python3 -m bash_kernel.install

### Install Julia kernel system-wide
RUN julia -e 'using Pkg; Pkg.add("IJulia")' \
 && JUPYTER_DATA_DIR=/usr/local/share/jupyter julia -e 'using IJulia; IJulia.installkernel("Julia")'


RUN dnf clean all \
 && rm -rf /var/cache/dnf/*
