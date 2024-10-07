cmake_minimum_required(VERSION 3.15)

project(osim VERSION 0.0.1 LANGUAGES CXX)
cmake_policy(SET CMP0007 NEW)

include(GNUInstallDirs) # CMAKE_INSTALL_LIBDIR, _INCLUDEDIR, etc.
include(CMakePackageConfigHelpers)  # configure_package_config_file
include(FindPython3)

find_package(spdlog REQUIRED CONFIG)
find_package(Simbody REQUIRED CONFIG)
find_package(Python3 COMPONENTS Development NumPy)

set(OSIM_OPENSIM_BASEDIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core")

# figure out which subset of sourcecode to use for `osim`
file(GLOB_RECURSE OSIM_GLOBBED_FILES "${OSIM_OPENSIM_BASEDIR}/OpenSim/**/*.c??")
set(OSIM_EXCLUDED_PATTERNS "/Test/" "/Tests/" "/Examples/" "/Moco/" "/Sandbox/" "C3DFileAdapter")
foreach(var ${OSIM_GLOBBED_FILES})
    set(OSIM_EXCLUDE FALSE)
    foreach(pattern ${OSIM_EXCLUDED_PATTERNS})
        if("${var}" MATCHES "${pattern}")
            set(OSIM_EXCLUDE TRUE)
        endif()
    endforeach()
    if(NOT ${OSIM_EXCLUDE})
        list(APPEND OSIM_SOURCE_FILES "${var}")
    endif()
endforeach()

file(GLOB_RECURSE OSIM_GLOBBED_LEPTON_SOURCES "${OSIM_OPENSIM_BASEDIR}/Vendors/lepton/src/*.cpp")
add_library(lepton STATIC ${OSIM_GLOBBED_LEPTON_SOURCES})
target_include_directories(lepton PUBLIC
    $<BUILD_INTERFACE:${OSIM_OPENSIM_BASEDIR}/Vendors/lepton/include>
    $<INSTALL_INTERFACE:include>
)
file(GLOB_RECURSE OSIM_GLOBBED_LEPTON_HEADERS "${OSIM_OPENSIM_BASEDIR}/Vendors/lepton/include/lepton/*.h")
install(FILES ${OSIM_GLOBBED_LEPTON_HEADERS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/lepton")

add_library(OpenSim STATIC ${OSIM_SOURCE_FILES})
target_compile_definitions(OpenSim PRIVATE
    OPENSIM_ACTUATORS_MAJOR_VERSION=0
    OPENSIM_ACTUATORS_MINOR_VERSION=0
    OPENSIM_ACTUATORS_BUILD_VERSION=0
    OPENSIM_ANALYSES_MAJOR_VERSION=0
    OPENSIM_ANALYSES_MINOR_VERSION=0
    OPENSIM_ANALYSES_BUILD_VERSION=0
    OPENSIM_COMMON_MAJOR_VERSION=0
    OPENSIM_COMMON_MINOR_VERSION=0
    OPENSIM_COMMON_BUILD_VERSION=0
    OPENSIM_SIMULATION_MAJOR_VERSION=0
    OPENSIM_SIMULATION_MINOR_VERSION=0
    OPENSIM_SIMULATION_BUILD_VERSION=0
    OPENSIM_TOOLS_MAJOR_VERSION=0
    OPENSIM_TOOLS_MINOR_VERSION=0
    OPENSIM_TOOLS_BUILD_VERSION=0
)
target_include_directories(OpenSim PUBLIC
    $<BUILD_INTERFACE:${OSIM_OPENSIM_BASEDIR}>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(OpenSim PUBLIC
    SimTKcommon_static
    SimTKmath_static
    SimTKsimbody_static
    spdlog::spdlog
    lepton
)

# attach sources
file(GLOB_RECURSE OSIM_GLOBBED_HEADERS "${OSIM_OPENSIM_BASEDIR}/OpenSim/**/*.h")
foreach(var ${OSIM_GLOBBED_HEADERS})
    set(OSIM_EXCLUDE FALSE)
    foreach(pattern ${OSIM_EXCLUDED_PATTERNS})
        if("${var}" MATCHES "${pattern}")
            set(OSIM_EXCLUDE TRUE)
        endif()
    endforeach()
    if(NOT ${OSIM_EXCLUDE})
        list(APPEND OSIM_HEADER_FILES "${var}")
    endif()
endforeach()

foreach(header ${OSIM_HEADER_FILES})
    file(RELATIVE_PATH header_relpath ${OSIM_OPENSIM_BASEDIR} ${header})
    get_filename_component(DIR ${header_relpath} DIRECTORY)
    install(FILES ${header} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${DIR})
endforeach()

# python bindings
add_library(lib SHARED lib.cpp)
target_link_libraries(lib PUBLIC Python3::Python)

# installation
install(TARGETS OpenSim lepton EXPORT OpenSimTargets)
install(EXPORT OpenSimTargets DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OpenSim)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/OpenSimConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/OpenSimConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OpenSim
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/OpenSimConfig.cmake" DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/OpenSim")

