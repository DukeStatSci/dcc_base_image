FROM fedora:42

RUN dnf install -y langpacks-en glibc-langpack-en glibc-locale-source glibc-common

ENV TZ=America/New_York
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

ENV QUARTO_VERSION="1.7.31"
ENV QUARTO_DIR=/usr/local/quarto
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
    top

# Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v$QUARTO_VERSION/quarto-$QUARTO_VERSION-linux-rhel7-amd64.tar.gz \
 && mkdir -p $QUARTO_DIR \
 && tar xvzf quarto-*-linux-rhel7-amd64.tar.gz -C $QUARTO_DIR --strip-components=1

# R Stuff
RUN dnf copr enable -y iucar/cran \
 && dnf update -y \
 && dnf install -y --setopt='tsflags=' R \
 && dnf install -y \
    R-flexiblas flexiblas-* \
    R-CRAN-tidyverse \
    R-CRAN-devtools \
    R-CRAN-tidymodels \
    R-CRAN-rjags \
    R-CRAN-sf \
    R-CRAN-rstan \
    R-CRAN-brms \
    R-CRAN-bench \
    R-CRAN-countdown \
    R-CRAN-repurrrsive \
    R-CRAN-nycflights13 \
    R-CRAN-palmerpenguins \
    R-CRAN-ggthemes \
    R-CRAN-ggrepel \
    R-CRAN-GGally \
    R-CRAN-datasauRus \
    R-CRAN-ggpmisc \
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
    R-CRAN-reticulate

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
    jax

RUN dnf clean all \
 && rm -rf /var/cache/dnf/*

