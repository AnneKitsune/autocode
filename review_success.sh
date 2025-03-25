#!/bin/sh

# The manual review passed. This will merge the feature branch into main.
# $1 is the feature branch name

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}"/lib.sh

BRANCH="$1"

git checkout main
if [[ -z "$(git branch --list "$BRANCH")" ]]; then
    echo "Branch $BRANCH does not exist. Aborting..."
    exit 1
fi
if git merge --no-ff "$BRANCH" -m "automerge: $BRANCH"; then
    # Merge succeeded
    if "${SCRIPT_DIR}"/test_rust.sh; then
        git branch -d "$BRANCH"
        git push origin --delete "$BRANCH"
        git push origin main
        echo "Merge of $BRANCH successful."
        $discord_send "### Merge of $BRANCH successful."
        exit 0
    else
        echo "Merge of $BRANCH successful, but tests failed."
        $discord_send "### Merge of $BRANCH successful, but tests failed."
    fi
else
    # Merge failed - resolve conflicts
    echo "Merge conflict detected in $BRANCH. Attempting AI resolution."
    $discord_send "### Merge conflict detected in $BRANCH. Attempting AI resolution."
    conflict_files="$(git diff --name-only)"

    # Resolve conflicts using AI
    if "${SCRIPT_DIR}"/run.sh "Fix all the git merge conflicts in the provided files." "$conflict_files"; then
        # resolved
        if "${SCRIPT_DIR}"/test_rust.sh; then
            git add .
            git commit -m "airesolve: Resolved conflicts merging $BRANCH"
            git branch -D "$BRANCH"
            git push origin main
            $discord_send "### Merge of $BRANCH successful following AI git merge."
            exit 0
        else
            $discord_send "### Merge of $BRANCH successful following AI git merge. However, tests are failing."
            exit 0
        fi
    else
        # failed
        echo "AI resolution failed - manual intervention required"
        $discord_send "### Merge of $BRANCH into main failed. AI failed to fix git merge. Manual intervention required."
        git merge --abort
        git checkout "$BRANCH"
        exit 1
    fi
fi

