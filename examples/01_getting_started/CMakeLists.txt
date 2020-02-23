# Library (software under test)
add_library(cpp_coverage_sortlib 
    "src/utils.hpp"
    "src/utils.cpp"
    "src/sortlib.cpp"
)
target_include_directories(cpp_coverage_sortlib PUBLIC "include")
add_definitions(-DCPP_COVERAGE_EXAMPLE_STATIC_LIB)

# Test binary
add_executable(cpp_coverage_example_01_getting_started_test "test/sortlib_test.cpp")
target_link_libraries(cpp_coverage_example_01_getting_started_test PRIVATE cpp_coverage_sortlib)
add_definitions(-DCPP_COVERAGE_EXAMPLE_STATIC_LIB)

add_test(NAME cpp_coverage_example_01_getting_started_test COMMAND cpp_coverage_example_01_getting_started_test )

# This is how code coverage is enabled (creates a target coverage_report which will provide coverage_report)
#enable_coverage()
#add_code_coverage(
#	TARGET cpp_coverage_example_01_getting_started_test
#	SOURCES
#		"${CMAKE_CURRENT_SOURCE_DIR}/src/*"
#		"${CMAKE_CURRENT_SOURCE_DIR}/include/*"
#)

# add_coverage_report(cpp_coverage_sortlib)

# Supporting M:N relationship for test:module
target_coverage(
    TEST_TARGET               # The test target which is exercising the software under test   
        cpp_coverage_example_01_getting_started_test 
    SOURCE_TARGETS            # The source targets to measure while the test target is executed
        cpp_coverage_sortlib
    REPORT_FOR_SOURCE_TARGET  # Include in source target report
    REPORT_FOR_PROJECT        # Include in project report
)

# Consider detecting source targets via dependencies?! But this will fail to test that includes sources directly.... if not comparing...