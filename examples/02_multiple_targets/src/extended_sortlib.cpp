#include <extended_sortlib/extended_sortlib.hpp>
#include "mergesort.hpp"
#include <sortlib/sortlib.hpp>

CPP_COVERAGE_EXAMPLE_API  void
CPP_COVERAGE_EXAMPLE_CALL sort(int* arr, int low, int high, algorithm alg)
{
    switch (alg)
    {
    case algorithm::bubblesort:
        bubblesort(arr, low, high);
        break;
    case algorithm::mergesort:
        mergesort(arr, low, high);
        break;
    case algorithm::quicksort:
    default:
        quicksort(arr, low, high);
    }
}