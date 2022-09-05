# Docker for Stable Diffusion

## Setup for Windows

- For Windows using WSL2, write a .wslconfig File in your user path with following content:

```ini
[wsl2]
memory=12GB # Limits VM memory in WSL 2 to X GB
processors=3 # Makes the WSL 2 VM use X virtual processors
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
  docker run -d --gpus all -p 7860:8080 -v ./.cache/app:/root/.cache -v ./.cache/facexlib/:/app/src/facexlib/facexlib/weights/ -v ./models/:/models/ -v ./outputs/:/outputs/ -e RUN_MODE=false sharrnah/stable-diffusion-guitard
  ```
  _(replace "`sharrnah/stable-diffusion-guitard`" image name with "`stable-diffusion-guitard`" to run self-build image)_

  change "RUN_MODE" depending on your machine. (see [Options](#options) for more info)

### With Docker Compose _(recommended)_
- Download / Clone this repo.
  
  _(Or just get the docker-compose.yaml file if you want to use the prebuild image and ignore "build image yourself" step.)_

- Start docker-compose project.
  - building image yourself:
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
- Set the environment variable "WEBUI_RELAUNCH" to
  - "`true`" (default) For automatic restarting of the WebUI
  - "`false`" Disables automatic restarting of the WebUI

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

- Find some nice example prompts here:
  - https://lexica.art/

## Model Sources

> **Models should be downloaded automatically on first run now!**

### Stable Diffusion Model Download

| Model            | Function         | Version  | Size   | Local Location (*Case-Sensitive!*)    | Download Source                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|------------------|------------------|----------|--------|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Stable Diffusion | Image Generation | v1.4      | ~4&nbsp;GB  | models/SDv1.4.ckpt                    | Web:<br>https://drive.yerf.org/wl/?id=EBfTrmcCCUAGaQBXVIj5lJmEhjoP1tgl<br>https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media<br>Torrent Magnet:<br>`magnet:?xt=urn:btih:3a4a612d75ed088ea542acac52f9f45987488d1c&dn=sd-v1-4.ckpt&tr=udp%3a%2f%2ftracker.openbittorrent.com%3a6969%2fannounce&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337`<br>Hugging Face:<br>https://huggingface.co/CompVis/stable-diffusion-v1-4 |
| GFPGAN           | Face Correction  | v1.3.0    | 332&nbsp;MB | models/GFPGANv1.3.pth                 | Web:<br>https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth                                                                                                                                                                                                                                                                                                                                                             |
| RealESRGAN       | Upscaling        | v0.1.0    | ~64&nbsp;MB | models/RealESRGAN_x4plus.pth          | Web:<br>https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth                                                                                                                                                                                                                                                                                                                                                    |
| RealESRGAN anime | Upscaling Anime  | v0.2.2.4  | ~17&nbsp;MB | models/RealESRGAN_x4plus_anime_6B.pth | Web:<br>https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth                                                                                                                                                                                                                                                                                                                                         |
| Latent Diffusion | Upscaling, Inpainting | July 2022 | ~2&nbsp;GB | models/LDSR.ckpt                       | Web:<br>https://heibox.uni-heidelberg.de/f/578df07c8fc04ffbadf3/?dl=1                                                                                                                                                                                                                                                                                                                                         |

### _Sources:_
- https://rentry.org/GUItard
- https://github.com/hlky/stable-diffusion
