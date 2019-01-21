#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $BAUX_TEST_SUIT_SOURCED -eq 1 ]] && return
declare -gr BAUX_TEST_SUIT_SOURCED=1
declare -gr BAUX_TEST_SUIT_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$BAUX_TEST_SUIT_ABS_DIR/../lib/test.sh"
source "$BAUX_TEST_SUIT_ABS_DIR/../lib/var.sh"
source "$BAUX_TEST_SUIT_ABS_DIR/../lib/utili.sh"

VERSION="v0.0.1"
HELP="\
$(proname) <test-files|test-dir>
This program is released under the terms of MIT License."

declare -ga BAUX_TEST_SUIT_FILES
declare -ga BAUX_TEST_SUIT_CASES

is_shell_script() {
    [[ -f $1 && $1 == *.sh && $(file "$1") =~ sh[[:alnum:]]*\ script ]]
}

search_test_cases() {
    sed -rn 's/(^test[-_][[:alnum:]_-]+)(\s+)?\((\s+)?\).*/\1/p' "$1"
}

ensure_is_shell_script() {
    is_shell_script "$1" || die "[$1] is not a shell script"
}

add_test_file() {
    ensure_is_shell_script "$1"
    BAUX_TEST_SUIT_FILES+=("$1")
}

add_test_dir() {
    for file in $1/*.sh; do
        add_test_file "$file"
    done
}

add_test_files() {
    for path in "$@"; do
        [[ -d $path ]] && add_test_dir "$path" && continue
        add_test_file "$path"
    done
}

add_test_cases_from() {
    for file in "$@"; do
        BAUX_TEST_SUIT_CASES+=($(search_test_cases "$file"))
    done
    [[ ${#BAUX_TEST_SUIT_CASES[@]} -eq 0 ]] && die "No test case in given files"
}

run_test_cases() {
    for cs in "$@"; do
        type_func "$cs" && "$cs"
    done
}

baux_test() {
    local -A opts args
    getoptions opts args "hv" "$@"
    shift $((OPTIND - 1))
    [[ ${#@} -eq 0 ]] && usage && die "$(cecho red "Please give a test file!")"
    [[ ${opts[h]} -eq 1 || ${opts[v]} -eq 1 ]] && usage && exit 0

    add_test_files "$@"
    add_test_cases_from "${BAUX_TEST_SUIT_FILES[@]}"
    import "${BAUX_TEST_SUIT_FILES[@]}"
    run_test_cases "${BAUX_TEST_SUIT_CASES[@]}"
    summary
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && baux_test "$@"

# vim:set ft=sh ts=4 sw=4:
