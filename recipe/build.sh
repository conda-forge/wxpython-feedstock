#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ext/wxWidgets
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ext/wxWidgets/src/tiff/config
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ext/wxWidgets/src/png
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ext/wxWidgets/src/expat/expat/conftools

declare -a PLATFORM_BUILD_FLAGS
if [[ $(uname) == Darwin ]]; then
  # there apparently is a c++ header file being processed as c
  # this is supposed to help against the error "'type_traits' file not found"
  export CFLAGS="${CFLAGS} -stdlib=libc++"
  # compiler on macOS seems to ignore the CPPFLAGS variable
  # see https://clang.llvm.org/docs/CommandGuide/clang.html
  export CPATH="${CPATH}:${PREFIX}/include"
  # on macOS 10.13 with XCode 9.0 mediactrl.mm compile errors out at #import <AVFoundation/AVFoundation.h> with:
  # 'AVCaptureDeviceType' is unavailable: not available on macOS
  # turns out default wxWidgets build is with -mmacosx-version-min=10.5 whilst
  # AVFoundation.h looks like it needs at least 10.7
  # furthermore, we need at least 10.9 to be able to build with libc++ and avoid the dreaded
  # "strvararg.h:25:14: fatal error: 'type_traits' file not found" build error

  # This is done using a patch now
  # sed -i -e s/"--enable-mediactrl"/"--enable-mediactrl --with-macosx-version-min=10.9"/g buildtools/build_wxwidgets.py

  # Apparently waf build system creates the object files for all targets first
  # and then creates the shared libs and doesn't honour CXXFLAGS during the
  # linking stage, which leads to linking libstdc++ instead of libc++
  export LDFLAGS="$LDFLAGS -stdlib=libc++"

  # Without this, wx tries to build a universal binary by default
  PLATFORM_BUILD_FLAGS+=(--mac_arch="$OSX_ARCH")

elif [[ $(uname) == Linux ]]; then
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include/GL -I${PREFIX}/include"

  # The configure script doesn't use --rpath-link :/
  if [[ ${ARCH} == 32 ]]; then
    export LD_LIBRARY_PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
  else
    export LD_LIBRARY_PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64"
  fi

  PLATFORM_BUILD_FLAGS+=(--gtk2)

  # Force shared linkage to Python, avoids issues with lto-wrapper and saves size.
  rm -rf ${PREFIX}/lib/python${PY_VER}/config-${PY_VER}m-x86_64-linux-gnu/libpython${PY_VER}m.a
  rm -rf ${PREFIX}/lib/libpython${PY_VER}m.a
fi

env | sort

# Disable code signing during the building stage on osx-arm64
# The code signing in cctools-port is causing the symbolically linked
# libraries in $PREFIX/lib to become files which causes issues at runtime
# https://github.com/conda-forge/wxpython-feedstock/issues/74
# The environment variable disables the step (defined in cctools-port/cctools/include/stuff/port.h)
# The libraries are still signed during the packaging stage
if [[ "$CC" == *"arm64"* ]]; then
  export NO_CODESIGN=1
fi

# The siplib files contained in the 4.2.1 tarball are incompatible
# with python 3.12, so need to be re-generated
# https://github.com/wxWidgets/Phoenix/issues/2455
$PYTHON build.py sip                 "${PLATFORM_BUILD_FLAGS[@]}" --verbose --no_magic --prefix=$PREFIX --jobs=$CPU_COUNT

$PYTHON build.py build_wx install_wx "${PLATFORM_BUILD_FLAGS[@]}" --verbose --no_magic --prefix=$PREFIX --jobs=$CPU_COUNT

# on macOS --no_magic isn't enough, we need to make build.py use wx-config to find
# the libraries in ${PREFIX}/lib otherwise they end up being linked in the wxpython
# .so files as hardcoded paths into the wxwidgets build directory
$PYTHON build.py build_py install_py "${PLATFORM_BUILD_FLAGS[@]}" --verbose --use_syswx --prefix=$PREFIX --jobs=$CPU_COUNT
