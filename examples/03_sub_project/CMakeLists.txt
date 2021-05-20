project(cpp_coverage_sub_project)

# Library (software under test)
add_library(cpp_coverage_sub_project 
    "src/sub_project.cpp"
)
target_include_directories(cpp_coverage_sub_project PUBLIC "include")
add_definitions(-DCPP_COVERAGE_EXAMPLE_STATIC_LIB)

# Test binary
add_executable(cpp_coverage_example_03_sub_project_test "test/sub_project_test.cpp")
target_link_libraries(cpp_coverage_example_03_sub_project_test PRIVATE cpp_coverage_sub_project gtest)
add_definitions(-DCPP_COVERAGE_EXAMPLE_STATIC_LIB)

# Add test with coverage if coverage is enabled
cpp_coverage_add_test_coverage(
    TARGET
        cpp_coverage_example_03_sub_project_test 
    TARGET_ARGS
        --gtest_output=xml:cpp_coverage_example_03_sub_project_test.output.xml
    MODULES
        ${CMAKE_BINARY_DIR}
    SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/src" 
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
    CONTINUE_AFTER_CPP_EXCEPTION
    REPORT_FOR_GLOBAL
    REPORT_FOR_PROJECT
    REPORT_FOR_TARGET
)
