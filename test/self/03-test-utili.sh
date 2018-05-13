#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TEST_UTILI_SOURCED -eq 1 ]] && return
declare -gr TEST_UTILI_SOURCED=1
declare -gr TEST_UTILI_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$TEST_UTILI_ABS_DIR/../../lib/utili.sh"
source "$TEST_UTILI_ABS_DIR/../../lib/test.sh"

test_utili() {
    setup() {
        tmp=$(mktemp)
    }; setup

    teardown() {
        rm -rf "$tmp"
    }; trap 'teardown' RETURN EXIT SIGINT

    subtest "test random" "{
        is '' \"\$(random)\"
        is 'test' \"\$(random test)\"
        unlike \"\$(random {1..100})\" \"\$(echo {1..10})\"
    }"

    subtest "test cecho" "{
        local -a colors=(red green yellow blue magenta cyan white)
        local i=0
        for c in black \${colors[@]}; do
            is \"[3\$((i++))mtest[0m\" \"\$(cecho \$c test)\"
        done
        is \"[34mtest[0m\" \"\$(cecho other test)\"
    }"

    subtest "test check_tool" "{
        # OK
        run_ok '\$status -eq 0' check_tool
        run_ok '\$status -eq 0' check_tool bash
        run_ok '\$status -eq 0' check_tool bash ls

        # fail
        run_ok '\$status -eq 1' check_tool ''
        run_ok '\$status -eq 1' check_tool xxx
        run_ok '\$status -eq 1' check_tool bash xxx
    }"

    subtest "test realdir" "{
        run_ok '\$status -eq 0 && \$output == \"\"' realdir
        run_ok '\$output =~ /etc' realdir /etc/hosts
        run_ok '\$output =~ \"/etc /etc\"' realdir /etc/hosts /etc/passwd
    }"

    subtest "test read_config" "{
        local -A configs
        test_read_config() {
            local -A configs
            echo 'user=test' >$tmp
            echo 'host=test.com' >>$tmp
            read_config configs $tmp
            echo \${configs[\$1]}
        }

        # OK
        run_ok '\$status -eq 0' read_config configs $tmp
        is 'test' \"\$(test_read_config user)\"
        is 'test.com' \"\$(test_read_config host)\"
        
        # fail
        run_ok '\$status -eq 1' read_config configs ''
        run_ok '\$status -eq 1' read_config configs xxxx
        isnt 'test' \"\$(test_read_config USER)\"
        isnt 'test.com' \"\$(test_read_config HOST)\"
    }"

    subtest "test getoptions" "{
        local -A opts args
        getoptions opts args 'a' ''
        is '' \"\${opts[a]}\"
        getoptions opts args 'a' a
        is '' \"\${opts[a]}\"
        getoptions opts args 'a' -a
        is '1' \"\${opts[a]}\"
        getoptions opts args 'a' -a a
        is '1' \"\${opts[a]}\"
        getoptions opts args 'a:' -a a
        is '1' \"\${opts[a]}\"
        is 'a' \"\${args[a]}\"
    }"
}

run_tests() {
    test_utili
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && run_tests "$@" && summary

# vim:set ft=sh ts=4 sw=4:
