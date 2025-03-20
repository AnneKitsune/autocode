#!/bin/sh

# shared variables

export WEAK_MODEL="qwen_coder"
export WEAK_MODEL_URL=""
export STRONG_MODEL="qwq"
export STRONG_MODEL_URL=""
export CLASSIFIER_MODEL="qwen_coder"
export CLASSIFIER_MODEL_URL=""
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export discord_send="/home/anne/discord_send.sh"
export AIDER_CONF="${SCRIPT_DIR}/aider.conf.yml"

export OPENAI_API_BASE="http://ai3:8080/v1"
export OPENAI_API_KEY="empty"

run_ai() {
    # $1 model
    # $2 request
    "${SCRIPT_DIR}"/prompt.sh "http://ai3:8080" "$1" "$2" "$OPENAI_API_KEY"
}
