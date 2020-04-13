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
target_link_libraries(cpp_coverage_example_01_getting_started_test PRIVATE cpp_coverage_sortlib gtest)
add_definitions(-DCPP_COVERAGE_EXAMPLE_STATIC_LIB)

# Add test with coverage if coverage is enabled
cpp_coverage_add_test_coverage(
    TARGET
        cpp_coverage_example_01_getting_started_test 
    TARGET_ARGS
        --gtest_output=xml:cpp_coverage_example_01_getting_started_test.output.xml 
        > cpp_coverage_example_01_getting_started_test.output.txt
    SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/src" 
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
    CONTINUE_AFTER_CPP_EXCEPTION
    REPORT_FOR_PROJECT
    REPORT_FOR_TARGET
    QUIET
)
