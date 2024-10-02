#export CFLAGS=-fPIC
#export CXXFLAGS=-fPIC
OSIM_BUILD_TYPE=RelMinSize

rm -rf build/ deps-build/ install/

cmake -S third_party/ -B deps-build -DCMAKE_BUILD_TYPE=${OSIM_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PWD}/install && cmake --build deps-build -j20 && cmake -S . -B build -DCMAKE_PREFIX_PATH=${PWD}/install -DCMAKE_BUILD_TYPE=${OSIM_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PWD}/install && cmake --build build -j20
