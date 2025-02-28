#!/bin/sh
rustup default stable
rm -rf /tmp/aitest
cd /tmp
cargo new --lib aitest
cd aitest
git add .
git commit -m 'init'
