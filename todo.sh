#!/bin/sh

# Modify the todo.md file in the current directory.
# $1 request

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}"/lib.sh

aider --config "$AIDER_CONFIG" -m "Do not create new files. Modify the provided todo.md file to reflect the following request: $1" --model "$STRONG_MODEL" todo.md

