#!/bin/sh
# $1 file containing steps of a plan, one per line. each line is a prompt.
# $2 files passed to aider
# $3 optional guidelines file

WEAK_MODEL="qwen_anne"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
discord_send="/home/anne/share/utils/discord_send.sh"

$discord_send "### Implementing plan: $1"

task_count="$(wc -l < "$1")"
current_task=0

while read -r task <&3; do
    current_task=$((current_task + 1))
    echo "Implementing task: $task"
    $discord_send "- [$current_task/$task_count] Implementing task: \`$task\`"

    "$SCRIPT_DIR"/run.sh "Guidelines: $(cat "$3") I want you to implement the following task: $task. In addition, make sure that src/lib.rs or src/main.rs contains mod filename for any file (or folder containing the file) you modify." "$2" || exit 1 && \
    git diff -U30 > /tmp/diff && \
    echo "Generating commit message using $WEAK_MODEL..." && \
    ollama run "$WEAK_MODEL" "Given the following git diff, write a short commit message explaining the changes. $(cat /tmp/diff)" > /tmp/commit_msg && \
    git add . && \
    git commit -m "autocode: $(tr -d '\n' < /tmp/commit_msg | sed 's/\"/\\\"/g;s/\`//g')"
done 3< "$1"

$discord_send "Done implementing plan: $1"
