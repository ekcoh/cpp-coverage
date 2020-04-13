#include <gtest/gtest.h>

#include <sortlib/sortlib.hpp>

TEST(sortlib_test, quicksort__should_sort_values_in_ascending_order__if_full_range_is_specified)
{
    int arr[] = { 7, 2, 8, 1, 3 }; // arrange
    quicksort(arr, 0, 4);          // act
    ASSERT_EQ(arr[0], 1);          // assert...
    ASSERT_EQ(arr[1], 2);
    ASSERT_EQ(arr[2], 3);
    ASSERT_EQ(arr[3], 7);
    ASSERT_EQ(arr[4], 8);
}

TEST(sortlib_test, quicksort__should_sort_sub_range_of_values_in_ascending_order__if_valid_subrange_is_specified)
{
    int arr[] = { 7, 2, 8, 1, 3 }; // arrange
    quicksort(arr, 2, 4);          // act
    ASSERT_EQ(arr[0], 7);          // assert...
    ASSERT_EQ(arr[1], 2);
    ASSERT_EQ(arr[2], 1);
    ASSERT_EQ(arr[3], 3);
    ASSERT_EQ(arr[4], 8);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}