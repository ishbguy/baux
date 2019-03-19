#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TEST_VAR_SOURCED -eq 1 ]] && return
declare -gr TEST_VAR_SOURCED=1
declare -gr TEST_VAR_ABS_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "$TEST_VAR_ABS_DIR/../../lib/var.sh"
source "$TEST_VAR_ABS_DIR/../../lib/test.sh"

test_var() {
    setup() {
        tmp=$(mktemp)
    }; setup

    teardown() {
        rm -rf "$tmp"
    }; trap 'teardown' RETURN EXIT SIGINT

    subtest "test typeof" "{
        local -a array=()
        local -A map=()
        local -n reference=array
        local -i integer=1
        local -r readonly=0
        local -l lower=test
        local -u upper=TEST
        local -x export=TYPEOF
        func() { true; }

        run_ok '\$status -eq 0 && \$output == \"\"' typeof
        run_ok '\$output == array' typeof array
        run_ok '\$output == map' typeof map
        run_ok '\$output == reference' typeof reference
        run_ok '\$output == integer' typeof integer
        run_ok '\$output == readonly' typeof readonly
        run_ok '\$output == lower' typeof lower
        run_ok '\$output == upper' typeof upper
        run_ok '\$output == export' typeof export
        run_ok '\$output == function' typeof func
        run_ok '\$output == undefined' typeof undefined

        run_ok '\$output == \"array map reference integer readonly lower upper export function undefined\"' \
            typeof array map reference integer readonly lower upper export func undefined
    }"

    subtest "test istype" "{
        local -a array=()
        local -A map=()
        local -n reference=array
        local -i integer=1
        local -r readonly=0
        local -l lower=test
        local -u upper=TEST
        local -x export=TYPEOF
        func() { true; }
        
        run_ok '\$status -eq 0' istype array array
        run_ok '\$status -eq 0' istype map map
        run_ok '\$status -eq 0' istype reference reference
        run_ok '\$status -eq 0' istype integer integer
        run_ok '\$status -eq 0' istype readonly readonly
        run_ok '\$status -eq 0' istype lower lower
        run_ok '\$status -eq 0' istype upper upper
        run_ok '\$status -eq 0' istype export export
        run_ok '\$status -eq 0' istype function func
        run_ok '\$status -eq 0' istype undefined undefined

        run_ok '\$status -eq 0' type_array array
        run_ok '\$status -eq 0' type_map map
        run_ok '\$status -eq 0' type_ref reference
        run_ok '\$status -eq 0' type_int integer
        run_ok '\$status -eq 0' type_lower lower
        run_ok '\$status -eq 0' type_upper upper
        run_ok '\$status -eq 0' type_export export
        run_ok '\$status -eq 0' type_func func

        run_ok '\$status -eq 1' type_func undefined
    }"

    subtest "test defined" "{
        local -a array=()
        local -A map=()
        local -n reference=array
        local -i integer=1
        local -r readonly=0
        local -l lower=test
        local -u upper=TEST
        local -x export=TYPEOF
        func() { true; }
        
        run_ok '\$status -eq 0' defined array
        run_ok '\$status -eq 0' defined map
        run_ok '\$status -eq 0' defined reference
        run_ok '\$status -eq 0' defined integer
        run_ok '\$status -eq 0' defined readonly
        run_ok '\$status -eq 0' defined lower
        run_ok '\$status -eq 0' defined upper
        run_ok '\$status -eq 0' defined export
        run_ok '\$status -eq 0' defined func

        run_ok '\$status -eq 1' defined undefined
    }"
}

run_tests() {
    test_var
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && { run_tests "$@"; summary; }

# vim:set ft=sh ts=4 sw=4:
