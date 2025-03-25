#!/bin/sh
#RUST_BACKTRACE=1 cargo test && cargo clippy -- -D warnings && cargo bench
cargo clippy --fix --allow-dirty
cargo fmt
RUST_BACKTRACE=1 cargo test --all
#RUST_BACKTRACE=1 cargo test && cargo bench
echo "$?" > /tmp/exitcode


