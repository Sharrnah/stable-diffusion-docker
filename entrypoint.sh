#!/bin/bash

MODEL_FILES=(
    'SDv1.4.ckpt https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media fe4efff1e174c627256e44ec2991ba279b3816e364b49f9be2abc0b3ff3f8556'
    'GFPGANv1.3.pth https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth c953a88f2727c85c3d9ae72e2bd4846bbaf59fe6972ad94130e23e7017524a70'
    'RealESRGAN_x4plus.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth 4fa0d38905f75ac06eb49a7951b426670021be3018265fd191d2125df9d682f1'
    'RealESRGAN_x4plus_anime_6B.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth f872d837d3c90ed2e05227bed711af5671a6fd1c9f7d7e91c911a61f155e99da'
    'LDSR.ckpt https://heibox.uni-heidelberg.de/f/578df07c8fc04ffbadf3/?dl=1 c209caecac2f97b4bb8f4d726b70ac2ac9b35904b7fc99801e1f5e61f9210c13'
)

validateDownloadModel() {
    local file=$1
    local url=$2
    local hash=$3

    echo "checking if ${file} has hash ${hash}..."
    sha256sum --check --status <<< "${hash} /models/${file}"
    if [[ $? == "1" ]]; then
        echo "Downloading: ${url} please wait..."
        mkdir -p /models/
        wget --output-document=/models/${file} --no-verbose --show-progress --progress=dot:giga ${url}
        echo "saved ${file}"
    else
        echo -e "${file} is valid!\n"
    fi
}

# Validate model files
echo "Validating model files..."
for models in "${MODEL_FILES[@]}"; do
    model=($models)
    validateDownloadModel ${model[0]} ${model[1]} ${model[2]}
done

socat TCP4-LISTEN:8080,fork TCP4:127.0.0.1:7860 &


# Enable textual inversion (because it is not compatible with Latent diffusion currently, its set for opt-in)
if [ "${ENABLE_TEXTUAL_INVERSION}" = "true" ] ; then
  echo "Cloning and installing Textual Inversion (breaks Latent Diffusion Super Resolution!!!)"
  git clone https://github.com/hlky/sd-enable-textual-inversion /tmp/sd-enable-textual-inversion
  cp -ax /tmp/sd-enable-textual-inversion/* /app/ && rm -rf /tmp/sd-enable-textual-inversion
fi

RUN_ARGS=""

if [ "${RUN_MODE}" = "OPTIMIZED" ] ; then
  echo "Running OPTIMIZED mode"
  RUN_ARGS="--gfpgan-cpu --esrgan-cpu --optimized"
elif [ "${RUN_MODE}" = "OPTIMIZED-TURBO" ] ; then
  echo "Running OPTIMIZED-TURBO mode"
  RUN_ARGS="--gfpgan-cpu --esrgan-cpu --optimized-turbo"
elif [ "${RUN_MODE}" = "GTX16" ] ; then
  echo "Running GTX16 mode"
  RUN_ARGS="--precision full --no-half --gfpgan-cpu --esrgan-cpu --optimized"
elif [ "${RUN_MODE}" = "GTX16-TURBO" ] ; then
  echo "Running GTX16-TURBO mode"
  RUN_ARGS="--precision full --no-half --gfpgan-cpu --esrgan-cpu --optimized-turbo"
elif [ "${RUN_MODE}" = "FULL-PRECISION" ] ; then
  echo "Running FULL-PRECISION mode"
  RUN_ARGS="--precision full --precision=full --no-half"
else
  echo "Running default mode"
fi


if [[ -z $RUN_ARGS ]]; then
    launch_message="entrypoint.sh: Launching..."
else
    launch_message="entrypoint.sh: Launching with arguments ${RUN_ARGS}"
fi
# handle automatic relaunching
if [[ -z $WEBUI_RELAUNCH || $WEBUI_RELAUNCH == "true" ]]; then
    n=0
    while true; do

        echo $launch_message
        if (( $n > 0 )); then
            echo "Relaunch count: ${n}"
        fi
        conda run --no-capture-output -n ldm python -u scripts/webui.py $RUN_ARGS
        echo "entrypoint.sh: Process is ending. Relaunching in 0.5s..."
        ((n++))
        sleep 0.5
    done
else
    echo $launch_message
    conda run --no-capture-output -n ldm python -u scripts/webui.py $RUN_ARGS
fi
