# Source from https://rentry.org/kretard
FROM nvidia/cuda:11.4.3-cudnn8-devel-ubuntu20.04

# COPIED FROM https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/debian/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    git \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    mercurial \
    openssh-client \
    procps \
    subversion \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH

# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=py39_4.12.0

RUN set -x && \
    UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
    SHA256SUM="78f39f9bae971ec1ae7969f0516017f2413f17796670f7040725dd83fcff5689"; \
    elif [ "${UNAME_M}" = "s390x" ]; then \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-s390x.sh"; \
    SHA256SUM="ff6fdad3068ab5b15939c6f422ac329fa005d56ee0876c985e22e622d930e424"; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-aarch64.sh"; \
    SHA256SUM="5f4f865812101fdc747cea5b820806f678bb50fe0a61f19dc8aa369c52c4e513"; \
    elif [ "${UNAME_M}" = "ppc64le" ]; then \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-ppc64le.sh"; \
    SHA256SUM="1fe3305d0ccc9e55b336b051ae12d82f33af408af4b560625674fa7ad915102b"; \
    fi && \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy
#---

RUN conda init bash

# install socat to proxy internal port to attach to 0.0.0.0 so it can be exposed to the host from the docker container
RUN apt-get update && apt-get install -q -y --no-install-recommends socat && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN echo "Cloning Project" && git clone https://github.com/hlky/stable-diffusion/ .

RUN mkdir -p ./models/ldm/stable-diffusion-v1/

RUN ln -s /models/SDv1.4.ckpt /app/models/ldm/stable-diffusion-v1/model.ckpt

RUN echo "Downloading Arial Font for image matrix" && wget -O ./scripts/arial.ttf https://github.com/matomo-org/travis-scripts/raw/master/fonts/Arial.ttf

RUN echo "Creating python environment" && conda env create -f environment.yaml

RUN ln -s /models/GFPGANv1.3.pth /app/src/gfpgan/experiments/pretrained_models/GFPGANv1.3.pth

EXPOSE 7860

COPY --chmod=0755 entrypoint.sh /app/

# fix arial.ttf loading in webui script
RUN sed -i -- 's/arial\.ttf/\/app\/scripts\/arial\.ttf/g' ./scripts/webui.py
# fix colorized font rendering in webgui script (removes color)
RUN sed -i -- 's/\\u0336//g' ./scripts/webui.py

# symlink to mount outputs to host
RUN mkdir -p /outputs/ && ln -s /outputs/ /app/outputs

CMD /bin/bash -C entrypoint.sh
