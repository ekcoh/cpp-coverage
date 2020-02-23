#include <extended_sortlib/extended_sortlib.hpp>

// Merge sort 
void merge(int *arr, int low, int high, int mid)
{
    int i, j, k, c[50];
    i = low;
    k = low;
    j = mid + 1;
    while (i <= mid && j <= high) {
        if (arr[i] < arr[j]) {
            c[k] = arr[i];
            k++;
            i++;
        }
        else {
            c[k] = arr[j];
            k++;
            j++;
        }
    }
    while (i <= mid) {
        c[k] = arr[i];
        k++;
        i++;
    }
    while (j <= high) {
        c[k] = arr[j];
        k++;
        j++;
    }
    for (i = low; i < k; i++) {
        arr[i] = c[i];
    }
}

/* l is for left index and r is right index of the
   sub-array of arr to be sorted */
void mergesort(int arr[], int l, int r)
{
    if (l < r) {
        //divide the array at mid and sort independently using merge sort
        int mid = (l + r) / 2;
        mergesort(arr, l, mid);
        mergesort(arr, mid + 1, r);
        //merge or conquer sorted arrays
        merge(arr, l, r, mid);
    }
}