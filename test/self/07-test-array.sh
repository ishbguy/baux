#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $TEST_ARRAY_SOURCED -eq 1 ]] && return
declare -gr TEST_ARRAY_SOURCED=1
declare -gr TEST_ARRAY_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$TEST_ARRAY_ABS_DIR/../../lib/array.sh"
source "$TEST_ARRAY_ABS_DIR/../../lib/test.sh"

test_array() {
    setup() {
        tmp=$(mktemp)
    }; setup

    teardown() {
        rm -rf "$tmp"
    }; trap 'teardown' RETURN EXIT SIGINT

    subtest "test push" "{
        local -a array=()

        is 0 \"\${#array[@]}\"

        push array ''
        is 1 \"\${#array[@]}\"
        is '' \"\${array[\$((\${#array[@]}-1))]}\"

        push array one
        is 2 \"\${#array[@]}\"
        is one \"\${array[\$((\${#array[@]}-1))]}\"

        push array two three
        is 4 \"\${#array[@]}\"
        is three \"\${array[\$((\${#array[@]}-1))]}\"
    }"

    subtest "test pop" "{
        local -a array=(one two '' three four)
        
        is 5 \"\${#array[@]}\"

        run_ok '\$output == four' pop array
        pop array
        is 4 \"\${#array[@]}\"
        is three \"\${array[\$((\${#array[@]}-1))]}\"

        pop array
        is 3 \"\${#array[@]}\"
        is '' \"\${array[\$((\${#array[@]}-1))]}\"

        pop array; pop array
        is 1 \"\${#array[@]}\"
        is one \"\${array[\$((\${#array[@]}-1))]}\"

        pop array
        is 0 \"\${#array[@]}\"
        is '' \"\${array[\$((\${#array[@]}-1))]}\"

        pop array; pop array
        is 0 \"\${#array[@]}\"
        is '' \"\${array[\$((\${#array[@]}-1))]}\"
    }"

    subtest "test _shift" "{
        local -a array=(one '' three)

        is 3 \"\${#array[@]}\"

        run_ok '\$output == one' _shift array
        _shift array
        is 2 \"\${#array[@]}\"
        is '' \"\${array[0]}\"

        _shift array; _shift array
        is 0 \"\${#array[@]}\"
        is '' \"\${array[0]}\"

        _shift array; _shift array
        is 0 \"\${#array[@]}\"
        is '' \"\${array[0]}\"
    }"

    subtest "test unshift" "{
        local -a array=()

        is 0 \"\${#array[@]}\"

        unshift array one
        is 1 \"\${#array[@]}\"
        is one \"\${array[0]}\"

        unshift array ''
        is 2 \"\${#array[@]}\"
        is '' \"\${array[0]}\"

        unshift array two three
        is 4 \"\${#array[@]}\"
        is two \"\${array[0]}\"
    }"

    subtest "test slice" "{
        local -a array=(one two three four)

        run_ok '\$status -eq 1' slice array -1
        run_ok '\$output == one' slice array 0
        run_ok '\$output == \"\"' slice array 999

        run_ok '\$output == \"one one\"' slice array 0 0
        run_ok '\$output == \"one two\"' slice array 0 1
        run_ok '\$output == \"one two three\"' slice array 0 1 2
        run_ok '\$output == \"one two three four\"' slice array 0 1 999 2 3

        local -A map=()
        map[one]=1
        map[two]=2
        map[three]=3
        map[four]=4

        run_ok '\$output == \"1 2 3 4\"' slice map one 2 two three 999 four
    }"

    subtest "test _get" "{
        local -a array=(0 1 2 3)
        is 0 \"\$(_get array 0)\"
        is 1 \"\$(_get array 1)\"
        is 2 \"\$(_get array 2)\"
        is 3 \"\$(_get array 3)\"
        is '' \"\$(_get array 4)\"

        local -A map
        map[0]=0
        map[1]=1
        map[2]=2

        is 0 \"\$(_get map 0)\"
        is 1 \"\$(_get map 1)\"
        is 2 \"\$(_get map 2)\"
        is '' \"\$(_get map 3)\"
    }"

    subtest "test _set" "{
        local -a array=(0 1 2 3)
        _set array 0 10
        ok '\${array[0]} == 10'
        _set array 4 10
        ok '\${array[4]} == 10'

        local -A map
        map[0]=0
        map[1]=1
        map[2]=2
        _set map 0 10
        ok '\${map[0]} == 10'
        _set map 4 10
        ok '\${map[4]} == 10'
    }"

    subtest "test keys" "{
        local -a array=()
        run_ok '\$output == \"\"' keys array

        array+=(0 1 2 3)
        run_ok '\$output == \"0 1 2 3\"' keys array

        local -A map=()
        run_ok '\$output == \"\"' keys map

        map[one]=1
        map[two]=2
        map[three]=3
        run_ok '\$output =~ one' keys map
        run_ok '\$output =~ two' keys map
        run_ok '\$output =~ three' keys map
    }"

    subtest "test values" "{
        local -a array=()

        run_ok '\$output == \"\"' values array

        array+=(one two three)
        run_ok '\$output == \"one two three\"' values array

        local -A map=()
        run_ok '\$output == \"\"' values map

        map[one]=1
        map[two]=2
        map[three]=3
        run_ok '\$output =~ 1' values map
        run_ok '\$output =~ 2' values map
        run_ok '\$output =~ 3' values map
    }"

    subtest "test exsits" "{
        local -a array=()

        run_ok '\$status -eq 1' exists array 1

        array+=(1 2 3)
        run_ok '\$status -eq 0' exists array 0
        run_ok '\$status -eq 0' exists array 1
        run_ok '\$status -eq 0' exists array 2

        local -a map=()
        run_ok '\$status -eq 1' exists map 1

        map[one]=1
        map[two]=2
        map[three]=3
        run_ok '\$status -eq 0' exists map one
        run_ok '\$status -eq 0' exists map two
        run_ok '\$status -eq 0' exists map three
    }"

    subtest "test _join" "{
        local -a array=(one two '' three)

        run_ok '\$output == one:two::three' _join : \"\${array[@]}\"
        run_ok '\$output == \"one two  three\"' _join ' ' \"\${array[@]}\"
    }"

    subtest "test _split" "{
        local -a array

        array=()
        _split 'one:two:three' array :
        is one \"\${array[0]}\"
        is two \"\${array[1]}\"
        is three \"\${array[2]}\"

        array=()
        _split 'one::three:' array :
        is one \"\${array[0]}\"
        is '' \"\${array[1]}\"
        is three \"\${array[2]}\"
        is '' \"\${array[3]}\"

        array=()
        _split ':::' array :
        is '' \"\${array[0]}\"
        is '' \"\${array[1]}\"
        is '' \"\${array[2]}\"
        is '' \"\${array[3]}\"

        array=()
        _split '   ' array ' '
        is '' \"\${array[0]}\"
        is '' \"\${array[1]}\"
        is '' \"\${array[2]}\"
        is '' \"\${array[3]}\"

        array=()
        _split 'one : two:three: ' array ' '
        is 'one' \"\${array[0]}\"
        is ':' \"\${array[1]}\"
        is 'two:three:' \"\${array[2]}\"
        is '' \"\${array[3]}\"

        array=()
        _split 'one : two:three: ' array :
        is 'one ' \"\${array[0]}\"
        is ' two' \"\${array[1]}\"
        is 'three' \"\${array[2]}\"
        is ' ' \"\${array[3]}\"
    }"

    subtest "test _uniq" "{
        local -a array=(one one '' two three two three)

        run_ok '\$status -eq 0' _uniq \"\${array[@]}\"
        local string=\$(_uniq \"\${array[@]}\")
        is 13 \${#string}
    }"

    subtest "test sort" "{
        local -a array=({0..100})        
        
        run_ok '\$status -eq 0' __issorted \$(_sort \$(_sort -R \${array[@]}))
        run_ok '\$status -eq 0' __issorted \$(select_sort \$(_sort -R \${array[@]}))
        run_ok '\$status -eq 0' __issorted \$(insert_sort \$(_sort -R \${array[@]}))
        run_ok '\$status -eq 0' __issorted \$(shell_sort \$(_sort -R \${array[@]}))
    }"

    subtest "test search" "{
        local -a array=({0..100})

        is 48 \"\$(search array 48)\"
        is '48 1 36' \"\$(search array 48 1 36)\"
        is '' \"\$(search array 101)\"

        array=({10..0} 99 {30..20})
        is 11 \"\$(search array 99)\"
    }"

    subtest "test lseach" "{
        local -a array=({0..100})

        is 48 \"\$(lsearch array 48)\"
        is '' \"\$(lsearch array 101)\"

        array=({10..0} 99 {30..20})
        is 11 \"\$(lsearch array 99)\"
    }"

    subtest "test bseach" "{
        local -a array=({0..100})

        is 48 \"\$(bsearch array 48)\"
        is '' \"\$(bsearch array 101)\"
    }"
}

run_tests() {
    test_array
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && { run_tests "$@"; summary; }

# vim:set ft=sh ts=4 sw=4:
