

# consider supporting a simple coverage based on source and/or module which just uses ${PROJECT_SOURCE_DIR}

# add_code_coverage(TEST_TARGET mytest SOURCE ${CMAKE_PROJECT_DIR})

# TODO Add cobertura output
# TODO Add handling of other CLI commands, maybe to config file instead?!
# TODO Add test target depending on examples that assert correct coverage in generated output and existence of output files
# TODO Consider having PROJECT_COVERAGE_REPORT_ALL that drives all report generation per project
# TODO Integrate Covertura into build?! https://github.com/cobertura/cobertura/releases

function(add_coverage_targets 
    TARGET_NAME 
    TARGET_BINARY_DIR 
    COV_FILE REPORT_TARGET 
    OPENCPPCOVERAGE_ARGS)
    #
    set(REPORT_CONFIG_FILE ${TARGET_BINARY_DIR}/${TARGET_NAME}.coverage_report.txt)
    set(REPORT_DIR ${TARGET_BINARY_DIR}/${TARGET_NAME}_coverage)
    set(REPORT ${REPORT_DIR}/index.html)
    set(REPORT_COBERTURA_FILE ${TARGET_BINARY_DIR}/${TARGET_NAME}.cobertura.xml)
    # TODO Place .cov file here?! as well as config

    # Create custom target for generating project report from .cov files
	add_custom_target(${REPORT_TARGET}
		COMMAND ${CMAKE_COMMAND} -E echo "Generating code coverage report for ${REPORT_TARGET}..."
		DEPENDS ${REPORT}
		VERBATIM
    )

    # Define a rule how to generate html report from .cov files
    add_custom_command(OUTPUT ${REPORT}
	    COMMAND ${CMAKE_COMMAND} -E echo "Running main report command..."
        COMMAND ${OPENCPPCOVERAGE_ARGS}
	        --export_type=html:${REPORT_DIR}
            --export_type=cobertura:${REPORT_COBERTURA_FILE}
	        --config_file ${REPORT_CONFIG_FILE}
	    DEPENDS 
            ${REPORT_CONFIG_FILE} 
            ${COV_FILE}
	    WORKING_DIRECTORY ${REPORT_DIR}
	    COMMENT "Generating code coverage report: ${REPORT}"
	    VERBATIM
    )

	# Generate code coverage report configuration file based on accumulated
    # configure-time meta information properties. Utilize the fact that 
    # file(GENERATE...) is not executed until all project CMakeLists.txt files
    # have been processed.
    file(GENERATE 
	    OUTPUT ${REPORT_CONFIG_FILE}
	    CONTENT "$<TARGET_PROPERTY:${REPORT_TARGET},CPP_COVERAGE_INPUT_FILES>$<TARGET_PROPERTY:${REPORT_TARGET},CPP_COVERAGE_SOURCE_FILES>"
	)
endfunction()

