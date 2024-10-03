#!/usr/bin/env bash

set -xeuo pipefail

# "base" build type to use when build types haven't been specified
OSC_BASE_BUILD_TYPE=${OSC_BASE_BUILD_TYPE:-Release}

# build type for all of OSC's dependencies
OSC_DEPS_BUILD_TYPE=${OSC_DEPS_BUILD_TYPE:-`echo ${OSC_BASE_BUILD_TYPE}`}

# build type for OSC
OSC_BUILD_TYPE=${OSC_BUILD_TYPE-`echo ${OSC_BASE_BUILD_TYPE}`}

OSC_BUILD_CONCURRENCY=1

if [ ! -d emsdk ]; then
     git clone https://github.com/emscripten-core/emsdk.git
     cd emsdk/
     ./emsdk install latest
     cd -
fi

# activate emsdk
./emsdk/emsdk activate latest
source ./emsdk/emsdk_env.sh

rm -rf build/ deps-build/ install/ osc-build/ oscdeps-build/

# config+build these deps into install/
emcmake cmake -S third_party/ -B deps-build -DCMAKE_BUILD_TYPE=${OSC_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PWD}/install -DCMAKE_INSTALL_LIBDIR=${PWD}/install/lib
emmake cmake --build deps-build -j${OSC_BUILD_CONCURRENCY}

# config+build osim into install/
emcmake cmake -S . -B build -DCMAKE_PREFIX_PATH=${PWD}/install -DCMAKE_BUILD_TYPE=${OSC_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PWD}/install
emmake cmake --build build -j${OSC_BUILD_CONCURRENCY} --target install

# config+build opensim deps into install/
CXXFLAGS="-fexceptions" emcmake cmake -S ../opensim-creator/third_party -B oscdeps-build -DCMAKE_BUILD_TYPE=${OSC_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PWD}/install -DOSCDEPS_GET_OPENSIM=OFF -DOSCDEPS_GET_SDL=OFF -DOSCDEPS_GET_GLEW=OFF -DOSCDEPS_TY_NATIVEFILEDIALOG=OFF
emmake cmake --build oscdeps-build -j${OSC_BUILD_CONCURRENCY}

# config+build modified OpenSimCreator
LDFLAGS="-fexceptions -sNO_DISABLE_EXCEPTION_CATCHING=1 -sUSE_WEBGL2=1 -sMIN_WEBGL_VERSION=2 -sFULL_ES2=1 -sFULL_ES3=1 -sUSE_SDL=2" CXXFLAGS="-fexceptions --use-port=sdl2" emcmake cmake -S ../opensim-creator/ -B osc-build/ -DCMAKE_BUILD_TYPE=${OSC_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${PWD}/install -DOSC_EMSCRIPTEN=ON -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH
emmake cmake --build osc-build -j${OSC_BUILD_CONCURRENCY} -v

# run test suite, excluding tests that depend on window/files (work-in-progress)
node osc-build/tests/testoscar/testoscar.js  --gtest_filter=-Renderer*:Image*:ResourceStream*
