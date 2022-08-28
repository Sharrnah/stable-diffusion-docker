# Docker image for Stable Diffusion

## Setup for Windows

- For Windows using WSL2, write a .wslconfig File in your user path with following content:

```ini
[wsl2]
memory=16GB # Limits VM memory in WSL 2 to X GB
processors=4 # Makes the WSL 2 VM use X virtual processors
localhostForwarding=true
```
- You can play with the values if your PC can't handle it.

- Install Docker Desktop for Windows

- Make sure you are running the newest NVIDIA Drivers and newest Docker Desktop Version.
  - See https://docs.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl for more information about WSL support.
    
    (all newer Driver and Docker versions should support it out of the box.)

    Test with:
    > `wsl cat /proc/version`
    
    Needs kernel version of 5.10.43.3 or higher.

## Installation

### With Docker
- Build image yourself with:
  > `docker build -t stable-diffusion-guitard .`

- Run prebuild image with:
  ```console
  docker run -d --gpus all -p 7860:8080 -v ./.cache/app:/root/.cache -v ./.cache/facexlib/:/opt/conda/envs/ldm/lib/python3.8/site-packages/facexlib/weights/ -v ./models/:/models/:ro -v ./outputs/:/outputs/ -e RUN_MODE=false sharrnah/stable-diffusion-guitard
  ```
  _(replace "`sharrnah/stable-diffusion-guitard`" image name with "`stable-diffusion-guitard`" to run self-build image)_

  change "RUN_MODE" depending on your machine. (see [Options](#options) for more info)

### With Docker Compose _(recommended)_
- Download / Clone this repo.
  
  _(Or just get the docker-compose.yaml file if you want to use the prebuild image and skip "build image yourself" step.)_

- build image yourself and start it with _(only if you want to build image yourself)_:
  > `docker compose -f docker-compose.build.yaml up -d --build`

- start prebuild image with:
  > `docker compose up -d`

- See current logs with:
  > `docker compose logs stablediffusion -f`

- You can exec into the container with:
  > `docker compose exec stablediffusion bash`

## Options
- You can set the environment variable "RUN_MODE" to one of these setting:
  - "`OPTIMIZED`" For reduced Memory mode (sacrificing speed)
  - "`OPTIMIZED-TURBO`" For lesser reduced Memory mode (sacrificing less speed)
  - "`GTX16`" When generated images are green (known problem on GTX 16xx GPUs)
  - "`GTX16-TURBO`" When generated images are green (known problem on GTX 16xx GPUs) [using OPTIMIZED-TURBO]
  - "`FULL-PRECISION`" use full precision

For that you can create a `.env` file and set the content to
```env
RUN_MODE=OPTIMIZED
```
or
```
RUN_MODE=GTX16
```
(See `example.env` file including all possible values)

## Usage
- after the webgui started successfully you should see a log output telling
  ```
  Running on local URL:  http://127.0.0.1:7860/
  ```
  
- See current log with:
  > `docker compose logs stablediffusion -f`
  
- Open http://127.0.0.1:7860/ in your Browser to use it.

- All generated images are saved into the `./outputs/` directory.


## Model Sources

> **Models should be downloaded automatically on first run now!**

### Stable Diffusion Model Download

- Download the v1.4 Stable Diffusion model from one of the following sources:
  - Web:
    
    - https://drive.yerf.org/wl/?id=EBfTrmcCCUAGaQBXVIj5lJmEhjoP1tgl
    
    or

    - https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media
  - Torrent Magnet:
    
    - > `magnet:?xt=urn:btih:3a4a612d75ed088ea542acac52f9f45987488d1c&dn=sd-v1-4.ckpt&tr=udp%3a%2f%2ftracker.openbittorrent.com%3a6969%2fannounce&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337`
  - Hugging face:
    
    - https://huggingface.co/CompVis/stable-diffusion-v1-4

- Place the downloaded model file into the `models/` directory and name it `SDv1.4.ckpt` (**Case-Sensitive**)

### GFPGAN Model Download (Face Correction)
- Download the GFPGAN v1.3.0 model from here:
  - https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth

- Place the downloaded model file into the `models/` directory and name it `GFPGANv1.3.pth` (**Case-Sensitive**)

### RealESRGAN Model Download (Upscaling)
- Download the RealESRGAN x4plus model from here:
  - https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth
- Download the RealESRGAN x4plus anime model from here:
  - https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth

- Place the downloaded model files into the `models/` directory and name them `RealESRGAN_x4plus.pth` and `RealESRGAN_x4plus_anime_6B.pth` (**Case-Sensitive**)


### _Sources:_
- https://rentry.org/GUItard
- https://github.com/hlky/stable-diffusion
