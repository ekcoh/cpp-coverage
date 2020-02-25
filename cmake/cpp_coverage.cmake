

# consider supporting a simple coverage based on source and/or module which just uses ${PROJECT_SOURCE_DIR}

# add_code_coverage(TEST_TARGET mytest SOURCE ${CMAKE_PROJECT_DIR})

# TODO Add cobertura output
# TODO Add handling of other CLI commands, maybe to config file instead?!
# TODO Add test target depending on examples that assert correct coverage in generated output and existence of output files
# TODO Consider having PROJECT_COVERAGE_REPORT_ALL that drives all report generation per project
# TODO Integrate Covertura into build?! https://github.com/cobertura/cobertura/releases

# Only inteded
function(add_coverage_targets 
    TARGET_NAME 
    TARGET_BINARY_DIR 
    CPP_COVERAGE_BINARY_OUTPUT_FILE 
    REPORT_TARGET 
    OPENCPPCOVERAGE_ARGS)

    set(REPORT_CONFIG_FILE 
        ${TARGET_BINARY_DIR}/${TARGET_NAME}.cov.report.txt)
    set(REPORT_COBERTURA_FILE 
        ${TARGET_BINARY_DIR}/${TARGET_NAME}.cobertura.xml)
    set(REPORT_DIR 
        ${TARGET_BINARY_DIR}/${TARGET_NAME}_coverage)
    set(REPORT 
        ${REPORT_DIR}/index.html)

	add_custom_target(${REPORT_TARGET}
		COMMAND ${CMAKE_COMMAND} -E echo 
            "Generated code coverage report for \"${REPORT_TARGET}\" in \"${REPORT}\""
		DEPENDS ${REPORT}
		VERBATIM
    )

    add_custom_command(OUTPUT ${REPORT}
        COMMAND OpenCppCoverage
            ${OPENCPPCOVERAGE_ARGS}
	        --export_type=html:${REPORT_DIR}
            --export_type=cobertura:${REPORT_COBERTURA_FILE}
	        --config_file ${REPORT_CONFIG_FILE}
	    DEPENDS 
            ${REPORT_CONFIG_FILE} 
            ${CPP_COVERAGE_BINARY_OUTPUT_FILE}
	    WORKING_DIRECTORY ${REPORT_DIR}
	    COMMENT "Generating code coverage report: ${REPORT}"
	    VERBATIM
    )

    file(GENERATE 
	    OUTPUT ${REPORT_CONFIG_FILE}
	    CONTENT "$<TARGET_PROPERTY:${REPORT_TARGET},CPP_COVERAGE_INPUT_FILES>$<TARGET_PROPERTY:${REPORT_TARGET},CPP_COVERAGE_SOURCE_FILES>"
	)
endfunction()

