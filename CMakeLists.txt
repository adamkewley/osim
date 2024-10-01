cmake_minimum_required(VERSION 3.15)

project(osim VERSION 0.0.1 LANGUAGES CXX)

find_package(spdlog REQUIRED CONFIG)
find_package(Simbody REQUIRED CONFIG)

include(GNUInstallDirs) # CMAKE_INSTALL_LIBDIR, _INCLUDEDIR, etc.
include(CMakePackageConfigHelpers)  # configure_package_config_file

file(GLOB_RECURSE OSIM_GLOBBED_FILES "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/OpenSim/**/*.c??")
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

add_library(lepton STATIC
    "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/Vendors/lepton/src/CompiledExpression.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/Vendors/lepton/src/ExpressionProgram.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/Vendors/lepton/src/ExpressionTreeNode.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/Vendors/lepton/src/Operation.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/Vendors/lepton/src/ParsedExpression.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/Vendors/lepton/src/Parser.cpp"
)
target_include_directories(lepton PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core/Vendors/lepton/include>
    $<INSTALL_INTERFACE:include>
)
install(TARGETS lepton EXPORT OpenSimTargets)

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
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/third_party/opensim-core>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(OpenSim PUBLIC 
    SimTKcommon_static
    SimTKmath_static
    SimTKsimbody_static
    spdlog::spdlog
    lepton
)

install(TARGETS OpenSim EXPORT OpenSimTargets)
install(EXPORT OpenSimTargets DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OpenSim)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/OpenSimConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/OpenSimConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OpenSim
)

