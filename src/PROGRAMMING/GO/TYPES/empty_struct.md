---

empty struct is a type in go it is written like `struct{}`
so a value of that type is `struct{}{}`

a bit weird notation but that's how its done

```go
var my_es_var struct{}
//               ^
//          this is a type
// my_es_var will be a zero value of an empty struct type

my_another_es_var := struct{}{}
//                     ^      ^
//                     |      |
//        struct{} is a type  |
//           part             |
//                     this is a value part
//
// similar to if you would declare and initialize an int array
// [3]int{1, 2, 3}
```
