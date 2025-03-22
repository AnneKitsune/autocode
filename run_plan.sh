#!/bin/sh
# $1 file containing steps of a plan, one per line. each line is a prompt.
# $2 files passed to aider
# $3 optional guidelines file

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}"/lib.sh

$discord_send "### Implementing plan: $1"

task_count="$(wc -l < "$1")"
current_task=0

while read -r task <&3; do
    current_task=$((current_task + 1))
    echo "Implementing task: $task"
    $discord_send "- [$current_task/$task_count] Implementing task: \`$task\`"

    previous_changes="$(git log -n 5 --pretty=format:"%s" | sed 's/autocode: //')"

    "$SCRIPT_DIR"/run.sh "Previous Changes: $previous_changes. Guidelines: $(cat "$3")\nI want you to implement the following task: $task.\nIn addition, make sure that src/lib.rs or src/main.rs contains `mod filename;` for any file (or folder containing the file) you modify." "$2" || exit 1 && \
    git diff -U30 > /tmp/diff && \
    echo "Generating commit message using $WEAK_MODEL..." && \
    "$SCRIPT_DIR"/run_ai.sh "$WEAK_MODEL" "Given the following git diff, write a short commit message explaining the changes. $(cat /tmp/diff)" > /tmp/commit_msg && \
    git add . && \
    git commit -m "autocode: $(tr -d '\n' < /tmp/commit_msg | sed 's/\"/\\\"/g;s/\`//g')"
done 3< "$1"

$discord_send "Done implementing plan: $1"