function(add_test_coverage)
    # Custom options as well as supporting OpenCppCoverage CLI options, see:
    # https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
    cmake_parse_arguments(
		CPP_COVERAGE
		"GENERATE_TEST_REPORT;GENERATE_PROJECT_REPORT;CONTINUE_AFTER_CPP_EXCEPTION;VERBOSE;QUIET"
		"TEST_TARGET;BINARY_OUTPUT_FILE;HTML_OUTPUT_DIR;COBERTURA_OUTPUT_FILE" 
		"SOURCES;MODULES;DEPENDENCIES"
		${ARGN}
	)

    # Build OpenCppCoverage base command
    list(APPEND OPENCPPCOVERAGE_ARGS "OpenCppCoverage")
    if (CPP_COVERAGE_CONTINUE_AFTER_CPP_EXCEPTION)
        list(APPEND OPENCPPCOVERAGE_ARGS "--continue_after_cpp_exception")
    endif()
    if (CPP_COVERAGE_VERBOSE)
        list(APPEND OPENCPPCOVERAGE_ARGS "--verbose")
    endif()
    if (CPP_COVERAGE_QUIET)
        list(APPEND OPENCPPCOVERAGE_ARGS "--quiet")
    endif()
    message("OPENCPPCOVERAGE_ARGS=${OPENCPPCOVERAGE_ARGS}")

    set(COV_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CPP_COVERAGE_TEST_TARGET}.cov.txt")
	set(COV_OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CPP_COVERAGE_TEST_TARGET}.cov")

    # Setup coverage report target for individual test target
    get_target_property(TEST_TARGET_BINARY_DIR ${CPP_COVERAGE_TEST_TARGET} BINARY_DIR)
    set(TEST_COVERAGE_REPORT_TARGET ${CPP_COVERAGE_TEST_TARGET}_coverage_report)
    add_coverage_targets(
        "${CPP_COVERAGE_TEST_TARGET}" 
        "${TEST_TARGET_BINARY_DIR}" 
        "${COV_OUTPUT_FILE}" 
        "${TEST_COVERAGE_REPORT_TARGET}"
        "${OPENCPPCOVERAGE_ARGS}"
    )
    message("TEST_COVERAGE_REPORT_TARGET=${TEST_COVERAGE_REPORT_TARGET}")

    # Setup coverage report target for project
    set(PROJECT_COVERAGE_REPORT_TARGET ${CMAKE_PROJECT_NAME}_coverage_report)
    if (NOT TARGET ${PROJECT_COVERAGE_REPORT_TARGET})
        add_coverage_targets(
            "${CMAKE_PROJECT_NAME}" 
            "${PROJECT_BINARY_DIR}" 
            "${COV_OUTPUT_FILE}" 
            "${PROJECT_COVERAGE_REPORT_TARGET}"
            "${OPENCPPCOVERAGE_ARGS}"
        )
    endif()

    # Create native path source args list from SOURCES argument
    foreach (CPP_COVERAGE_SOURCE_FILE ${CPP_COVERAGE_SOURCES})
        file(TO_NATIVE_PATH ${CPP_COVERAGE_SOURCE_FILE} SOURCE_NATIVE_PATH)
        string(APPEND OPENCPPCOVERAGE_SOURCE_ARGS "sources=${SOURCE_NATIVE_PATH}\n")
    endforeach()

    # Generate configuration file for test target used to output .cov
	file(WRITE ${COV_CONFIG_FILE} 
		"# Auto-generated config file for OpenCppCoverage\n"
		"export_type=binary:${COV_OUTPUT_FILE}\n"
        "${OPENCPPCOVERAGE_SOURCE_ARGS}" 
	)

    # Append aggregated coverage input to custom CMake project property
    # of project coverage report target. This will later be transformed
    # to a configuration file.
    file(TO_NATIVE_PATH ${COV_OUTPUT_FILE} NATIVE_COV_OUTPUT_FILE)
    set_property(TARGET ${PROJECT_COVERAGE_REPORT_TARGET} 
		APPEND_STRING PROPERTY 
        CPP_COVERAGE_INPUT_FILES "input_coverage=${NATIVE_COV_OUTPUT_FILE}\n"
	)
    set_property(TARGET ${TEST_COVERAGE_REPORT_TARGET} 
		APPEND_STRING PROPERTY 
        CPP_COVERAGE_INPUT_FILES "input_coverage=${NATIVE_COV_OUTPUT_FILE}\n"
	)

    # Append source list to custom CMake property of project coverage 
    # report target. This will later be transformed to a configuration file.
    set_property(TARGET ${PROJECT_COVERAGE_REPORT_TARGET} 
		APPEND_STRING PROPERTY 
        CPP_COVERAGE_SOURCE_FILES "${OPENCPPCOVERAGE_SOURCE_ARGS}"
	)
    set_property(TARGET ${TEST_COVERAGE_REPORT_TARGET} 
		APPEND_STRING PROPERTY 
        CPP_COVERAGE_SOURCE_FILES "${OPENCPPCOVERAGE_SOURCE_ARGS}"
	)

    # Tell CMake how to produce .cov file by running test and set dependencies.
    # Note that dependency to test target will invalidate .cov file whenever
    # the test changes. Source dependencies linked to or directly included
    # by the test will indirectly be part of this dependency graph.
    # However, support explicit extra dependencies in case of IPC scenario
    # or dynamic shared library loading or other loose dependencies.
	add_custom_command(
		OUTPUT ${COV_OUTPUT_FILE}
        COMMAND
            COMMAND ${CMAKE_COMMAND} -E echo "Producing ${COV_OUTPUT_FILE}..."
		COMMAND 
			${OPENCPPCOVERAGE_ARGS} 
            --config_file=${COV_CONFIG_FILE} 
			-- $<TARGET_FILE:${CPP_COVERAGE_TEST_TARGET}>
		DEPENDS
			${CPP_COVERAGE_TEST_TARGET}
            ${CPP_COVERAGE_DEPENDENCIES}
		WORKING_DIRECTORY 
            ${CMAKE_CURRENT_BINARY_DIR}
		VERBATIM
	)

    # Add target that generates coverage data
    add_custom_target(${CPP_COVERAGE_TEST_TARGET}_cover
        DEPENDS ${COV_OUTPUT_FILE})

    add_dependencies(${PROJECT_COVERAGE_REPORT_TARGET} ${CPP_COVERAGE_TEST_TARGET}_cover)
endfunction()

