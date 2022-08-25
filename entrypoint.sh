#!/bin/bash
socat TCP4-LISTEN:8080,fork TCP4:127.0.0.1:7860 &

conda run --no-capture-output -n ldm python scripts/webui.py
