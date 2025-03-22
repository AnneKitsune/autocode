#!/bin/sh

# $1 model
# $2 request

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}"/lib.sh

"$SCRIPT_DIR"/prompt.sh "http://ai3:8080" "$1" "$2" "$OPENAI_API_KEY"
