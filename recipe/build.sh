#!/bin/bash

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

elif [[ $(uname) == Linux ]]; then
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include/GL -I${PREFIX}/include"

  # The configure script doesn't use --rpath-link :/
  if [[ ${ARCH} == 32 ]]; then
    export LD_LIBRARY_PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
  else
    export LD_LIBRARY_PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64"
  fi

  # PLATFORM_BUILD_FLAGS+=(--gtk3)
  PLATFORM_BUILD_FLAGS+=(--with-gtk=3)

fi

env | sort

$PYTHON build.py build_wx install_wx "${PLATFORM_BUILD_FLAGS[@]}" --verbose --no_magic --prefix=$PREFIX --jobs=$CPU_COUNT
# on macOS --no_magic isn't enough, we need to make build.py use wx-config to find
# the libraries in ${PREFIX}/lib otherwise they end up being linked in the wxpython
# .so files as hardcoded paths into the wxwidgets build directory
$PYTHON build.py build_py install_py "${PLATFORM_BUILD_FLAGS[@]}" --verbose --use_syswx --prefix=$PREFIX --jobs=$CPU_COUNT
