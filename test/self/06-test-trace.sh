#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TEST_TRACE_SOURCED -eq 1 ]] && return
declare -gr TEST_TRACE_SOURCED=1
declare -gr TEST_TRACE_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$TEST_TRACE_ABS_DIR/../../lib/trace.sh"
source "$TEST_TRACE_ABS_DIR/../../lib/test.sh"

test_trace() {
    setup() {
        tmp=$(mktemp)
    }; setup

    teardown() {
        rm -rf "$tmp"
    }; trap 'teardown' RETURN EXIT SIGINT

    one() {
        two "$1"
    }
    two() {
        three "$1"
    }
    three() {
        frame "$1"
    }

    subtest "test frame" "{
        run_ok '\$output =~ three' one
        run_ok '\$output =~ three' one 0
        run_ok '\$output =~ two' one 1
        run_ok '\$output =~ one' one 2
        run_ok '\$output =~ run_ok' one 3
    }"

    subtest "test callstack" "{
        run_ok '\$output =~ run_ok' callstack
        run_ok '\$output =~ run_ok' callstack 0
        run_ok '\$output =~ test_callstack' callstack 1
        run_ok '\$output =~ subtest' callstack 2
        run_ok '\$output =~ test_trace' callstack 3
    }"
}

run_tests() {
    test_trace
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && { run_tests "$@"; summary; }

# vim:set ft=sh ts=4 sw=4:
