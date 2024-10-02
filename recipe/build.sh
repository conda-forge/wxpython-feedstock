#!/bin/bash

declare -a BUILD_FLAGS

if [[ $(uname) == Darwin ]]; then

  # Without this, wx tries to build a universal binary by default
  BUILD_FLAGS+=(--mac_arch="$OSX_ARCH")

elif [[ $(uname) == Linux ]]; then

  BUILD_FLAGS+=(--gtk3)
fi

BUILD_FLAGS+=(--verbose)
BUILD_FLAGS+=(--jobs=$CPU_COUNT)
BUILD_FLAGS+=(--prefix=$PREFIX)

# Build against existing wxwidgets installed in $PREFIX
BUILD_FLAGS+=(--no_magic)
BUILD_FLAGS+=(--use_syswx)

$PYTHON build.py build_py install_py "${BUILD_FLAGS[@]}"
