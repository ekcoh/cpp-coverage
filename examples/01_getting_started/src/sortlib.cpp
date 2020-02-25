#include <iostream>

#include <sortlib/sortlib.hpp>

/* C++ implementation of QuickSort */
//#include <bits/stdc++.h> 
using namespace std;

void swap(int* a, int* b)
{
    int t = *a;
    *a = *b;
    *b = t;
}

int partition(int arr[], int low, int high)
{
    int pivot = arr[high];
    int i = (low - 1); 

    for (int j = low; j <= high - 1; j++)
    {
        if (arr[j] < pivot)
        {
            i++; 
            swap(&arr[i], &arr[j]);
        }
    }
    swap(&arr[i + 1], &arr[high]);
    return (i + 1);
}

void CPP_COVERAGE_EXAMPLE_CALL quicksort(int* arr, int low, int high)
{
    if (low < high)
    {
        int pi = partition(arr, low, high);
        quicksort(arr, low, pi - 1);
        quicksort(arr, pi + 1, high);
    }
}

void CPP_COVERAGE_EXAMPLE_CALL bubblesort(int* arr, int low, int high)
{
    // Not tested in module-reated test, but covered from 02_multiple_targets
    if (low < high)
    {
        for (auto i = low; i <= high - 1; ++i)
        {
            for (auto j = i + 1; j <= high; ++j)
            {
                if (arr[i] > arr[j])
                    swap(&arr[i], &arr[j]);
            }
        }
    }
}

void CPP_COVERAGE_EXAMPLE_CALL uncovered()
{
    std::cout << "This function is never called from any test\n";
}