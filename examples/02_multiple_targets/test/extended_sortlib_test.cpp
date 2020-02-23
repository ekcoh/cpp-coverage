#include <extended_sortlib/extended_sortlib.hpp>

bool sort_test(algorithm alg)
{
    // arrange
    int arr[] = { 7, 2, 8, 1, 3 };

    // act
    sort(arr, 0, 4, alg);

    // assert
    return arr[0] == 1 && arr[1] == 2 && arr[2] == 3 && arr[3] == 7 && arr[4] == 8;
}

bool mergesort__should_sort_values_in_ascending_order__if_algorithm_is_quicksort()
{
    return sort_test(algorithm::quicksort);
}

bool mergesort__should_sort_values_in_ascending_order__if_algorithm_is_mergesort()
{
    return sort_test(algorithm::mergesort);
}

bool mergesort__should_sort_values_in_ascending_order__if_algorithm_is_bubblesort()
{
    return sort_test(algorithm::bubblesort);
}

int main(int, char**)
{
    auto success =
        mergesort__should_sort_values_in_ascending_order__if_algorithm_is_quicksort() &&
        mergesort__should_sort_values_in_ascending_order__if_algorithm_is_mergesort() &&
        mergesort__should_sort_values_in_ascending_order__if_algorithm_is_bubblesort();
    return success ? 0 : 1;
}