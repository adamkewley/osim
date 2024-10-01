cmake_minimum_required(VERSION 3.15)

project(osim VERSION 0.0.1 LANGUAGES CXX)

find_package(spdlog REQUIRED CONFIG)

file(GLOB_RECURSE OSIM_GLOBBED_FILES "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/OpenSim/**/*.c??")
set(OSIM_EXCLUDED_PATTERNS "/Test/" "/Tests/" "/Examples/" "/Moco/" "/Sandbox/")
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

add_library(osim STATIC ${OSIM_SOURCE_FILES})
target_compile_definitions(osim PRIVATE
    OPENSIM_ACTUATORS_MAJOR_VERSION=0
    OPENSIM_ACTUATORS_MINOR_VERSION=0
    OPENSIM_ACTUATORS_BUILD_VERSION=0
)
target_include_directories(osim PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core"
)
