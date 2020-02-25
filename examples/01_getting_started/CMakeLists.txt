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

# Enable coverage
add_test_coverage(
    TEST_TARGET
        cpp_coverage_example_01_getting_started_test 
    SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/src" 
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
    CONTINUE_AFTER_CPP_EXCEPTION
    VERBOSE
)

# Consider detecting source targets via dependencies?! But this will fail to test that includes sources directly.... if not comparing...