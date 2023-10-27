In C, when you create an array using the bracket syntax, it will be allocated at compile-time. Where this array is stored depends on where you declare it.

statically allocated at COMPILE TIME!!
```c
int numbers[10];
```

as opposed to just mallocing the array.
this is the technical reason why bracket arrays work so nice in C.


int arr[10]; // This is globally declared, so it's in the static storage area.

void func() {
  static int staticArr[10]; // This is also in the static storage area.
}
