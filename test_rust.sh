#!/bin/sh
RUST_BACKTRACE=1 cargo test && cargo clippy -- -D warnings && cargo bench
#RUST_BACKTRACE=1 cargo test && cargo bench
echo "$?" > /tmp/exitcode


