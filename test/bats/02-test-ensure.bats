#!/usr/bin/env bats

SRC_DIR=$BATS_TEST_DIRNAME/../..
source $SRC_DIR/lib/ensure.sh
load bats-aux

@test "test ensure" {
    run ensure
    [[ $status -eq 1 ]] || run_error "run ensure without args failed."

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
        run ensure "$expr"
        [[ $status -eq 0 ]] || run_error "run ensure '$expr' failed."
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
        run ensure "$expr"
        [[ $status -eq 1 ]] || run_error "run ensure '$expr' failed."
    done
}

@test "test ensure_not_empty" {
    run ensure_not_empty
    [[ $status -eq 0 ]] || run_error "run ensure_not_empty without args failed."

    local -a data_pass=(
            '""'
            "''"
            '" "'
            "' '"
            '1'
            '0'
            'test'
            'one two'
            ' one'
            'one '
            ' one '
            )
    for expr in "${data_pass[@]}"; do
        run ensure_not_empty "$expr"
        [[ $status -eq 0 ]] || run_error "run ensure_not_empty '$expr' failed."
    done

    local -a data_fail=(
            ''
            ""
            ' '
            )
    for expr in "${data_fail[@]}"; do
        run ensure_not_empty "$expr"
        [[ $status -eq 1 ]] || run_error "run ensure_not_empty '$expr' failed."
    done

    run ensure_not_empty one ""
    [[ $status -eq 1 ]] || run_error "run ensure_not_empty one '' failed."
}

@test "test ensure_is" {
    local -a data_pass=(
            ':'
            ' : '
            "1:1"
            "test:test"
            )
    for expr in "${data_pass[@]}"; do
        run ensure_is "${expr%%:*}" "${expr##*:}"
        [[ $status -eq 0 ]] || run_error "run ensure_is '${expr%%:*}' '${expr##*:}' failed."
    done

    local -a data_fail=(
            '1:'
            ':1'
            '0:1'
            ' :  '
            'test:Test'
            )
    for expr in "${data_fail[@]}"; do
        run ensure_is "${expr%%:*}" "${expr##*:}"
        [[ $status -eq 1 ]] || run_error "run ensure_is '${expr%%:*}' '${expr##*:}' failed."
    done
}

@test "test ensure_isnt" {
    local -a data_pass=(
            '1:'
            ':1'
            '0:1'
            ' :  '
            'test:Test'
            )
    for expr in "${data_pass[@]}"; do
        run ensure_isnt "${expr%%:*}" "${expr##*:}"
        [[ $status -eq 0 ]] || run_error "run ensure_isnt '${expr%%:*}' '${expr##*:}' failed."
    done

    local -a data_fail=(
            ':'
            ' : '
            "1:1"
            "test:test"
            )
    for expr in "${data_fail[@]}"; do
        run ensure_isnt "${expr%%:*}" "${expr##*:}"
        [[ $status -eq 1 ]] || run_error "run ensure_isnt '${expr%%:*}' '${expr##*:}' failed."
    done
}

@test "test ensure_like" {
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
        run ensure_like "${expr%%:*}" "${expr##*:}"
        [[ $status -eq 0 ]] || run_error "run ensure_like '${expr%%:*}' '${expr##*:}' failed."
    done

    local -a data_fail=(
            '0:1'
            ' :  '
            'test:Test'
            'test: test'
            'test:test '
            )
    for expr in "${data_fail[@]}"; do
        run ensure_like "${expr%%:*}" "${expr##*:}"
        [[ $status -eq 1 ]] || run_error "run ensure_like '${expr%%:*}' '${expr##*:}' failed."
    done
}

@test "test ensure_unlike" {
    local -a data_pass=(
            '0:1'
            ' :  '
            'test:Test'
            'test: test'
            'test:test '
            )
    for expr in "${data_pass[@]}"; do
        run ensure_unlike "${expr%%:*}" "${expr##*:}"
        [[ $status -eq 0 ]] || run_error "run ensure_unlike '${expr%%:*}' '${expr##*:}' failed."
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
        run ensure_unlike "${expr%%:*}" "${expr##*:}"
        [[ $status -eq 1 ]] || run_error "run ensure_unlike '${expr%%:*}' '${expr##*:}' failed."
    done
}

@test "test ensure_run" {
    ensure_run_func_true() { true; }
    ensure_run_func_false() { false; }

    local -a data_pass=(
            true
            'test true'
            ensure_run_func_true
            )
    for cmd in "${data_pass[@]}"; do
        run ensure_run "$cmd"
        [[ $status -eq 0 ]] || run_error "run ensure_run '$cmd' failed."
    done

    local -a data_fail=(
            false
            'id --no-this-opt'
            ensure_run_func_false
            cmd-not-found
            )
    for cmd in "${data_fail[@]}"; do
        run ensure_run "$cmd"
        [[ $status -eq 1 ]] || run_error "run ensure_run '$cmd' failed."
    done
}
