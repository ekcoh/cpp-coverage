#include <mergesort.hpp>

bool mergesort__should_sort_values_in_ascending_order__if_full_range_is_specified()
{
    // arrange
    int arr[] = { 7, 2, 8, 1, 3 };

    // act
    mergesort(arr, 0, 4);

    // assert
    return arr[0] == 1 && arr[1] == 2 && arr[2] == 3 && arr[3] == 7 && arr[4] == 8;
}

bool mergesort__should_sort_sub_range_of_values_in_ascending_order__if_valid_subrange_is_specified()
{
    // arrange
    int arr[] = { 7, 2, 8, 1, 3 };

    // act
    mergesort(arr, 2, 4);

    // assert
    return arr[0] == 7 && arr[1] == 2 && arr[2] == 1 && arr[3] == 3 && arr[4] == 8;
}

int main(int, char**)
{
    auto success =
        mergesort__should_sort_values_in_ascending_order__if_full_range_is_specified() &&
        mergesort__should_sort_sub_range_of_values_in_ascending_order__if_valid_subrange_is_specified();
    return success ? 0 : 1;
}