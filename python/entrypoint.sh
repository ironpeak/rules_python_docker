#!/bin/bash

set -euo pipefail

directory="$(pwd | rev | cut -d '/' -f3- | rev)"
binary="${directory}/$(ls -p ${directory} | grep -v /)"

sed -i "s/PYTHON_BINARY = .*/PYTHON_BINARY = 'python'/" ${binary}

shift

python "${binary}" "$@"
