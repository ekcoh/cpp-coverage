#include <gtest/gtest.h>

#include <sub_project/sub_project.hpp>

TEST(subproject_test, non_zero_if_even__should_return_non_zero__if_arg_is_even)
{
    int r = non_zero_if_even(4);
    EXPECT_TRUE(r != 0);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}