#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TSET_ENSURE_SOURCED -eq 1 ]] && return
declare -gr TSET_ENSURE_SOURCED=1
declare -gr TSET_ENSURE_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$TSET_ENSURE_ABS_DIR/../../lib/ensure.sh"
source "$TSET_ENSURE_ABS_DIR/../../lib/test.sh"

get_section() {
    local section=$1
    local file=$2

    awk '/#####'"$section"'-start/, /#####'"$section"'-end/ \
        { if ($0 !~ /#####/ && $0 !~ /^\s*$/) print $0 }' "$file"
}

test_ensure() {
    setup() {
        tmp=$(mktemp)
    }; setup
    
    teardown() {
        rm -rf "$tmp"
    }; trap 'teardown' RETURN EXIT SIGINT

    subtest "ensure test" "{
        run_ok '\$status -eq 1 && \$output =~ args\\ error' ensure

        old_ifs=\$IFS
        IFS=$'\\n'

        # ensure ok
        for line in \$(get_section OK $TSET_ENSURE_ABS_DIR/02-test-ensure.txt); do
            run_ok '\$status -eq 0' ensure \"\$line\"
        done

        # ensure fail
        for line in \$(get_section FAIL $TSET_ENSURE_ABS_DIR/02-test-ensure.txt); do
            run_ok '\$status -eq 1' ensure \"\$line\"
        done

        IFS=\$old_ifs
    }"

    subtest "test ensure_not_empty" "{
        # OK
        run_ok '\$status -eq 0' ensure_not_empty
        run_ok '\$status -eq 0' ensure_not_empty test
        run_ok '\$status -eq 0' ensure_not_empty 'test '
        run_ok '\$status -eq 0' ensure_not_empty ' test'

        # fail
        run_ok '\$status -eq 1' ensure_not_empty ''
        run_ok '\$status -eq 1' ensure_not_empty ' '
        run_ok '\$status -eq 1' ensure_not_empty test ''
        run_ok '\$status -eq 1' ensure_not_empty test ' '
    }"

    subtest "test ensure_is" "{
        # OK
        run_ok '\$status -eq 0' ensure_is '' ''
        run_ok '\$status -eq 0' ensure_is ' ' ' '
        run_ok '\$status -eq 0' ensure_is 'test' 'test'
        run_ok '\$status -eq 0' ensure_is 'test ' 'test '
        run_ok '\$status -eq 0' ensure_is ' test' ' test'
        run_ok '\$status -eq 0' ensure_is ' test ' ' test '

        # fail
        run_ok '\$status -eq 1' ensure_is '' ' '
        run_ok '\$status -eq 1' ensure_is 'test' 'Test'
        run_ok '\$status -eq 1' ensure_is 'test' 'test '
        run_ok '\$status -eq 1' ensure_is ' test' 'test'
    }"

    subtest "test ensure_isnt" "{
        # OK
        run_ok '\$status -eq 0' ensure_isnt '' ' '
        run_ok '\$status -eq 0' ensure_isnt 'test' 'Test'
        run_ok '\$status -eq 0' ensure_isnt 'test' ' test'
        run_ok '\$status -eq 0' ensure_isnt 'test' 'test '
        run_ok '\$status -eq 0' ensure_isnt 'test' ' test '

        # fail
        run_ok '\$status -eq 1' ensure_isnt '' ''
        run_ok '\$status -eq 1' ensure_isnt ' ' ' '
        run_ok '\$status -eq 1' ensure_isnt 'test' 'test'
        run_ok '\$status -eq 1' ensure_isnt 'test ' 'test '
        run_ok '\$status -eq 1' ensure_isnt ' test' ' test'
        run_ok '\$status -eq 1' ensure_isnt ' test ' ' test '

    }"

    subtest "test ensure_like" "{
        # OK
        run_ok '\$status -eq 0' ensure_like '' ''
        run_ok '\$status -eq 0' ensure_like ' ' ''
        run_ok '\$status -eq 0' ensure_like 'test' ''
        run_ok '\$status -eq 0' ensure_like 'test' 'te'
        run_ok '\$status -eq 0' ensure_like 'test' 'st'
        run_ok '\$status -eq 0' ensure_like 'test' 'test'
        run_ok '\$status -eq 0' ensure_like 'test' '.*'
        run_ok '\$status -eq 0' ensure_like 'test' 'te.*'
        run_ok '\$status -eq 0' ensure_like 'test' '.*st'

        # fail
        run_ok '\$status -eq 1' ensure_like '' ' '
        run_ok '\$status -eq 1' ensure_like '' 'a'
        run_ok '\$status -eq 1' ensure_like 'test' ' '
        run_ok '\$status -eq 1' ensure_like 'test' 'Test'
        run_ok '\$status -eq 1' ensure_like 'test' ' test'
        run_ok '\$status -eq 1' ensure_like 'test' '^est'
        run_ok '\$status -eq 1' ensure_like 'test' 'tes$'
    }"

    subtest "test ensure_unlike" "{
        # OK
        run_ok '\$status -eq 0' ensure_unlike '' ' '
        run_ok '\$status -eq 0' ensure_unlike '' 'a'
        run_ok '\$status -eq 0' ensure_unlike 'test' ' '
        run_ok '\$status -eq 0' ensure_unlike 'test' 'Test'
        run_ok '\$status -eq 0' ensure_unlike 'test' ' test'
        run_ok '\$status -eq 0' ensure_unlike 'test' '^est'
        run_ok '\$status -eq 0' ensure_unlike 'test' 'tes$'

        # fail
        run_ok '\$status -eq 1' ensure_unlike '' ''
        run_ok '\$status -eq 1' ensure_unlike ' ' ''
        run_ok '\$status -eq 1' ensure_unlike 'test' ''
        run_ok '\$status -eq 1' ensure_unlike 'test' 'te'
        run_ok '\$status -eq 1' ensure_unlike 'test' 'st'
        run_ok '\$status -eq 1' ensure_unlike 'test' 'test'
        run_ok '\$status -eq 1' ensure_unlike 'test' '.*'
        run_ok '\$status -eq 1' ensure_unlike 'test' 'te.*'
        run_ok '\$status -eq 1' ensure_unlike 'test' '.*st'
    }"

    subtest "test BAUX_ENSURE_DEBUG=0" "{
        run_ok '\$status -eq 0' \
            bash -c 'DEBUG=0; source $TSET_ENSURE_ABS_DIR/../../lib/ensure.sh; ensure'
        run_ok '\$status -eq 0' \
            bash -c 'DEBUG=0; source $TSET_ENSURE_ABS_DIR/../../lib/ensure.sh; ensure_not_empty'
        run_ok '\$status -eq 0' \
            bash -c 'DEBUG=0; source $TSET_ENSURE_ABS_DIR/../../lib/ensure.sh; ensure_is'
        run_ok '\$status -eq 0' \
            bash -c 'DEBUG=0; source $TSET_ENSURE_ABS_DIR/../../lib/ensure.sh; ensure_isnt'
        run_ok '\$status -eq 0' \
            bash -c 'DEBUG=0; source $TSET_ENSURE_ABS_DIR/../../lib/ensure.sh; ensure_like'
        run_ok '\$status -eq 0' \
            bash -c 'DEBUG=0; source $TSET_ENSURE_ABS_DIR/../../lib/ensure.sh; ensure_unlike'
    }"
}

run_tests() {
    test_ensure
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && run_tests "$@" && summary

# vim:set ft=sh ts=4 sw=4:
