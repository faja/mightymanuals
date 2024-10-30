---

# types

## integers
- i8 - signed 8 bit integer: -128 .. +127
- i16 - ..etc
- i32
- i64
- i128
- u8 - unsigned 8 bit integer: 0 .. +255
- u16
- u32
- u64
- u128

- isize - signed integer of a size of a underlying HW used,
- usize - unsigned -||-

## floating-point types
- f32 - floating 32 bit size
- f64 - floating 64 bit size, generally use this one only

## bool
```
let is_welsh: bool = true;
let can_sing: bool = false;
// if you really have to you can convert that to 0 an 1
let is_welsh_num: i32 = is_welsh as i32;
let can_sing_num: i32 = can_sing as i32;
```

### boolean logis
```
&&  // AND
||  // OR
!   // NOT
```

## string
### char
it is a SINGLE character utf8 encoded (might be a emoji)
```
let my_first_name_first_lette: char = 'M';
```

## type conversin
```
let g = 3.99;
let h = g as i32; # convert float to iteger
```

# variables
```rust
// to define a variable
let name: type = value;
```

eg:
```rust
let a1: i32 = -12345;
let a2: i32 = 0xFFFF;   # hex, 0-9A-F
let a3: i32 = 0o177;    # octal, 0-7
let a4: i32 = 0b1110;   # binary, 0-1
let b: u32 = 12345;
let c: isize = 24680;

println!("Numbers are {} {} {} {} {} {}", a1, a2, a3, a4, b, c);
println!("Numbers in reverse order are {5} {4} {3} {2} {1} {0}", a1, a2, a3, a4, b, c);
println!("isize is {} bytes on my machine", std::mem::size_of::<isize>());

let f1: f64 = 1.23456;
println!("Float to 2dp {:.2}", f1);
println!("Left-aligned {:<10.2}", f1);
println!("Right-aligned {:>10.2}", f1);
println!("Left-aligned with tilde {:~<10.2}", f1);
println!("Right-aligned with tilde {:~>10.2}", f1);
```

## mutable variables
```rust
let d = 0;
let mut e = 1;
```

## ignore unused variable
```
let _f = 0;
```

# constants
```
const SECONDS_IN_HOUR; i32 = 3_600;   # must be capital letter and type must be specified
```

# if statement
```rust
if age > 50 { // please note, test expression must be "bool"
  ...;
else if age > 30 {
}
  ...;
else {
  ...;
}

let msg = if age > 50 {"old"} else {"young"};
```

# match statement
```rust
let num = 100;

match num {
    100 => println!("A hundred"),
    200 => {
        println!("Two hundred");
        println!("Two indeed!")
    },
    201..=300 => println!("more than 200"),
    400 | 500 => println!("400 or 500"),
    _   => println!("Something else")
}
```

# loops

```rust
loop {
    // this is infinite loop...
}

let mut i = 0;
while i < 10 {
    // do something
   i += 1;
}

let arr = [99, 55, 95, 100, 82];
for elem in arr {
    println!("{}", elem);
}

for i in 0..10 {
    // 0 to 9,
    // to include 10, 0..=10
    println!("{}", i);
}
```

#  break and continue
loop {
    if some_condition {
        break;
    }
    // do something
}

loop {
    if some_condition {
        continue; // this means actually next
    }
    // do something
}

to break or continue in nested loops use loop labels, eg:
```rust

'outer: loop {
   // ...
   loop {
      // ...
      break 'outer;
   }
}
```

# ENUMS
## basics
```rust
enum Color {
    Red,
    Green,
    Blue
}

let c: Color = Color::Red;

match c {
    Color::Red   => println!("coch"),
    Color::Green => println!("gwyrdd"),
    Color::Blue  => println!("glas"),
}
```

## enum with data
```rust
enum HouseLocation {
  Number(i32),
  Name(String),
  Unknown
}

let h1 = HouseLocation::Number(4);

match h1 {
  HouseLocation::Number(h) => println!("number: {}", s),
  _ => println!("...Unknown"),
}
```

## OPTION enum

```rust
enum Option<T> {
  Some(T),
  None
}

// eg:
fn sec_of_day(h: u32, m: u32, s: u32) -> Option<u32> {
  // ...
  let secs = 42
  return Option::Some(secs)
  // else
  return Option::None
}

secs = sec_of_day(1, 2, 3);
match secs {
  Some(s) => println!("second of day: {}", s),
  None    => println!("second of day: no value")
}
```

## RESULT enum
similar to OPTION

```rust
enum Result<T, E> {
  Ok(T),
  Err(E)
}

// example function retruns Resutl enum
fn .... -> Result<i32, ParseIntError>
// returns Ok or Err
Result::Ok<i32>
Result::Err<ParseIntError>
```
