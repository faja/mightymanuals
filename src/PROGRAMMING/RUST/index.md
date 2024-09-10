---
# install
```sh
# https://www.rust-lang.org/tools/install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update

rustup component add rust-analyzer  # add rust-analyzer
```

# basic cargo usage
```sh
cargo build            # build an app in debug mode
cargo build --release  # build an app in release mode

cargo run              # build and run an app in debug mode
cargo run --release    # build and run an app in release mode

cargo check            # does not build an app, just do some sanity checking
```

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

## 

# variables
```rust
// to define a variable
let name: type = value;
```

eg:
```rust
let a1: i32 = -12345;
let a2: i32 = 0xFFFF;   # hex
let a3: i32 = 0o177;    #
let a4: i32 = 0b1110;   # 
let b: u32 = 12345;
let c: isize = 24680;

println!("Numbers are {} {} {} {} {} {}", a1, a2, a3, a4, b, c);
println!("Numbers in reverse order are {5} {4} {3} {2} {1} {0}", a1, a2, a3, a4, b, c);
println!("isize is {} bytes on my machine", std::mem::size_of::<isize>());
```