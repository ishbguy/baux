#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TEST_LOG_SOURCED -eq 1 ]] && return
declare -gr TEST_LOG_SOURCED=1
declare -gr TEST_LOG_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$TEST_LOG_ABS_DIR/../../lib/log.sh"
source "$TEST_LOG_ABS_DIR/../../lib/test.sh"

test_log() {
    setup() {
        tmp=$(mktemp)
    }; setup

    teardown() {
        rm -rf "$tmp"
    }; trap 'teardown' RETURN EXIT SIGINT

    subtest "test for log" "{
        run_ok '\$output =~ DEBUG' log debug test 
        run_ok '\$output =~ INFO' log info test 
        run_ok '\$output =~ WARN' log warn test 
        run_ok '\$output =~ ERROR' log error test 
        run_ok '\$output =~ FATAL' log fatal test 
        run_ok '\$output =~ PANIC' log panic test 
        run_ok '\$output =~ QUIET' log quiet test 

        BAUX_LOG_OUTPUT_LEVEL=info
        run_ok '\$output =~ \"\"' log debug test 
        run_ok '\$output =~ INFO' log info test 
        run_ok '\$output =~ WARN' log warn test 
        run_ok '\$output =~ ERROR' log error test 
        run_ok '\$output =~ FATAL' log fatal test 
        run_ok '\$output =~ PANIC' log panic test 
        run_ok '\$output =~ QUIET' log quiet test 

        BAUX_LOG_OUTPUT_LEVEL=quiet
        run_ok '\$output =~ \"\"' log debug test 
        run_ok '\$output =~ \"\"' log info test 
        run_ok '\$output =~ \"\"' log warn test 
        run_ok '\$output =~ \"\"' log error test 
        run_ok '\$output =~ \"\"' log fatal test 
        run_ok '\$output =~ \"\"' log panic test 
        run_ok '\$output =~ QUIET' log quiet test 

        BAUX_LOG_OUTPUT_LEVEL=debug
        BAUX_LOG_OUTPUT_FILE=$tmp
        run_ok '\$output =~ \"\"' log debug test 
        run_ok '\$output =~ \"\"' log info test 
        run_ok '\$output =~ \"\"' log warn test 
        run_ok '\$output =~ \"\"' log error test 
        run_ok '\$output =~ \"\"' log fatal test 
        run_ok '\$output =~ \"\"' log panic test 
        run_ok '\$output =~ \"\"' log quiet test 
        
        run_ok '\$status -eq 0' grep DEBUG $tmp
        run_ok '\$status -eq 0' grep INFO $tmp
        run_ok '\$status -eq 0' grep WARN $tmp
        run_ok '\$status -eq 0' grep ERROR $tmp
        run_ok '\$status -eq 0' grep FATAL $tmp
        run_ok '\$status -eq 0' grep PANIC $tmp
        run_ok '\$status -eq 0' grep QUIET $tmp
    }"
}

run_tests() {
    test_log
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && { run_tests "$@"; summary; }

# vim:set ft=sh ts=4 sw=4:
