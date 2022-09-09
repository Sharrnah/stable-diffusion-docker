FROM nvidia/cuda:11.4.3-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
    ca-certificates \
    git \
    libglib2.0-0 \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget -O ~/miniconda.sh -q --show-progress --progress=bar:force https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# initialize conda
RUN conda init bash

# install socat to proxy internal port to attach to 0.0.0.0 so it can be exposed to the host from the docker container
RUN apt-get update && apt-get install -q -y --no-install-recommends socat && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN echo "Cloning Project" && git clone https://github.com/sd-webui/stable-diffusion-webui.git .

# link stable diffusion model v1.4
RUN mkdir -p ./models/ldm/stable-diffusion-v1/
RUN ln -s /models/SDv1.4.ckpt /app/models/ldm/stable-diffusion-v1/model.ckpt

# Install font for prompt matrix
RUN mkdir -p /usr/share/fonts/truetype/ && cp ./data/DejaVuSans.ttf /usr/share/fonts/truetype/

RUN echo "Creating python environment" && conda env create -f environment.yaml

# link to Face Correction Model FPGGANv1.3
RUN ln -s /models/GFPGANv1.3.pth /app/src/gfpgan/experiments/pretrained_models/GFPGANv1.3.pth

# link to Upscaling Model RealESRGAN x4plus
RUN ln -s /models/RealESRGAN_x4plus.pth /app/src/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus.pth
RUN ln -s /models/RealESRGAN_x4plus_anime_6B.pth /app/src/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus_anime_6B.pth

# Add latent-diffusion
RUN echo "Adding Latent-Diffusion" && git clone https://github.com/Hafiidz/latent-diffusion.git /app/src/latent-diffusion && \
    mkdir -p /app/src/latent-diffusion/experiments/pretrained_models/ && \
    wget -O /app/src/latent-diffusion/experiments/pretrained_models/project.yaml -q --show-progress --progress=bar:force https://heibox.uni-heidelberg.de/f/31a76b13ea27482981b4/?dl=1 && \
    ln -s /models/LDSR.ckpt /app/src/latent-diffusion/experiments/pretrained_models/model.ckpt

EXPOSE 7860

COPY entrypoint.sh /app/
RUN chmod 0755 /app/entrypoint.sh

# symlink to mount outputs to host
RUN mkdir -p /outputs/ && ln -s /outputs/ /app/outputs

# Set RUN_MODE (possible options inside example.env)
ENV RUN_MODE=false
# Set to enable/disable automatic restart of WebUI
ENV WEBUI_RELAUNCH=true

CMD /bin/bash -C entrypoint.sh
