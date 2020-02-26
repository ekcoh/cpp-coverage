# Library (software under test)
add_library(cpp_coverage_extended_sortlib 
    "src/extended_sortlib.cpp"
    "src/mergesort.cpp"
)
target_link_libraries(cpp_coverage_extended_sortlib PRIVATE cpp_coverage_sortlib)
target_include_directories(cpp_coverage_extended_sortlib PUBLIC "include")
add_definitions(-DCPP_COVERAGE_EXAMPLE_STATIC_LIB)

# TODO Fix problem where coverage is not provided for bubblesort when aggregating... should extract sources via dependencies?!
# First test binary (For the sake of example we are adding two separate test binaries covering different parts...)
add_executable(cpp_coverage_example_02_multiple_targets_test1 
    "test/extended_sortlib_test.cpp"
)
target_link_libraries(cpp_coverage_example_02_multiple_targets_test1 
    PRIVATE cpp_coverage_extended_sortlib
)
add_definitions(-DCPP_COVERAGE_EXAMPLE_STATIC_LIB)
add_test(NAME cpp_coverage_example_02_multiple_targets_test1 COMMAND cpp_coverage_example_02_multiple_targets_test1 )

# Second test binary (For the sake of example we are adding two separate test binaries covering different parts...)
add_executable(cpp_coverage_example_02_multiple_targets_test2 
    "src/mergesort.cpp"
    "test/mergesort_test.cpp"
)
target_include_directories(cpp_coverage_example_02_multiple_targets_test2
    PRIVATE "src"
)
target_link_libraries(cpp_coverage_example_02_multiple_targets_test2 
    PRIVATE cpp_coverage_extended_sortlib
)
add_definitions(-DCPP_COVERAGE_EXAMPLE_STATIC_LIB)
add_test(NAME cpp_coverage_example_02_multiple_targets_test2 COMMAND cpp_coverage_example_02_multiple_targets_test2 )

# Add coverage for first test binary
add_test_coverage(
    TEST_TARGET
        cpp_coverage_example_02_multiple_targets_test1 
    SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/src" 
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
    CONTINUE_AFTER_CPP_EXCEPTION
    REPORT_FOR_PROJECT
    REPORT_FOR_TARGET
)

# Add coverage for second test binary
add_test_coverage(
    TEST_TARGET
         cpp_coverage_example_02_multiple_targets_test2 
    SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/src" 
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
    CONTINUE_AFTER_CPP_EXCEPTION
    REPORT_FOR_PROJECT
    REPORT_FOR_TARGET
)
