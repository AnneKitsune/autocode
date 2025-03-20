#!/bin/sh

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}"/lib.sh

# The manual review failed and we should apply changes.
# $1 is the branch name
# $2 is a file containing the review comments.
# $3 is guidelines (optional)

$discord_send "# Implementing manual review for branch $1"

# First, we take the review comments and create a plan file from it.
run_ai "$STRONG_MODEL" "You will be given review comments. Your job is to create a list of tasks (ai prompts) that will be fed to a programmer AI. You should write one prompt per line. You should include precise details to help the programmer AI have the necessary context. This context should be on the same line as the prompt. You should output the list within html tags like this: <tasks>\ninstructions. additional context and instructions.\ninstructions. additional context and instructions.\n</tasks>. Here is the review file you need to translate into the list of tasks / prompts: $(cat "$2")" > /tmp/ai_plan_raw.txt

sed -n '/<tasks>/,/<\/tasks>/p' /tmp/ai_plan_raw.txt | sed 's/<tasks>/d;s/<\/tasks>/d' > /tmp/"$1".txt

# Then, we go onto the feature branch.
git checkout "$1"
# We ask run_plans.sh to implement the generated plan.
if ! "${SCRIPT_DIR}"/run_plans.sh "/tmp/$1.txt" "$3"; then
    echo "Failed to implement review changes."
    $discord_send "# Failed to implement requested review changes in $1"
    exit 1
fi
# We ask for a new round of manual review if it succeeds.
$discord_send "# Successfully implemented requested review changes in $1.\nReview the code manually.\nIf satisfied, run review_success.sh branch_name.\nIf not satisfied, write requested changes in a file and run review_failed.sh branch_name review_comments.txt path/to/guidelines.md."

# Potential issue with the workflow: going through three rounds of review and it fails to implement a request, which then deletes the branch.
