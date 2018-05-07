#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TEST_BAUX_TEST_SOURCED -eq 1 ]] && return
declare -gr TEST_BAUX_TEST_SOURCED=1
declare -gr TEST_BAUX_TEST_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$TEST_BAUX_TEST_ABS_DIR/../../lib/test.sh"

contruct_test_script() {
    echo "#! /usr/bin/env/bash
source $TEST_BAUX_TEST_ABS_DIR/../../lib/test.sh
test_baux_subtest() {
    $1
}
"
}

contruct_notest_script() {
    echo "#! /usr/bin/env/bash
source $TEST_BAUX_TEST_ABS_DIR/../../lib/test.sh
baux_subtest() {
    $1
}
"
}

contruct_not_shell_script() {
    echo "
source $TEST_BAUX_TEST_ABS_DIR/../../lib/test.sh
baux_subtest() {
    $1
}
"
}

test_baux_test() {
    # setup and teardown
    tmp=$(mktemp "tmp-XXXXXX.sh")
    tmp_dir=$(mktemp -d "tmp-dir-XXXXXXXX")
    old_path="$PATH"
    export PATH="$PATH:$TEST_BAUX_TEST_ABS_DIR/../../lib-exec"
    trap 'rm -rf $tmp $tmp_dir; export PATH=$old_path' RETURN EXIT SIGINT

    # test file
    run_ok "\$status -eq 1" baux-test.sh
    contruct_not_shell_script "true" >"$tmp"
    run_ok "\$status -eq 1" baux-test.sh "$tmp"
    contruct_notest_script "true" >"$tmp"
    run_ok "\$status -eq 1" baux-test.sh "$tmp"
    contruct_test_script "true" >"$tmp"
    run_ok "\$status -eq 0" baux-test.sh "$tmp"
    contruct_test_script "is 0 0" >"$tmp"
    run_ok "\$output =~ PASS.*:\\ 1" baux-test.sh "$tmp"
    contruct_test_script "is 1 0" >"$tmp"
    run_ok "\$output =~ FAIL.*:\\ 1" baux-test.sh "$tmp"
    contruct_test_script "is 0 0; is 1 0" >"$tmp"
    run_ok "\$output =~ PASS.*:\\ 1.*FAIL.*:\\ 1" baux-test.sh "$tmp"

    # test dir
    run_ok "\$status -eq 1" baux-test.sh "$tmp_dir"
    contruct_test_script "is 0 0" >"$tmp"
    cp "$tmp" "$tmp_dir"
    run_ok "\$status -eq 0" baux-test.sh "$tmp_dir"
}

run_tests() {
    test_baux_test
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && run_tests "$@" && summary

# vim:set ft=sh ts=4 sw=4:
