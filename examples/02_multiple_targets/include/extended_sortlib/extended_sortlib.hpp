#ifndef CPP_COVERAGE_EXAMPLE_EXTENDED_SORTLIB_HPP
#define CPP_COVERAGE_EXAMPLE_EXTENDED_SORTLIB_HPP

#ifdef _WIN32
#define CPP_COVERAGE_EXAMPLE_CALL __cdecl
#ifdef CPP_COVERAGE_EXAMPLE_STATIC_LIB
#define CPP_COVERAGE_EXAMPLE_API
#else
#ifdef CPP_COVERAGE_EXAMPLE_EXPORTING
#define CPP_COVERAGE_EXAMPLE_API __declspec( dllexport )
#else
#define CPP_COVERAGE_EXAMPLE_API __declspec( dllimport )
#endif /* CPP_COVERAGE_EXAMPLE_EXPORTING */
#endif /* CPP_COVERAGE_EXAMPLE_STATIC_LIB */
#elif __GNUC__ >= 4
#define CPP_COVERAGE_EXAMPLE_API __attribute__((visibility("default")))
#define CPP_COVERAGE_EXAMPLE_CALL
#else
#define CPP_COVERAGE_EXAMPLE_API
#define CPP_COVERAGE_EXAMPLE_CALL
#endif /* _WIN32 */

enum class algorithm
{
    quicksort,
    mergesort,
    bubblesort
};

CPP_COVERAGE_EXAMPLE_API  void
CPP_COVERAGE_EXAMPLE_CALL sort(int* arr, int low, int high, algorithm alg);


#endif // CPP_COVERAGE_EXAMPLE_EXTENDED_SORTLIB_HPP