#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TEST_TEST_SOURCED -eq 1 ]] && return
declare -gr TEST_TEST_SOURCED=1
declare -gr TEST_TEST_ABS_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "$TEST_TEST_ABS_DIR/../../lib/test.sh"

get_section() {
    local section=$1
    local file=$2

    awk '/#####'"$section"'-start/, /#####'"$section"'-end/ \
        { if ($0 !~ /#####/ && $0 !~ /^\s*$/) print $0 }' "$file"
}

test_test() {
    setup() {
        tmp=$(mktemp)
    }; setup

    teardown() {
        rm -rf "$tmp"
    }; trap 'teardown' RETURN EXIT SIGINT

    subtest "test ok" "{
        old_ifs=\$IFS
        IFS=$'\\n'

        # ensure ok
        for line in \$(get_section OK $TEST_TEST_ABS_DIR/test-ensure-ok.txt); do
            run_ok '\$status -eq 0' ok \"\$line\"
        done

        # ensure fail
        for line in \$(get_section FAIL $TEST_TEST_ABS_DIR/test-ensure-ok.txt); do
            run_ok '\$status -eq 1' ok \"\$line\"
        done

        IFS=\$old_ifs
    }"

    subtest "test is" "{
        # OK
        run_ok '\$status -eq 0' is '' ''
        run_ok '\$status -eq 0' is ' ' ' '
        run_ok '\$status -eq 0' is 'test' 'test'
        run_ok '\$status -eq 0' is 'test ' 'test '
        run_ok '\$status -eq 0' is ' test' ' test'
        run_ok '\$status -eq 0' is ' test ' ' test '

        # fail
        run_ok '\$status -eq 1' is '' ' '
        run_ok '\$status -eq 1' is 'test' 'Test'
        run_ok '\$status -eq 1' is 'test' 'test '
        run_ok '\$status -eq 1' is ' test' 'test'
    }"

    subtest "test isnt" "{
        # OK
        run_ok '\$status -eq 0' isnt '' ' '
        run_ok '\$status -eq 0' isnt 'test' 'Test'
        run_ok '\$status -eq 0' isnt 'test' ' test'
        run_ok '\$status -eq 0' isnt 'test' 'test '
        run_ok '\$status -eq 0' isnt 'test' ' test '

        # fail
        run_ok '\$status -eq 1' isnt '' ''
        run_ok '\$status -eq 1' isnt ' ' ' '
        run_ok '\$status -eq 1' isnt 'test' 'test'
        run_ok '\$status -eq 1' isnt 'test ' 'test '
        run_ok '\$status -eq 1' isnt ' test' ' test'
        run_ok '\$status -eq 1' isnt ' test ' ' test '

    }"

    subtest "test like" "{
        # OK
        run_ok '\$status -eq 0' like '' ''
        run_ok '\$status -eq 0' like ' ' ''
        run_ok '\$status -eq 0' like 'test' ''
        run_ok '\$status -eq 0' like 'test' 'te'
        run_ok '\$status -eq 0' like 'test' 'st'
        run_ok '\$status -eq 0' like 'test' 'test'
        run_ok '\$status -eq 0' like 'test' '.*'
        run_ok '\$status -eq 0' like 'test' 'te.*'
        run_ok '\$status -eq 0' like 'test' '.*st'

        # fail
        run_ok '\$status -eq 1' like '' ' '
        run_ok '\$status -eq 1' like '' 'a'
        run_ok '\$status -eq 1' like 'test' ' '
        run_ok '\$status -eq 1' like 'test' 'Test'
        run_ok '\$status -eq 1' like 'test' ' test'
        run_ok '\$status -eq 1' like 'test' '^est'
        run_ok '\$status -eq 1' like 'test' 'tes$'
    }"

    subtest "test unlike" "{
        # OK
        run_ok '\$status -eq 0' unlike '' ' '
        run_ok '\$status -eq 0' unlike '' 'a'
        run_ok '\$status -eq 0' unlike 'test' ' '
        run_ok '\$status -eq 0' unlike 'test' 'Test'
        run_ok '\$status -eq 0' unlike 'test' ' test'
        run_ok '\$status -eq 0' unlike 'test' '^est'
        run_ok '\$status -eq 0' unlike 'test' 'tes$'

        # fail
        run_ok '\$status -eq 1' unlike '' ''
        run_ok '\$status -eq 1' unlike ' ' ''
        run_ok '\$status -eq 1' unlike 'test' ''
        run_ok '\$status -eq 1' unlike 'test' 'te'
        run_ok '\$status -eq 1' unlike 'test' 'st'
        run_ok '\$status -eq 1' unlike 'test' 'test'
        run_ok '\$status -eq 1' unlike 'test' '.*'
        run_ok '\$status -eq 1' unlike 'test' 'te.*'
        run_ok '\$status -eq 1' unlike 'test' '.*st'
    }"

    subtest "test run_ok" "{
        run_ok '\$status -eq 0' run_ok '\$status -eq 0' exit 0
        run_ok '\$status -eq 0' run_ok '\$status -eq 1' exit 1

        run_ok '\$status -eq 1' run_ok '\$status -eq 1' exit 0
        run_ok '\$status -eq 1' run_ok '\$status -eq 0' exit 1
    }"

    subtest "test subtest" "{
        run_ok '\$status -eq 0' subtest 'subtest pass' 'is 0 0'
        run_ok '\$status -eq 1' subtest 'subtest fail' 'is 1 0'
        run_ok '\$status -eq 0' subtest 'subtest skip' 'skip; is 1 0'
        run_ok '\$status -ne 0' subtest 'subtest die' 'echo ><'
    }"

    subtest "test skip & summary" "{
        run_ok '\$status -eq 0' skip

        skip_fail() { skip; is 1 0; summary; }
        run_ok '\$status -eq 0' skip_fail

        fail_skip() { is 1 0; skip; is 0 1; summary; }
        run_ok '\$status -eq 1' fail_skip

        skip_subtest() {  skip; subtest 'skip' 'is 1 0'; }
        run_ok '\$status -eq 0' skip_subtest
    }"

}

run_tests() {
    test_test
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && { run_tests "$@"; summary; }

# vim:set ft=sh ts=4 sw=4:
