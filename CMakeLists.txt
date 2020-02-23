cmake_minimum_required (VERSION 3.8)

# Include CMake utilities -----------------------------------------------------
#include(cmake/compile_options.cmake)

include(cmake/cpp_coverage.cmake)

project(cpp_coverage)

enable_testing()
add_subdirectory(examples)