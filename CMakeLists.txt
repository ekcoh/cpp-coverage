# Copyright(C) 2019 - 2020 Håkan Sidenvall <ekcoh.git@gmail.com>.
#
# This file is subject to the license terms in the LICENSE file found in the 
# root directory of this distribution.
#
# See https://github.com/ekcoh/cpp-coverage for updates, documentation, and revision 
# history.

cmake_minimum_required (VERSION 3.11)

include(cmake/cpp_coverage.cmake)

project(cpp_coverage)
option(CPP_COVERAGE_BUILD_EXAMPLES "If enabled, builds examples" ON)
option(CPP_COVERAGE_ENABLE_COBERTURA "If enabled, downloads Covertura (if not already available as fetched content) and enables cobertura export format" ON)

if (CPP_COVERAGE_ENABLE_COBERTURA)
    include(FetchContent)
    FetchContent_Declare(
        cobertura
        URL        https://github.com/cobertura/cobertura/archive/cobertura-2.1.1.zip
    )

    FetchContent_GetProperties(cobertura)
    if(NOT cobertura)
        FetchContent_Populate(cobertura)
        #add_subdirectory(${googletest_SOURCE_DIR} ${googletest_BINARY_DIR})
        set(CPP_COVERAGE_COBERTURA_REPORT "${cobertura_SOURCE_DIR}/cobertura/executables/cobertura-report")
    endif()
endif()
if (CPP_COVERAGE_BUILD_EXAMPLES)
    enable_testing()
    add_subdirectory(examples)
endif()