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
option(CPP_COVERAGE_ENABLE_PER_TARGET_COVERAGE_REPORTS "If enabled, allows generation of per-target coverage report (if defined for target)" OFF)

if (WIN32)
    option(CPP_COVERAGE_ENABLE_REPORT_GENERATOR "If enabed, downloads ReportGenerator (if not already available as fetched content) and enables custom report generation." ON)
    if (CPP_COVERAGE_ENABLE_REPORT_GENERATOR)
        include(FetchContent)
        FetchContent_Declare(
            report_generator
            URL https://github.com/danielpalme/ReportGenerator/releases/download/v4.5.0/ReportGenerator_4.5.0.zip
        )

        FetchContent_GetProperties(report_generator)
        if(NOT report_generator)
            FetchContent_Populate(report_generator)
            set(CPP_COVERAGE_REPORT_GENERATOR_TOOL "${report_generator_SOURCE_DIR}/net47/ReportGenerator.exe")
        endif()
    endif()
endif()

if (CPP_COVERAGE_BUILD_EXAMPLES)
    enable_testing()
    add_subdirectory(examples)
endif()