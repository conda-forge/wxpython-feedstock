#!/bin/bash

# Remove this to ensure we aren't using vendored wxWidgets
rm -rf ext/wxWidgets

# Specify where WXWIN is located (the prefix) to help the build process
export WXWIN=${PREFIX}
# $PYTHON build.py build_py install_py "${PLATFORM_BUILD_FLAGS[@]}" --verbose --use_syswx --prefix=$PREFIX --jobs=$CPU_COUNT
$PYTHON build.py build_py install_py --verbose --use_syswx --prefix=$PREFIX
