#include <sub_project/sub_project.hpp>

CPP_COVERAGE_EXAMPLE_API  int
CPP_COVERAGE_EXAMPLE_CALL non_zero_if_even(int x)
{
    if (x % 2 == 0)
        return 1;
    return 0;
}