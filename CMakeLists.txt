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

option(CPP_COVERAGE_BUILD_EXAMPLES "If enabled, builds examples" OFF)
option(CPP_COVERAGE_ENABLE_PER_TARGET_COVERAGE_REPORTS "If enabled, allows generation of per-target coverage report (if defined for target)" OFF)
option(CPP_COVERAGE_ENABLE_REPORT_GENERATOR "If enabled, downloads ReportGenerator (if not already available as fetched content) and enables custom report generation." ON)
option(CPP_COVERAGE_ENABLE_COV_COMMANDS "If enabled, adds CMake custom command build rules for cov files" OFF)
option(CPP_COVERAGE_ENABLE_COV_DEPENDENCIES "If enabled, setup CMake dependencies on cov files" ON)
option(CPP_COVERAGE_ONLY_FOR_DEBUG_CONFIGURATION ON)
set(CPP_COVERAGE_REPORT_TYPE "Html;HtmlChart;Badges" CACHE STRING "Report type passed to report tool via --reporttype argument")

if (CPP_COVERAGE_ENABLE_REPORT_GENERATOR)
    # Download pre-compiled report generator and make it available (WIN32 only)
    include(FetchContent)
    FetchContent_Declare(
        report_generator
        URL https://github.com/danielpalme/ReportGenerator/releases/download/v4.8.8/ReportGenerator_4.8.8.zip
    )

    FetchContent_GetProperties(report_generator)
    if(NOT report_generator)
        FetchContent_Populate(report_generator)
        set(CPP_COVERAGE_REPORT_GENERATOR_TOOL "${report_generator_SOURCE_DIR}/net47/ReportGenerator.exe" CACHE STRING "Report generator tool path")
    endif()
endif()

if (CPP_COVERAGE_BUILD_EXAMPLES)
    enable_testing()
    add_subdirectory(examples)
endif()