# cpp_coverage_add_code_coverage
#
# Adds code coverage target(s) for a given test target using OpenCppCoverage for
# coverage measurements.
#
# cpp_coverage_add_code_coverage(
#   TEST_TARGET <test_target>
#   [ SOURCES <sources...> ]
#   [ MODULES <modules...> ]
#   [ DEPENDENCIES <dependencies...> ]
#   [ CONTINUE_AFTER_CPP_EXCEPTION ]
#   [ VERBOSE | QUIET ]
# )
#
# BINARY_OUTPUT_FILE <file>
#   Optionally define an explicit coverage binary export file for the test 
#   target. This must be a unique file within the CMake project build. 
#   Defaults to '${CMAKE_CURRENT_BINARY_DIR}/${TEST_TARGET}.cov'.
#
function(add_test_coverage)
    # Custom options as well as supporting OpenCppCoverage CLI options, see:
    # https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
    cmake_parse_arguments(
		CPP_COVERAGE
		"GENERATE_TEST_REPORT;GENERATE_PROJECT_REPORT;CONTINUE_AFTER_CPP_EXCEPTION;VERBOSE;QUIET"
		"TEST_TARGET;HTML_OUTPUT_DIR;COBERTURA_OUTPUT_FILE" 
		"SOURCES;MODULES;DEPENDENCIES"
		${ARGN}
	)

    # Build OpenCppCoverage base command
    #list(APPEND OPENCPPCOVERAGE_ARGS "OpenCppCoverage")
    if (CPP_COVERAGE_CONTINUE_AFTER_CPP_EXCEPTION)
        list(APPEND OPENCPPCOVERAGE_ARGS "--continue_after_cpp_exception")
    endif()
    if (CPP_COVERAGE_VERBOSE AND CPP_COVERAGE_QUIET)
        message(FATAL_ERROR "Both VERBOSE and QUIET specified. Only one may be specified")
    endif()
    if (CPP_COVERAGE_VERBOSE)
        list(APPEND OPENCPPCOVERAGE_ARGS "--verbose")
    endif()
    if (CPP_COVERAGE_QUIET)
        list(APPEND OPENCPPCOVERAGE_ARGS "--quiet")
    endif()

    set(CPP_COVERAGE_BINARY_OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CPP_COVERAGE_TEST_TARGET}.cov")
    set(CPP_COVERAGE_CONFIG_INPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CPP_COVERAGE_TEST_TARGET}.cov.txt")
    file(TO_NATIVE_PATH ${CPP_COVERAGE_BINARY_OUTPUT_FILE} CPP_COVERAGE_NATIVE_BINARY_OUTPUT_FILE)
	
    # Create native path source args list from SOURCES argument
    foreach (CPP_COVERAGE_SOURCE_FILE ${CPP_COVERAGE_SOURCES})
        file(TO_NATIVE_PATH ${CPP_COVERAGE_SOURCE_FILE} SOURCE_NATIVE_PATH)
        string(APPEND OPENCPPCOVERAGE_SOURCE_ARGS "sources=${SOURCE_NATIVE_PATH}\n")
    endforeach()

    # Generate configuration file for test target used to output .cov
	file(WRITE ${CPP_COVERAGE_CONFIG_INPUT_FILE} 
		"# Auto-generated config file for OpenCppCoverage\n"
		"export_type=binary:${CPP_COVERAGE_BINARY_OUTPUT_FILE}\n"
        "${OPENCPPCOVERAGE_SOURCE_ARGS}" 
	)

    # Setup coverage report target for individual test target
    get_target_property(TEST_TARGET_BINARY_DIR ${CPP_COVERAGE_TEST_TARGET} BINARY_DIR)

    set(TEST_COVERAGE_REPORT_TARGET ${CPP_COVERAGE_TEST_TARGET}_coverage_report)
    add_coverage_targets(
        "${CPP_COVERAGE_TEST_TARGET}" 
        "${TEST_TARGET_BINARY_DIR}" 
        "${CPP_COVERAGE_BINARY_OUTPUT_FILE}" 
        "${TEST_COVERAGE_REPORT_TARGET}"
        "${OPENCPPCOVERAGE_ARGS}"
    )
    set_property(TARGET ${TEST_COVERAGE_REPORT_TARGET} 
		APPEND_STRING PROPERTY 
        CPP_COVERAGE_INPUT_FILES "input_coverage=${CPP_COVERAGE_NATIVE_BINARY_OUTPUT_FILE}\n"
	)
    set_property(TARGET ${TEST_COVERAGE_REPORT_TARGET} 
		APPEND_STRING PROPERTY 
        CPP_COVERAGE_SOURCE_FILES "${OPENCPPCOVERAGE_SOURCE_ARGS}"
	)
    
    # Setup coverage report target for project
    set(PROJECT_COVERAGE_REPORT_TARGET ${CMAKE_PROJECT_NAME}_coverage_report)
    if (NOT TARGET ${PROJECT_COVERAGE_REPORT_TARGET})
        add_coverage_targets(
            "${CMAKE_PROJECT_NAME}" 
            "${PROJECT_BINARY_DIR}" 
            "${CPP_COVERAGE_BINARY_OUTPUT_FILE}" 
            "${PROJECT_COVERAGE_REPORT_TARGET}"
            "${OPENCPPCOVERAGE_ARGS}"
        )
    endif()
    set_property(TARGET ${PROJECT_COVERAGE_REPORT_TARGET} 
		APPEND_STRING PROPERTY 
        CPP_COVERAGE_INPUT_FILES "input_coverage=${CPP_COVERAGE_NATIVE_BINARY_OUTPUT_FILE}\n"
	)
    set_property(TARGET ${PROJECT_COVERAGE_REPORT_TARGET} 
		APPEND_STRING PROPERTY 
        CPP_COVERAGE_SOURCE_FILES "${OPENCPPCOVERAGE_SOURCE_ARGS}"
	)

	add_custom_command(
		OUTPUT ${CPP_COVERAGE_BINARY_OUTPUT_FILE}
		COMMAND OpenCppCoverage 
			${OPENCPPCOVERAGE_ARGS} 
            --config_file=${CPP_COVERAGE_CONFIG_INPUT_FILE} 
			-- $<TARGET_FILE:${CPP_COVERAGE_TEST_TARGET}>
		DEPENDS
			${CPP_COVERAGE_TEST_TARGET}
            ${CPP_COVERAGE_DEPENDENCIES}
		WORKING_DIRECTORY 
            ${CMAKE_CURRENT_BINARY_DIR}
		VERBATIM
	)

    # Add target that generates coverage data
    add_custom_target(${CPP_COVERAGE_TEST_TARGET}_coverage
        DEPENDS ${CPP_COVERAGE_BINARY_OUTPUT_FILE})

    # Make project report target depend on target generating coverage
    add_dependencies(${PROJECT_COVERAGE_REPORT_TARGET} ${CPP_COVERAGE_TEST_TARGET}_coverage)
endfunction()

