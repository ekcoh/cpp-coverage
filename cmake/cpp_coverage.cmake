# Copyright(C) 2019 - 2020 Håkan Sidenvall <ekcoh.git@gmail.com>.
#
# This file is subject to the license terms in the LICENSE file found in the 
# root directory of this distribution.
#
# See https://github.com/ekcoh/cpp-coverage for updates, documentation, and revision 
# history.

function(cpp_coverage_add_test_with_coverage)
endfunction()

# cpp_coverage_add_code_coverage
#
# Adds code coverage target(s) for a given test target using OpenCppCoverage for
# coverage measurements. This is a substitute for regular CMake add_test(...).
# Hence it has the same pros and cons as running tests via CMake add_test(...).
#
# cpp_coverage_add_code_coverage(
#   TARGET <test_target>
#   [ REPORT_FOR_PROJECT ]
#   [ REPORT_FOR_TARGET ]
#   [ DEPENDENCIES <dependencies...> ]
#
#   [ SOURCES <source-file-patterns...> ]
#   [ MODULES <module-file-patterns...> ]
#   [ EXCLUDED_SOURCES <source-file-patterns...> ]
#   [ EXCLUDED_MODULES <module-file-patterns...> ]
#   [ COVER_CHILDREN ]
#   [ CONTINUE_AFTER_CPP_EXCEPTION ]
#   [ VERBOSE | QUIET ]
# )
#
# REPORT_FOR_PROJECT
#   Specifies that the coverage measured for the given <test_target> should be
#   aggregated to the custom target created for aggregating coverage for the whole
#   project. This target will be named ${CMAKE_PROJECT_NAME}_coverage_report.
# REPORT_FOR_TARGET
#   Optionally create a custom target named <test_target>_coverage_report that will
#   generate an individual report for the given targets coverage.
# DEPENDENCIES>
#   Optionally define custom target dependencies that may affect the coverage report.
#   These dependencies will be setup as dependencies of the custom command used
#   to produce the coverage binary data.
# SOURCES
#   See https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
# MODULES
#   See https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
# EXCLUDED_SOURCES
#   See https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
# EXCLUDED_MODULES
#   See https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
# COVER_CHILDREN
#   See https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
# CONTINUE_AFTER_CPP_EXCEPTION
#   See https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
# VERBOSE
#   See https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
# QUIET
#   See https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
#
function(cpp_coverage_add_test_coverage)
    cmake_parse_arguments(
		CPP_COVERAGE
		"REPORT_FOR_TARGET;REPORT_FOR_PROJECT;CONTINUE_AFTER_CPP_EXCEPTION;COVER_CHILDREN;VERBOSE;QUIET"
		"TARGET;EXCLUDED_LINE_REGEX" 
		"SOURCES;MODULES;EXCLUDED_SOURCES;EXCLUDED_MODULES;DEPENDENCIES;TARGET_ARGS"
		${ARGN}
	)

    # Build OpenCppCoverage base command
    if (CPP_COVERAGE_CONTINUE_AFTER_CPP_EXCEPTION)
        list(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS "continue_after_cpp_exception=1")
    endif()
    if (CPP_COVERAGE_COVER_CHILDREN)
        list(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS "cover_children=1")
    endif()
    if (CPP_COVERAGE_NO_AGGERGATE_BY_FILE)
        list(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS "no_aggregate_by_file=1")
    endif()
    if (CPP_COVERAGE_EXCLUDED_LINE_REGEX)
        list(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS "excluded_line_regex=${CPP_COVERAGE_EXCLUDED_LINE_REGEX}")
    endif()
    if (CPP_COVERAGE_VERBOSE AND CPP_COVERAGE_QUIET)
        message(FATAL_ERROR "Both VERBOSE and QUIET specified. Only one may be specified")
    endif()
    if (CPP_COVERAGE_VERBOSE)
        list(APPEND OPENCPPCOVERAGE_CLI_ARGS "--verbose")
    endif()
    if (CPP_COVERAGE_QUIET)
        list(APPEND OPENCPPCOVERAGE_CLI_ARGS "--quiet")
    endif()

    set(CPP_COVERAGE_BINARY_OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CPP_COVERAGE_TARGET}.cov")
    file(TO_NATIVE_PATH ${CPP_COVERAGE_BINARY_OUTPUT_FILE} CPP_COVERAGE_NATIVE_BINARY_OUTPUT_FILE)
    set(CPP_COVERAGE_CONFIG_INPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CPP_COVERAGE_TARGET}.cov.txt")
    file(TO_NATIVE_PATH ${CPP_COVERAGE_CONFIG_INPUT_FILE} CPP_COVERAGE_CONFIG_INPUT_FILE)

    # Setup coverage report target for individual test target
    get_target_property(TARGET_BINARY_DIR ${CPP_COVERAGE_TARGET} BINARY_DIR)
    file(TO_NATIVE_PATH ${TARGET_BINARY_DIR} TARGET_BINARY_DIR)
	
    # Create native path arguments for OpenCppCoverage
    string(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS_MULTILINE)
    foreach (CPP_COVERAGE_MODULE ${CPP_COVERAGE_MODULES})
        file(TO_NATIVE_PATH ${CPP_COVERAGE_MODULE} CPP_COVERAGE_MODULE)
        string(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS_MULTILINE "modules=${CPP_COVERAGE_MODULE}\n")
    endforeach()
    foreach (CPP_COVERAGE_EXCLUDED_MODULE ${CPP_COVERAGE_EXCLUDED_MODULES})
        file(TO_NATIVE_PATH ${CPP_COVERAGE_EXCLUDED_MODULE} CPP_COVERAGE_EXCLUDED_MODULE)
        string(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS_MULTILINE "excluded_modules=${CPP_COVERAGE_EXCLUDED_MODULE}\n")
    endforeach()
    foreach (CPP_COVERAGE_SOURCE_FILE ${CPP_COVERAGE_SOURCES})
        file(TO_NATIVE_PATH ${CPP_COVERAGE_SOURCE_FILE} SOURCE_NATIVE_PATH)
        string(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS_MULTILINE "sources=${SOURCE_NATIVE_PATH}\n")
    endforeach()
    foreach (CPP_COVERAGE_EXCLUDED_SOURCE ${CPP_COVERAGE_EXCLUDED_SOURCES})
        file(TO_NATIVE_PATH ${CPP_COVERAGE_EXCLUDED_SOURCE} CPP_COVERAGE_EXCLUDED_SOURCE)
        string(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS_MULTILINE "excluded_sources=${CPP_COVERAGE_EXCLUDED_SOURCE}\n")
    endforeach()

    foreach(COVERAGE_ARG IN LISTS OPENCPPCOVERAGE_COVERAGE_ARGS)
        string(APPEND OPENCPPCOVERAGE_COVERAGE_ARGS_MULTILINE "${COVERAGE_ARG}\n")
    endforeach() 

    # Generate configuration file for test target used to output .cov
	file(WRITE ${CPP_COVERAGE_CONFIG_INPUT_FILE} 
		"# Auto-generated config file for OpenCppCoverage to produce coverage output\n"
		"export_type=binary:${CPP_COVERAGE_NATIVE_BINARY_OUTPUT_FILE}\n"
        "export_type=html:${TARGET_BINARY_DIR}/${CPP_COVERAGE_TARGET}_coverage\n"
        "${OPENCPPCOVERAGE_COVERAGE_ARGS_MULTILINE}"
	)

    # Add custom command to generate coverage file
    add_custom_command(
		OUTPUT ${CPP_COVERAGE_BINARY_OUTPUT_FILE}
        COMMENT
            "Running OpenCppCoverage on test target ${CPP_COVERAGE_TARGET} to collect test coverage..."
		COMMAND OpenCppCoverage 
			${OPENCPPCOVERAGE_CLI_ARGS} 
            --config_file=${CPP_COVERAGE_CONFIG_INPUT_FILE} 
			-- $<TARGET_FILE:${CPP_COVERAGE_TARGET}> ${CPP_COVERAGE_TARGET_ARGS}
		DEPENDS
			${CPP_COVERAGE_TARGET}
            ${CPP_COVERAGE_DEPENDENCIES}
		WORKING_DIRECTORY 
            ${CMAKE_CURRENT_BINARY_DIR}
		VERBATIM
	)

    # Simply wrap test command within OpenCppCoverage
    # TODO Consider to piggy-back report generation to this?!
    add_test(
        NAME 
            ${CPP_COVERAGE_TARGET} 
        COMMAND OpenCppCoverage 
			${OPENCPPCOVERAGE_CLI_ARGS} 
            --config_file=${CPP_COVERAGE_CONFIG_INPUT_FILE} 
			-- $<TARGET_FILE:${CPP_COVERAGE_TARGET}>
    )

    # Add target that generates coverage data
    add_custom_target(${CPP_COVERAGE_TARGET}_coverage
        DEPENDS ${CPP_COVERAGE_BINARY_OUTPUT_FILE})

    # Test-target report handling
    if (CPP_COVERAGE_ENABLE_PER_TARGET_COVERAGE_REPORTS AND CPP_COVERAGE_REPORT_FOR_TARGET)
        set(TEST_COVERAGE_REPORT_TARGET ${CPP_COVERAGE_TARGET}_coverage_report)
        cpp_coverage_add_coverage_report_target(
            "${CPP_COVERAGE_TARGET}" 
            "${TARGET_BINARY_DIR}" 
            "${CPP_COVERAGE_BINARY_OUTPUT_FILE}" 
            "${TEST_COVERAGE_REPORT_TARGET}"
            "${OPENCPPCOVERAGE_CLI_ARGS}"
        )
        set_property(TARGET ${TEST_COVERAGE_REPORT_TARGET} 
		    APPEND_STRING PROPERTY 
            CPP_COVERAGE_INPUT_FILES "input_coverage=${CPP_COVERAGE_NATIVE_BINARY_OUTPUT_FILE}\n"
	    )
    endif()
    
    # Project report handling
    if (CPP_COVERAGE_REPORT_FOR_PROJECT)
        set(PROJECT_COVERAGE_REPORT_TARGET ${CMAKE_PROJECT_NAME}_coverage_report)
        if (NOT TARGET ${PROJECT_COVERAGE_REPORT_TARGET})
            cpp_coverage_add_coverage_report_target(
                "${CMAKE_PROJECT_NAME}" 
                "${PROJECT_BINARY_DIR}" 
                "${CPP_COVERAGE_BINARY_OUTPUT_FILE}" 
                "${PROJECT_COVERAGE_REPORT_TARGET}"
                "${OPENCPPCOVERAGE_CLI_ARGS}"
            )
        endif()
        set_property(TARGET ${PROJECT_COVERAGE_REPORT_TARGET} 
		    APPEND_STRING PROPERTY 
            CPP_COVERAGE_INPUT_FILES "input_coverage=${CPP_COVERAGE_NATIVE_BINARY_OUTPUT_FILE}\n"
	    )

        # Make project report target depend on target generating coverage
        add_dependencies(${PROJECT_COVERAGE_REPORT_TARGET} ${CPP_COVERAGE_TARGET}_coverage)
    endif()
