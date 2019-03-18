#! /usr/bin/env bats

SRC_DIR=$BATS_TEST_DIRNAME/../..
source $SRC_DIR/lib/test.sh
load bats-aux

@test "test ok" {
    local -a data_pass=(
            '1 == 1'
            '1 = 1'
            '1 != 0'
            '1 > 0'
            '0 < 1'
            '1 -eq 1'
            '1 -ne 0'
            '1 -ge 1'
            '1 -gt 0'
            '0 -lt 1'
            '0 -le 1'
            'test =~ ""'
            'test =~ t'
            '=='
            '=~'
            )
    for expr in "${data_pass[@]}"; do
        run ok "$expr" "'$expr' must be ok"
        [[ $status -eq 0 ]] || run_error "run ok '$expr' failed."
    done

    local -a data_fail=(
            ''
            '""'
            "''"
            '!'
            '1 =='
            '== 1'
            '1 =~'
            '=~ 1'
            )
    for expr in "${data_fail[@]}"; do
        run ok "$expr" "'$expr' should not be ok"
        [[ $status -eq 1 ]] || run_error "run ok '$expr' failed."
    done
}

@test "test is" {
    local -a data_pass=(
            ':'
            ' : '
            "1:1"
            "test:test"
            )
    for expr in "${data_pass[@]}"; do
        run is "${expr%%:*}" "${expr##*:}" "${expr%%:*} is ${expr##*:}"
        [[ $status -eq 0 ]] || run_error "run is '${expr%%:*}' '${expr##*:}' failed."
    done

    local -a data_fail=(
            '1:'
            ':1'
            '0:1'
            ' :  '
            'test:Test'
            )
    for expr in "${data_fail[@]}"; do
        run is "${expr%%:*}" "${expr##*:}" "${expr%%:*} is not ${expr##*:}"
        [[ $status -eq 1 ]] || run_error "run is '${expr%%:*}' '${expr##*:}' failed."
    done
}

@test "test isnt" {
    local -a data_pass=(
            '1:'
            ':1'
            '0:1'
            ' :  '
            'test:Test'
            )
    for expr in "${data_pass[@]}"; do
        run isnt "${expr%%:*}" "${expr##*:}" "${expr%%:*} is not ${expr##*:}"
        [[ $status -eq 0 ]] || run_error "run ensure_isnt '${expr%%:*}' '${expr##*:}' failed."
    done

    local -a data_fail=(
            ':'
            ' : '
            "1:1"
            "test:test"
            )
    for expr in "${data_fail[@]}"; do
        run isnt "${expr%%:*}" "${expr##*:}" "${expr%%:*} is ${expr##*:}"
        [[ $status -eq 1 ]] || run_error "run isnt '${expr%%:*}' '${expr##*:}' failed."
    done
}

@test "test like" {
    local -a data_pass=(
            ':'
            ' : '
            "1:1"
            "test:test"
            'test:'
            'test:t'
            'test:st'
            'test:es'
            )
    for expr in "${data_pass[@]}"; do
        run like "${expr%%:*}" "${expr##*:}" "${expr%%:*} like ${expr##*:}"
        [[ $status -eq 0 ]] || run_error "run like '${expr%%:*}' '${expr##*:}' failed."
    done

    local -a data_fail=(
            '0:1'
            ' :  '
            'test:Test'
            'test: test'
            'test:test '
            )
    for expr in "${data_fail[@]}"; do
        run like "${expr%%:*}" "${expr##*:}" "${expr%%:*} unlike ${expr##*:}"
        [[ $status -eq 1 ]] || run_error "run like '${expr%%:*}' '${expr##*:}' failed."
    done
}

@test "test unlike" {
    local -a data_pass=(
            '0:1'
            ' :  '
            'test:Test'
            'test: test'
            'test:test '
            )
    for expr in "${data_pass[@]}"; do
        run unlike "${expr%%:*}" "${expr##*:}" "${expr%%:*} unlike ${expr##*:}"
        [[ $status -eq 0 ]] || run_error "run unlike '${expr%%:*}' '${expr##*:}' failed."
    done

    local -a data_fail=(
            ':'
            ' : '
            "1:1"
            "test:test"
            'test:'
            'test:t'
            'test:st'
            'test:es'
            )
    for expr in "${data_fail[@]}"; do
        run unlike "${expr%%:*}" "${expr##*:}" "${expr%%:*} like ${expr##*:}"
        [[ $status -eq 1 ]] || run_error "run unlike '${expr%%:*}' '${expr##*:}' failed."
    done
}

@test "test run_ok" {
    run_ok_true() { true; }
    run_ok_false() { false; }

    local -a data_pass=(
            true
            run_ok_true
            )
    for cmd in "${data_pass[@]}"; do
        run run_ok '$status -eq 0' "$cmd"
        [[ $status -eq 0 ]] || run_error "run run_ok '$cmd' failed."
    done

    local -a data_fail=(
            false
            run_ok_false
            cmd-not-found
            )
    for cmd in "${data_fail[@]}"; do
        run run_ok '$status -eq 0' "$cmd"
        [[ $status -eq 1 ]] || run_error "run run_ok '$cmd' failed."
    done
}

@test "test subtest" {
    run subtest "subtest PASS" 'is 1 1 "test is"'
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run subtest "subtest FAIL" 'is 1 0 "test is"'
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    skip
    run subtest "subtest SKIP" 'is 1 0 "test is"'
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[SKIP]} ]]
}

@test "test skip & summary" {
    is 1 1 "test is"
    isnt 10 "test isnt"
    skip; like test test "test like"
    skip; subtest "test subtest" 'is 1 1 "test is"'
    run unlike test test "test unlike"

    run summary
    [[ $status -eq 0 ]]

    [[ ${BAUX_TEST_COUNTS[TOTAL]} -eq 4 ]]
    [[ ${BAUX_TEST_COUNTS[PASS]} -eq 2 ]]
    [[ ${BAUX_TEST_COUNTS[FAIL]} -eq 0 ]]
    [[ ${BAUX_TEST_COUNTS[SKIP]} -eq 2 ]]
}
