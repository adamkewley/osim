#!/usr/bin/env bash

set -xeuo pipefail

export CC=clang
export CXX=clang++
OSIM_BUILD_TYPE=RelWithDebInfo

# config+build these deps into install/
cmake -S third_party/ -B deps-build -DCMAKE_BUILD_TYPE=${OSIM_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PWD}/install
cmake --build deps-build -j20

# config+build opensim deps into install/
cmake -S ../opensim-creator/third_party -B oscdeps-build -DCMAKE_BUILD_TYPE=${OSIM_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PWD}/install -DOSCDEPS_GET_OPENSIM=OFF
cmake --build oscdeps-build -j20

# config+build osim into install/
cmake -S . -B build -DCMAKE_PREFIX_PATH=${PWD}/install -DCMAKE_BUILD_TYPE=${OSIM_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PWD}/install
cmake --build build -j20 --target install

# config+build modified OpenSimCreator
cmake -S ../opensim-creator/ -B osc-build/ -DCMAKE_BUILD_TYPE=${OSIM_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${PWD}/install
cmake --build osc-build -j20 -v