endfunction()

# ----------------- Script internals below this line --------------------------

function(cpp_coverage_add_coverage_report_target 
    TARGET_NAME 
    TARGET_BINARY_DIR 
    CPP_COVERAGE_BINARY_OUTPUT_FILE 
    REPORT_TARGET 
    OPENCPPCOVERAGE_CLI_ARGS)

    set(REPORT_CONFIG_FILE 
        ${TARGET_BINARY_DIR}/${TARGET_NAME}.cov.report.txt)
    set(REPORT_COBERTURA_FILE 
        ${TARGET_BINARY_DIR}/${TARGET_NAME}.cobertura.xml)
    set(REPORT_DIR 
        ${TARGET_BINARY_DIR}/${TARGET_NAME}_coverage)
    set(REPORT 
        ${REPORT_DIR}/index.html)

	add_custom_target(${REPORT_TARGET}
		DEPENDS ${REPORT}
		VERBATIM
    )

    string(APPEND REPORT_ARGS_MULTILINE "# Auto-generated config file for OpenCppCoverage to produce coverage report\n")
    string(APPEND REPORT_ARGS_MULTILINE "export_type=html:${REPORT_DIR}\n")
    string(APPEND REPORT_ARGS_MULTILINE "export_type=cobertura:${REPORT_COBERTURA_FILE}\n")

    add_custom_command(OUTPUT ${REPORT}
        COMMAND OpenCppCoverage 
            ${OPENCPPCOVERAGE_CLI_ARGS}
	        --config_file ${REPORT_CONFIG_FILE}
        COMMAND ${CPP_COVERAGE_REPORT_GENERATOR_TOOL} -reports:${REPORT_COBERTURA_FILE} -reporttypes:Html;HtmlChart;Badges -targetdir:${TARGET_BINARY_DIR}/custom_report -historydir:${TARGET_BINARY_DIR}/history
	    DEPENDS 
            ${REPORT_CONFIG_FILE} 
            ${CPP_COVERAGE_BINARY_OUTPUT_FILE}
	    WORKING_DIRECTORY ${REPORT_DIR}
	    COMMENT "Running OpenCppCoverage to generate code coverage report for \"${REPORT_TARGET}\" in \"${REPORT}\""
	    VERBATIM
    )

    # Note that file(GENERATE) will not generate until all CMakeLists.txt have been processed
    # We utilize this property of that command to make it possible to utilize aggregated
    # property set
    file(GENERATE 
	    OUTPUT ${REPORT_CONFIG_FILE}
	    CONTENT "${REPORT_ARGS_MULTILINE}$<TARGET_PROPERTY:${REPORT_TARGET},CPP_COVERAGE_INPUT_FILES>"
	)
endfunction()
