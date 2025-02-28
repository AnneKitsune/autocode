#!/bin/sh
# $1 file containing steps of a plan, one per line. each line is a prompt.
# $2 files passed to aider

while read -r task <&3; do
    echo "Implementing task: $task" && \
    /home/anne/share/prog/tools/autocode2/run.sh "$task" "$2" && \
    git add . && \
    git commit -m "implement"
done 3< "$1"

