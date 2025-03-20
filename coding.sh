#!/bin/sh
# $1 model
# $2 prompt
# $3 files

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. "${SCRIPT_DIR}"/lib.sh

aider $3 -c "$AIDER_CONF" -m "$2 Do not create new files." --model "$1"
fix_runs=5
test_exit=0

timeout -v 10s "$SCRIPT_DIR"/test_rust.sh 2>&1 | tee /tmp/rustoutput
test_exit=$(cat /tmp/exitcode)
success=1

if [ $test_exit -eq 0 ]; then
    echo "Tests Passed"
    success=0
else
    while [ $fix_runs -gt 0 ]; do
        echo "Tests did not pass."

        # prevent feeding links to aider, which would try to install playwright.
        sed -i 's/https//g;s/http//g' /tmp/rustoutput
        #aider src/lib.rs -m "Original prompt: $prompts \nErrors: $(cat /tmp/rustoutput). Fix the previous errors. Do not create new files."
        aider $3 -c "$AIDER_CONF" -m "Original prompt: $2. Errors: $(cat /tmp/rustoutput). Fix the previous errors. Do not create new files." --model "$1"
        timeout -v 10s "$SCRIPT_DIR"/test_rust.sh 2>&1 | tee /tmp/rustoutput
        test_exit=$(cat /tmp/exitcode)
        if [ $test_exit -eq 0 ]; then
            fix_runs=0
            success=0
        else
            fix_runs=$((fix_runs - 1))
        fi
    done
fi

exit $success
