# cpp-coverage

## Introduction
CMake functions to provide C++ code coverage reports in an easy way using [OpenCppCoverage](https://github.com/OpenCppCoverage/OpenCppCoverage).

## Usage

To use cpp-coverage to simplify usage of OpenCppCoverage all you need to do is to make sure cpp-coverage is available to your build by fetching it, using external-project_add, use submodule or download it. Then make sure cpp-coverage is added to your build by adding it as a subdirection and finally use 'add_test_coverage' function to add test coverage to existing test binaries. The utility functions will create custom targets to generate coverage (.cov) files as well as generate coverage reports (e.g. HTML). Coverage reports default to aggregated project coverage but additional options exist to for example also generate reports per test target. See /cmake/cpp_coverage.cmake documentation for full list of options.

```
# CMakeLists.txt
...

# (!) Fetch cpp-coverage (can be done many ways, this is one way...)
FetchContent_Declare(cpp_coverage
  GIT_REPOSITORY https://github.com/ekcoh/cpp-coverage.git
  GIT_TAG        release-0.1.0
)
FetchContent_GetProperties(cpp_coverage)
if(NOT cpp_coverage_POPULATED)
  FetchContent_Populate(cpp_coverage)
  add_subdirectory(${cpp_coverage_SOURCE_DIR} ${cpp_coverage_BINARY_DIR})
endif()

...
# Build project targets (as usual)
add_library(target_under_test ...)
...

# Create test executable (as usual)
add_executable( my_test_target "test/my_test_target.cpp" )
target_link_libraries( my_test_target PRIVATE target_under_test )

# Add test target to CMake tests (as usual)
add_test( NAME my_test_target COMMAND my_test_target )

# (!) Add test coverage to project (using convenience CMake function provided by cpp-coverage)
add_test_coverage(
    TEST_TARGET 
        my_test_target 
    SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/src" 
    CONTINUE_AFTER_CPP_EXCEPTION
)
...
```

For complete examples, see /examples folder. Examples are not built by default and requires CPP_COVERAGE_BUILD_EXAMPLES to be set to ON.

See [OpenCppCoverage documentation](https://github.com/OpenCppCoverage/OpenCppCoverage/wiki) 
for details on how to use and integrate in CI etc.

