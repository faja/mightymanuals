
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
