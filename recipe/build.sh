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
BUILD_FLAGS+=(--no_magic)

# on macOS --no_magic isn't enough, we need to make build.py use wx-config to
# find the libraries in ${PREFIX}/lib otherwise they end up being linked in
# the wxpython .so files as hardcoded paths into the wxwidgets build directory
BUILD_FLAGS+=(--use_syswx)

# The siplib files contained in the 4.2.1 tarball are incompatible
# with python 3.12, so need to be re-generated
# https://github.com/wxWidgets/Phoenix/issues/2455
$PYTHON build.py sip "${BUILD_FLAGS[@]}"


$PYTHON build.py build_py install_py "${BUILD_FLAGS[@]}"
