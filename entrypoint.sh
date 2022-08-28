#!/bin/bash
socat TCP4-LISTEN:8080,fork TCP4:127.0.0.1:7860 &

if [ "${RUN_MODE}" = "4G" ] ; then
  conda run --no-capture-output -n ldm python scripts/webui.py --gfpgan-cpu --esrgan-cpu --optimized
elif ["${RUN_MODE}" = "GTX16"]; then
  conda run --no-capture-output -n ldm python scripts/webui.py --precision full --no-half --gfpgan-cpu --esrgan-cpu --optimized
else
  conda run --no-capture-output -n ldm python scripts/webui.py
fi
