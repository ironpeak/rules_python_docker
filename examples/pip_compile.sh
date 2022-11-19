#!/bin/bash

pip install --upgrade pip

pip install pip-tools

pip-compile --no-build-isolation --generate-hashes --allow-unsafe --output-file="$1/requirements_lock.txt" $1/requirements.in
