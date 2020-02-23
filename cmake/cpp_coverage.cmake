#########################################################################################
#
# add_code_coverage(TARGET <target> SOURCES <sources>)
#
# <target> The executable target to be executed to collect code coverage.
# <sources> List of regexp sources to be included in code coverage result.
#
function(add_code_coverage)
	cmake_parse_arguments(
		OPENCCOV_PREFIX
		""
		"TARGET;DEPENDS"
		"SOURCES"
		${ARGN}
	)

	# Create source args list from arguments
	set(SOURCE_ARGS ${OPENCCOV_PREFIX_SOURCES})
	list(TRANSFORM SOURCE_ARGS PREPEND "sources=")
	if (WIN32)
        # OpenCppCoverage require Windows path separator
		list(TRANSFORM SOURCE_ARGS REPLACE "/" "\\\\")
	endif()
	string(REGEX REPLACE ";" "\\n" SOURCE_ARGS_CONFIG "${SOURCE_ARGS}") 

	# Generate configuration file for target
	set(CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${OPENCCOV_PREFIX_TARGET}.txt")
	set(OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${OPENCCOV_PREFIX_TARGET}.cov")
	file(WRITE ${CONFIG_FILE} 
		"# Auto-generated config file for OpenCppCoverage\n"
		"${SOURCE_ARGS_CONFIG}\n" 
		"export_type=binary:${OUTPUT_FILE}"
	)

	message("DEPENDS=${OPENCCOV_PREFIX_DEPENDS}")

	# Create source dependencies for custom command
	# TODO Support generics by iterating over list of wildcard expression and globbing them

	#FILE(GLOB_RECURSE GLOBBED_SOURCES ${OPENCCOV_PREFIX_SOURCES})
	
	#message("DEBUG XXXXXX=${GLOBBED_SOURCES}")

	# Create command to generate output coverage file for target
	add_custom_command(
		OUTPUT ${OUTPUT_FILE}
		COMMAND 
			OpenCppCoverage 
			--config_file=${CONFIG_FILE} 
			--continue_after_cpp_exception
			-- $<TARGET_FILE:${OPENCCOV_PREFIX_TARGET}>
		DEPENDS
			${OPENCCOV_PREFIX_TARGET}
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		VERBATIM
	)

	# Create target to generate coverage report
	add_custom_target(${OPENCCOV_PREFIX_TARGET}_cov
		COMMAND ${CMAKE_COMMAND} -E echo "Collecting coverage data for ${OPENCCOV_PREFIX_TARGET}..."
		DEPENDS ${OUTPUT_FILE}
		VERBATIM
	)

	# Append to code coverage binary output as input to report target
	file(TO_NATIVE_PATH ${OUTPUT_FILE} NATIVE_OUTPUT_FILE)
	set_property(TARGET coverage_report 
		APPEND_STRING PROPERTY 
			OPENCCOV_INPUT_FILES "input_coverage=${NATIVE_OUTPUT_FILE}\n"
	)

	# Make coverage report target depend on coverage generator target
	add_dependencies(coverage_report ${OPENCCOV_PREFIX_TARGET}_cov)

endfunction()

function(target_coverage)
	cmake_parse_arguments(
		CPP_COVERAGE
		"REPORT_FOR_SOURCE_TARGET;REPORT_FOR_PROJECT;REPORT_FOR_TOP_PROJECT"
		"TEST_TARGET" 
		"SOURCE_TARGETS"
		${ARGN}
	)

    if (NOT CPP_COVERAGE_TEST_TARGET)
        message(FATAL_ERROR "Missing required TEST_TARGET <target> argument. It should specify a valid CMake executable test binary target.")
    endif()
    if (NOT TARGET ${CPP_COVERAGE_TEST_TARGET})
        message(FATAL_ERROR "${CPP_COVERAGE_TEST_TARGET} is not a valid CMake logical target.")
    endif()
    if (NOT CPP_COVERAGE_SOURCE_TARGETS)
        message(FATAL_ERROR "Missing required SOURCE_TARGETS <targets...> argument. It should specify a valid CMake executable or library binary target.")
    endif()

    set(COV_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CPP_COVERAGE_TEST_TARGET}.cov.txt")
	set(COV_OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CPP_COVERAGE_TEST_TARGET}.cov")

    # For each covered source target, build aggregate list of source files
    foreach(SOURCE_TARGET ${CPP_COVERAGE_SOURCE_TARGETS})
        message(STATUS "SOURCE_TARGET=${SOURCE_TARGET}")

        get_target_property(SOURCE_DIR ${SOURCE_TARGET} SOURCE_DIR)
        get_target_property(SOURCES ${SOURCE_TARGET} SOURCES)
        get_target_property(INTERFACE_SOURCES ${SOURCE_TARGET} INTERFACE_SOURCES)

        # In case REPORT_FOR_SOURCE_TARGET is provided, generate a source target report
        # in the binary folder of the source target
        if (CPP_COVERAGE_REPORT_FOR_SOURCE_TARGET)
            # Define a configuration file for the source target report
            get_target_property(SOURCE_TARGET_FILE_DIR ${SOURCE_TARGET} BINARY_DIR)
            set(SOURCE_TARGET_REPORT_CONFIG_FILE "${SOURCE_TARGET_FILE_DIR}/${SOURCE_TARGET}.coverage_report.txt")
            set(SOURCE_TARGET_REPORT_DIR "${SOURCE_TARGET_FILE_DIR}/coverage")
            set(SOURCE_TARGET_REPORT "${SOURCE_TARGET_REPORT_DIR}/index.html")
            # $<TARGET_FILE_DIR:${SOURCE_TARGET}>/${SOURCE_TARGET}.inputfiles.txt
            
            # If not already defined, create custom target for source target coverage report
            set(SOURCE_TARGET_COVERAGE_REPORT_TARGET ${SOURCE_TARGET}_coverage_report)
            if (NOT TARGET ${SOURCE_TARGET_COVERAGE_REPORT_TARGET})
                add_custom_target(${SOURCE_TARGET_COVERAGE_REPORT_TARGET}
                    COMMAND ${CMAKE_COMMAND} -E echo "Creating coverage report for ${SOURCE_TARGET_COVERAGE_REPORT_TARGET}..."
                    DEPENDS ${SOURCE_TARGET_REPORT}
		            VERBATIM
                )

                # Explain to CMake how to create report from config file and targets
                add_custom_command(OUTPUT ${SOURCE_TARGET_REPORT}
                    COMMAND OpenCppCoverage --verbose
                        --continue_after_cpp_exception
                        --export_type=html:${SOURCE_TARGET_REPORT_DIR}
                        --config_file ${SOURCE_TARGET_REPORT_CONFIG_FILE}
                    DEPENDS 
                        ${SOURCE_TARGET_REPORT_CONFIG_FILE} ${COV_OUTPUT_FILE} # TODO Multiple COV files could be needed
                    WORKING_DIRECTORY
                        ${SOURCE_DIR}
                    COMMENT "Generating code coverage report: ${SOURCE_TARGET_REPORT}"
                    VERBATIM
                )

                file(WRITE ${SOURCE_TARGET_REPORT_CONFIG_FILE} "")
            endif()

            # Append meta information to source target
	        file(TO_NATIVE_PATH ${COV_OUTPUT_FILE} NATIVE_COV_OUTPUT_FILE)
	        set_property(TARGET ${SOURCE_TARGET_COVERAGE_REPORT_TARGET} 
		        APPEND_STRING PROPERTY 
			    CPP_COVERAGE_INPUT_FILES "input_coverage=${NATIVE_COV_OUTPUT_FILE}\n"
	        )
            file(APPEND ${SOURCE_TARGET_REPORT_CONFIG_FILE} "input_coverage=${NATIVE_COV_OUTPUT_FILE}\n")
        endif(CPP_COVERAGE_REPORT_FOR_SOURCE_TARGET)

        if (CPP_COVERAGE_REPORT_FOR_PROJECT)
            set(PROJECT_COVERAGE_REPORT_CONFIG_FILE ${PROJECT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.coverage_report.txt)
            set(PROJECT_COVERAGE_REPORT_DIR ${PROJECT_BINARY_DIR}/coverage)
            set(PROJECT_COVERAGE_REPORT ${PROJECT_COVERAGE_REPORT_DIR}/index.html)
            set(PROJECT_COVERAGE_REPORT_TARGET ${CMAKE_PROJECT_NAME}_coverage_report)

            if (NOT TARGET ${PROJECT_COVERAGE_REPORT_TARGET})
                # Create custom target for generating project report
	            add_custom_target(${PROJECT_COVERAGE_REPORT_TARGET}
		            COMMAND ${CMAKE_COMMAND} -E echo "Generating code coverage report for ${CMAKE_PROJECT_NAME}..."
		            DEPENDS ${PROJECT_COVERAGE_REPORT}
		            VERBATIM
	            )

                # Define a rule how to generate coverage report
                add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/coverage/index.html
	                COMMAND OpenCppCoverage --verbose
	                    --continue_after_cpp_exception
	                    --export_type=html:${PROJECT_COVERAGE_REPORT_DIR}
	                    --config_file ${PROJECT_COVERAGE_REPORT_CONFIG_FILE}
	                DEPENDS 
                        ${PROJECT_COVERAGE_REPORT_CONFIG_FILE} 
                        ${COV_OUTPUT_FILE}
	                WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
	                COMMENT "Generating code coverage report: ${PROJECT_COVERAGE_REPORT}"
	                VERBATIM
                )

	            # Generate code coverage report configuration file based on meta information property.
                # Note that it is not generated until all project CMakeLists.txt files have been processed
                file(GENERATE 
	                OUTPUT ${PROJECT_COVERAGE_REPORT_CONFIG_FILE}
	                CONTENT $<TARGET_PROPERTY:${PROJECT_COVERAGE_REPORT_TARGET},CPP_COVERAGE_INPUT_FILES>
	            )
            else()
                # Append additional rule how to generate coverage report
                add_custom_command(
                    OUTPUT 
                        ${PROJECT_BINARY_DIR}/coverage/index.html
	                DEPENDS 
                        ${COV_OUTPUT_FILE}
	                VERBATIM
                )                
            endif()

            # Append meta information to project target
	        file(TO_NATIVE_PATH ${COV_OUTPUT_FILE} NATIVE_COV_OUTPUT_FILE)
	        set_property(TARGET ${PROJECT_COVERAGE_REPORT_TARGET} 
		        APPEND_STRING PROPERTY 
			    CPP_COVERAGE_INPUT_FILES "input_coverage=${NATIVE_COV_OUTPUT_FILE}\n"
	        )
            #set_property(TARGET ${PROJECT_COVERAGE_REPORT_TARGET})

        endif()

        message("SOURCE_DIR: ${SOURCE_DIR}")
        message("SOURCES: ${SOURCES}")

        list(APPEND ALL_SOURCES ${SOURCES})
        list(TRANSFORM ALL_SOURCES PREPEND ${SOURCE_DIR}/)
    endforeach()

    message("ALL_SOURCES: ${ALL_SOURCES}")

    # Create source args list from arguments
	set(OPENCPPCOVERAGE_SOURCE_ARGS ${ALL_SOURCES})
	list(TRANSFORM OPENCPPCOVERAGE_SOURCE_ARGS PREPEND "sources=")
	if (WIN32)
        # OpenCppCoverage require Windows path separator
		list(TRANSFORM OPENCPPCOVERAGE_SOURCE_ARGS REPLACE "/" "\\\\")
	endif()
	string(REGEX REPLACE ";" "\\n" OPENCPPCOVERAGE_SOURCE_ARGS_CONFIG "${OPENCPPCOVERAGE_SOURCE_ARGS}") 

    # Generate configuration file for test target
	file(WRITE ${COV_CONFIG_FILE} 
		"# Auto-generated config file for OpenCppCoverage\n"
		"${OPENCPPCOVERAGE_SOURCE_ARGS_CONFIG}\n" 
		"export_type=binary:${COV_OUTPUT_FILE}"
	)

    # Create command to generate output coverage file for target
    # This tells CMake how to produce .cov file and sets up dependency to source
	add_custom_command(
		OUTPUT ${COV_OUTPUT_FILE}
		COMMAND 
			OpenCppCoverage 
			--config_file=${COV_CONFIG_FILE} 
			--continue_after_cpp_exception
			-- $<TARGET_FILE:${CPP_COVERAGE_TEST_TARGET}>
		DEPENDS
			${CPP_COVERAGE_TEST_TARGET} ${CPP_COVERAGE_SOURCE_TARGETS}
		WORKING_DIRECTORY 
            ${CMAKE_CURRENT_BINARY_DIR}
		VERBATIM
	)

    # Alternatively, setup test coverage target as test target instead?!
    add_custom_target(${CPP_COVERAGE_TEST_TARGET}_run
		COMMAND ${CMAKE_COMMAND} -E echo "Runs test and produces coverage..."
		DEPENDS ${COV_OUTPUT_FILE}
		VERBATIM
	)

    # Create coverage report target which produces coverage report based on .cov files
    # Note that we separate this from custom target that produce .cov files so that tests
    # are run only if needed due to outdated .cov files due to dependency tree changes.
    if (CPP_COVERAGE_REPORT_FOR_PROJECT)
        # Create custom target for generating project report
	    # add_custom_target(${CMAKE_PROJECT_NAME}_coverage_report
		#    COMMAND ${CMAKE_COMMAND} -E echo "Generating code coverage report for ${CMAKE_PROJECT_NAME}..."
		#    DEPENDS ${PROJECT_BINARY_DIR}/coverage/index.html
		#    VERBATIM
	    #)

        # Define a rule how to generate coverage report
        #add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/coverage/index.html
	    #    COMMAND OpenCppCoverage --verbose
		#        --continue_after_cpp_exception
		#        --export_type=html:${PROJECT_BINARY_DIR}/coverage
		#        --config_file ${PROJECT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.cov.report.txt
	    #    DEPENDS ${PROJECT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.cov.input.txt
	    #    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	    #    COMMENT "Generating code coverage report: ${PROJECT_BINARY_DIR}/coverage/index.html"
	    #    VERBATIM
        #)

	    # Generate code coverage report configuration file.
        # Note that it is not generated until all project CMakeLists.txt files have been processed
        #file(GENERATE 
		#    OUTPUT ${PROJECT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.cov.input.txt
		#    CONTENT $<TARGET_PROPERTY:coverage_report,OPENCCOV_INPUT_FILES>
	    #)
    endif(CPP_COVERAGE_REPORT_FOR_PROJECT)
endfunction()

function(target_code_coverage)
	cmake_parse_arguments(
		TARGET_CODE_COVERAGE
		""
		"TARGET_SOURCES;SOURCE_BASE_DIR" 
		""
		${ARGN}
	)
	message("TARGET_SOURCES=${TARGET_CODE_COVERAGE_TARGET_SOURCES}")
	message("SOURCE_BASE_DIR=${TARGET_CODE_COVERAGE_SOURCE_BASE_DIR}")
	message("ARGN=${ARGN}")

	# https://cmake.org/cmake/help/v3.0/prop_tgt/TYPE.html
	get_target_property(target_type ${TARGET_CODE_COVERAGE_TARGET_SOURCES} TYPE)
	message("TYPE=${target_type}")

	if (${target_type} STREQUAL "INTERFACE_LIBRARY")
		message("Its an INTERFACE_LIBRARY")
	endif()

#	list (GET ARGN 0 COV_TARGET)
#	get_target_property(SOURCE_FILES ${TARGET_CODE_COVERAGE_TARGET_SOURCES} SOURCES)
	#message("SOURCE_FILES: ${SOURCE_FILES}")
	#if(DEFINED TARGET_CODE_COVERAGE_SOURCE_BASE_DIR)
		#get_filename_component(CONVERTED ${SOURCE_FILES} 
		#ABSOLUTE BASE_DIR ${TARGET_CODE_COVERAGE_SOURCE_BASE_DIR})
	#	message("ITS DEFINED")
		#list(TRANSFORM SOURCE_FILES PREPEND "${SOURCE_BASE_DIR}")
		#message("CONVERTED: ${SOURCE_FILES}")

	#endif()
	#list(TRANSFORM SOURCE_FILES PREPEND "${PROJECT_SOURCE_DIR}")
#	add_code_coverage(
#		TARGET ${COV_TARGET}
#		SOURCES ${SOURCE_FILES}
#	)
endfunction()

#########################################################################################
#
# This macro enables a CMake configuration wide target for aggregated code coverage
#
macro(enable_coverage)
	# If target has already been defined do early return (target aggregates all)
	if (TARGET coverage_report)
		return()
	endif()

	# Find OpenCppCoverage on machine (Required)
	find_program(OPENCPPCOVERAGE_FOUND OpenCppCoverage)
	if (OPENCPPCOVERAGE_FOUND)
		message(STATUS "enable_coverage() found OpenCppCoverage tool-chain: ${OPENCPPCOVERAGE_FOUND}")
	else()
		message(FATAL_ERROR "enable_coverage() did not find OpenCppCoverage tool-chain which is required to collect coverage on this platform. Either install OpenCppCoverage or configure CMake to build coverage targets.")
	endif()

	# Add custom target to generate coverage report, it will aggregate all code coverage
	# added by sub-projects following the same custom semantics
	add_custom_target(coverage_report
		#COMMAND ${CMAKE_COMMAND} -E echo "Generating code coverage report..."
		DEPENDS ${CMAKE_BINARY_DIR}/coverage/index.html
		VERBATIM
	)

	# Tell CMake how to to generate code coverage HTML report based on a configuration
	# file dependency.
	add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/coverage/index.html
		COMMAND OpenCppCoverage --verbose
			--continue_after_cpp_exception
			--export_type=html:${CMAKE_BINARY_DIR}/coverage
			--config_file ${CMAKE_BINARY_DIR}/code_coverage_report_input_files.txt
		DEPENDS ${CMAKE_BINARY_DIR}/code_coverage_report_input_files.txt
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		COMMENT "Generating code coverage report: ${CMAKE_BINARY_DIR}/coverage/index.html"
		VERBATIM
	)

	# Generate code coverage configuration file, note that it is not generated until all
	# project CMakeLists.txt files have been processed
	file(GENERATE 
		OUTPUT ${CMAKE_BINARY_DIR}/code_coverage_report_input_files.txt 
		CONTENT $<TARGET_PROPERTY:coverage_report,OPENCCOV_INPUT_FILES>
	)
endmacro()

