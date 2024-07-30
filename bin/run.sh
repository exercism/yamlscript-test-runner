#!/usr/bin/env bash

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: path to solution folder
# $3: path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output
# directory.
# The test results are formatted according to the specifications at
# https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit:
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then
    echo 'usage: ./bin/run.sh exercise-slug ' \
         'path/to/solution/folder/ path/to/output/directory/'
    exit 1
fi

slug=$1
solution_dir=$(realpath "${2%/}")
output_dir=$(realpath "${3%/}")
results_file=$output_dir/results.json

# Create the output directory if it doesn't exist:
mkdir -p "$output_dir"

echo "
=== $slug =====================================================================
"

# Run the tests for the provided implementation file and redirect stdout and
# stderr to capture it:
test_output=$(
  make --no-print-dir -C "$solution_dir" test 2>&1 |
    tail -n+2 |
    perl -p0e 's/\nmake.*: \*\*\*.*//s'
)

# Write the results.json file based on the exit code of the command that was
# just executed that tested the implementation file:

if [[ $test_output = *'All tests successful.' ]]; then
    jq -n --arg output "$test_output" \
       '{version: 1, status: "pass", message: $output}' \
       > "$results_file"
elif (echo "$test_output" | grep -q '^  Failed tests: '); then
    jq -n --arg output "$test_output" \
       '{version: 1, status: "fail", message: $output}' \
       > "$results_file"
    # OPTIONAL: Sanitize the output
    # In some cases, the test output might be overly verbose, in which case
    # stripping the unneeded information can be very helpful to the student
    # test_output=$(printf "$test_output" | sed -n '/Test results:/,$p')

    # OPTIONAL: Manually add colors to the output to help scanning the
    # output for errors If the test output does not contain colors to help
    # identify failing (or passing) tests, it can be helpful to manually
    # add colors to the output.
    # colorized_test_output=$(echo "$test_output" |
    #   GREP_COLOR='01;31' grep --color=always -E \
    #     -e '^(ERROR:.*|.*failed)$|$' |
    #   GREP_COLOR='01;32' grep --color=always -E -e '^.*passed$|$')
else
    jq -n --arg output "$test_output" \
      '{version: 1, status: "error", message: $output}' \
      > "$results_file"
fi
