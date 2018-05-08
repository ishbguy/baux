#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TSET_ENSURE_SOURCED -eq 1 ]] && return
declare -gr TSET_ENSURE_SOURCED=1
declare -gr TSET_ENSURE_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$TSET_ENSURE_ABS_DIR/../../lib/test.sh"

test_ensure() {
    # setup and teardown
    tmp=$(mktemp)
    trap 'rm -rf $tmp' RETURN EXIT SIGINT

    subtest "ensure test" "{
        run_ok '\$status -eq 1 && \$output =~ args\\ error' ensure

        IFS=$'\\n'
        for line in \$(cat .02-test-ensure-ensure-ok.txt); do
            run_ok '\$status -eq 0' ensure \"\$line\"
        done
    }"
}

run_tests() {
    test_ensure
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && run_tests "$@" && summary

# vim:set ft=sh ts=4 sw=4: