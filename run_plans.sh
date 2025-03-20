#!/bin/sh

# Check for correct number of arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 \"<plan_files>\" [/path/to/guidelines.md]"
    exit 1
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}"/lib.sh

plan_files="$1"
guidelines="$2"
plan_count="$(echo "$plan_files" | wc -w)"

$discord_send "# Starting to implement $(pwd). Plans queued: $plan_count"

current_plan=0
successes=0
success_plans=""
failed_plans=""

for file in $plan_files; do
    current_plan=$((current_plan + 1))

    # Verify plan file exists
    if [ ! -f "$file" ]; then
        echo "Error: Plan file '$file' not found. Skipping..."
        continue
    fi

    # Step 1: Extract plan name from filename
    file_basename="$(basename "$file")"
    plan_name="${file_basename%.*}"

    # Step 2: Create and checkout new branch
    if ! git checkout -b "$plan_name" >/dev/null 2>&1; then
        echo "Branch '$plan_name' already exists. Reusing..."
        git checkout "$plan_name"
    fi

    # Step 3: List files not excluded by gitignore
    files_list="$(git ls-files --cached --others --exclude-standard)"

    # Step 4: Generate AI query and get files to modify
    tasks="$(cat "$file")"
    query="Guidelines: $guidelines Plan: $plan_name Tasks: $tasks Files present: $files_list Please return a space-separated list of files that need to be modified to implement this plan and nothing else. You may specify files not in the input list and they will be created, if appropriate. Also include files that you think contain information necessary to implement the tasks. Always include src/lib.rs if writing a library and src/main.rs if writing an executable, but never include both at the same time. Never create tests.rs files or a tests directory."

    files_to_modify="$(run_ai "$WEAK_MODEL" "$query" | sed '/```*/d')"

    # Step 5: Execute run_plan.sh
    "$SCRIPT_DIR/run_plan.sh" "$file" "$files_to_modify" "$guidelines"
    run_plan_exit=$?

    # Step 6: Return to main branch
    git checkout main >/dev/null 2>&1

    # Step 7: Handle success/failure
    if [ $run_plan_exit -ne 0 ]; then
        failed_plans="$failed_plans\n$plan_name"
        git branch -D "$plan_name" >/dev/null 2>&1
        echo "[$current_plan/$plan_count] Failed to implement $plan_name in $(pwd)"
        $discord_send "[$current_plan/$plan_count] Failed to implement $plan_name in $(pwd)"
    else
        success_plans="$success_plans\n$plan_name"
        successes=$((successes + 1))
        echo "[$current_plan/$plan_count] Successfully implemented $plan_name in $(pwd)"
        $discord_send "[$current_plan/$plan_count] Successfully implemented $plan_name in $(pwd)"
    fi
done

$discord_send "### Implemented $successes out of $plan_count. Successes: $success_plans\nFailures: $failed_plans"

$discord_send "### Pending Review ($(pwd))\n$success_plans"
