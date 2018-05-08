#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TEST_BAUX_SOURCED -eq 1 ]] && return
declare -gr TEST_BAUX_SOURCED=1
declare -gr TEST_BAUX_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$TEST_BAUX_ABS_DIR/../../lib/test.sh"

test_baux() {
    # setup and teardown
    tmp=$(mktemp)
    trap 'rm -rf $tmp' RETURN EXIT SIGINT

    subtest "test die" "run_ok '\$status -eq 1 && \$output == test' die test"

    subtest "test warn" "{
        run_ok '\$status -eq 1 && \$output == test' warn test
        run_ok '\$status -eq 2' { warn test; warn test; }
    }"

    subtest "test version" "{
        local VERSION=
        run_ok '\$status -eq 1 && \$output =~ VERSION\\ variable' version

        local VERSION='v0.0.1'
        run_ok '\$status -eq 0 && \$output =~ v0.0.1' version
    }"

    subtest "test proname" "{
        run_ok '\$status -eq 0 && \$output =~ $(basename "$0")' proname
    }"

    subtest "test usage" "{
        local HELP=
        local VERSION=
        run_ok '\$status -eq 2 && \$output =~ HELP && \$output =~ VERSION' usage
        local HELP='usage help'
        local VERSION='v0.0.1'
        run_ok '\$status -eq 0 && \$output =~ v0.0.1 && \$output =~ usage\\ help' usage
    }"

    subtest "test import" "{
        run_ok '\$status -eq 1' import xxxxxxx

        echo 'test_test_import() { echo test-import; }; test_test_import' >$tmp

        run_ok '\$status -eq 0 && \$output =~ test-import' import $tmp
        run_ok '\$status -eq 0 && \$output == test-import' import $tmp $tmp
    }"
}

run_tests() {
    test_baux
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && run_tests "$@" && summary

# vim:set ft=sh ts=4 sw=4:
