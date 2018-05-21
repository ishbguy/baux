#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_TEST_SOURCED -eq 1 ]] && return
declare -gr BAUX_TEST_SOURCED=1
declare -gr BAUX_TEST_ABS_DIR="$(dirname $(realpath "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_SOURCED -ne 1 ]]; then
    [[ ! -e $BAUX_TEST_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_TEST_ABS_DIR/baux.sh"
fi

import "$BAUX_TEST_ABS_DIR/utili.sh"
import "$BAUX_TEST_ABS_DIR/trace.sh"

declare -gA BAUX_TEST_PROMPTS
declare -gA BAUX_TEST_COLORS
declare -gA BAUX_TEST_COUNTS
declare -gi BAUX_TEST_SKIP_FLAG=0
declare -gi BAUX_TEST_STATUS_LEN=0
declare -g  BAUX_TEST_PAD_SPACES=""

BAUX_TEST_COUNTS[TOTAL]=0
BAUX_TEST_COUNTS[PASS]=0
BAUX_TEST_COUNTS[FAIL]=0
BAUX_TEST_COUNTS[SKIP]=0

BAUX_TEST_PROMPTS[TOTAL]="TOTAL"
BAUX_TEST_PROMPTS[PASS]="PASS"
BAUX_TEST_PROMPTS[FAIL]="FAIL"
BAUX_TEST_PROMPTS[SKIP]="SKIP"

BAUX_TEST_COLORS[TOTAL]="blue"
BAUX_TEST_COLORS[PASS]="green"
BAUX_TEST_COLORS[FAIL]="red"
BAUX_TEST_COLORS[SKIP]="yellow"
BAUX_TEST_COLORS[EMSG]="red"

for s in "${!BAUX_TEST_COUNTS[@]}"; do
    [[ ${#s} -gt $BAUX_TEST_STATUS_LEN ]] \
        && BAUX_TEST_STATUS_LEN=${#s}
done

for ((i = 1; i < BAUX_TEST_STATUS_LEN; i++)); do
    BAUX_TEST_PAD_SPACES+=" "
done

__count() {
    local test_status="$1"
    ((++BAUX_TEST_COUNTS[TOTAL]))
    if [[ $BAUX_TEST_SKIP_FLAG -eq 1 ]]; then
        ((++BAUX_TEST_COUNTS[SKIP]))
        BAUX_TEST_SKIP_FLAG=0
        result="SKIP"
        return
    fi
    if [[ $test_status -eq 0 ]]; then
        ((++BAUX_TEST_COUNTS[PASS]))
        result="PASS"
    else
        ((++BAUX_TEST_COUNTS[FAIL]))
        result="FAIL"
    fi
}

__report() {
    local -u result="$1"
    local msg="$2"

    echo -e "$BAUX_TEST_PAD_SPACES ${BAUX_TEST_COUNTS[TOTAL]} $msg \x1B[1G$(cecho \
        "${BAUX_TEST_COLORS[$result]}" "${BAUX_TEST_PROMPTS[$result]}")"
}

__location() {
    local idx="$(($1+1))"
    local temp=$(frame "$idx")
    eval set -- "$temp"
    local -a frame=("$@")
    local cmd=$(sed -ne "${frame[1]}p" "${frame[0]}" 2>/dev/null | sed -r 's/^\s+//')
    echo "$cmd [${frame[0]}:${frame[1]}:${frame[3]}]"
}

__diag() {
    local result="$1"
    local expect="$2"
    local actual="$3"
    [[ $result != "${BAUX_TEST_PROMPTS[FAIL]}" ]] && return 0

    # fail
    cecho "${BAUX_TEST_COLORS[EMSG]}" "$BAUX_TEST_PAD_SPACES $(__location 1)" >&2
    cecho "${BAUX_TEST_COLORS[EMSG]}" "$BAUX_TEST_PAD_SPACES Expect: $expect" >&2
    cecho "${BAUX_TEST_COLORS[EMSG]}" "$BAUX_TEST_PAD_SPACES Actual: $actual" >&2
    return 1
}

ok() {
    ensure "$# -ge 1 && $# -le 2" "Need at least an expression."
    ensure_not_empty "$1"

    local expr="$1"
    local msg="${2:-$1}"
    local -u result
    (eval "[[ $expr ]]" &>/dev/null)
    __count $?
    __report "$result" "$msg"
    [[ $result != "${BAUX_TEST_PROMPTS[FAIL]}" ]] \
        || { cecho "${BAUX_TEST_COLORS[EMSG]}" "$(__location 0)" >&2; return 1; }
}

is() {
    ensure "$# -ge 2 && $# -le 3" "Need expect, actual, message(optional) args."
    
    local expect="$1"
    local actual="$2"
    local msg="${3:-[[ $1 == $2 ]]}"
    local -u result
    ([[ "$expect" == "$actual" ]] &>/dev/null)
    __count $?
    __report "$result" "$msg"
    __diag "$result" "'$expect'" "'$actual'" 
}

isnt() {
    ensure "$# -ge 2 && $# -le 3" "Need expect, actual, message(optional) args."
    
    local expect="$1"
    local actual="$2"
    local msg="${3:-[[ $1 != $2 ]]}"
    local -u result
    ([[ "$expect" != "$actual" ]] &>/dev/null)
    __count $?
    __report "$result" "$msg"
    __diag "$result" "'$expect'" "'$actual'" 
}

like() {
    ensure "$# -ge 2 && $# -le 3" "Need expect, actual, message(optional) args."
    
    local expect="$1"
    local actual="$2"
    local msg="${3:-[[ $1 =~ $2 ]]}"
    local -u result
    ([[ $expect =~ $actual ]] &>/dev/null)
    __count $?
    __report "$result" "$msg"
    __diag "$result" "'$expect'" "'$actual'" 
}

unlike() {
    ensure "$# -ge 2 && $# -le 3" "Need expect, actual, message(optional) args."
    
    local expect="$1"
    local actual="$2"
    local msg="${3:-[[ ! $1 =~ $2 ]]}"
    local -u result
    ([[ ! $expect =~ $actual ]] &>/dev/null)
    __count $?
    __report "$result" "$msg"
    __diag "$result" "'$expect'" "'$actual'" 
}

run_ok() {
    ensure "$# -ge 2" "Need an expression and a command."
    ensure_not_empty "$1"
    
    local expr="$1"; shift
    local cmds="$*"
    local msg="test run: $cmds"
    local -u result
    local status output
    
    output=$("$@" 2>&1)
    status=$?

    (eval "[[ $expr ]]" &>/dev/null)
    __count $?
    __report "$result" "$msg"
    [[ $result != "${BAUX_TEST_PROMPTS[FAIL]}" ]] \
        || { \
        cecho "${BAUX_TEST_COLORS[EMSG]}" "$BAUX_TEST_PAD_SPACES $(__location 0)" >&2; \
        cecho "${BAUX_TEST_COLORS[EMSG]}" "$BAUX_TEST_PAD_SPACES expression: $expr" >&2; \
        cecho "${BAUX_TEST_COLORS[EMSG]}" "$BAUX_TEST_PAD_SPACES status: $status" >&2; \
        cecho "${BAUX_TEST_COLORS[EMSG]}" "$BAUX_TEST_PAD_SPACES output: '$output'" >&2; \
        return 1; }
}

subtest() {
    ensure "$# -eq 2" "Need test name and test instructions"
    ensure_not_empty "$1"

    local name="$1"
    local tests="$2"
    local encode_name="${name//[^[:alnum:]]/_}"
    local err_msg status

    ((++BAUX_TEST_COUNTS[TOTAL]))
    echo -ne "$BAUX_TEST_PAD_SPACES ${BAUX_TEST_COUNTS[TOTAL]} subtest: $name "

    # return if skip
    if [[ $BAUX_TEST_SKIP_FLAG -eq 1 ]]; then
        BAUX_TEST_SKIP_FLAG=0
        ((++BAUX_TEST_COUNTS[SKIP]))
        cecho "${BAUX_TEST_COLORS[SKIP]}" "${BAUX_TEST_PROMPTS[SKIP]}"
        return 0
    fi
    # exec in sub shell for avoiding exit
    err_msg=$(
        eval "$encode_name() {
            BAUX_TEST_COUNTS[TOTAL]=0
            BAUX_TEST_COUNTS[PASS]=0
            BAUX_TEST_COUNTS[FAIL]=0
            $tests
            return \${BAUX_TEST_COUNTS[FAIL]}
        }" &>/dev/null || die "subtest \"$name\" init fail." 2>&1 >/dev/null

        "$encode_name" 2>&1 >/dev/null
    )
    status="$?"
    if [[ $status -eq 0 ]]; then
        ((++BAUX_TEST_COUNTS[PASS]))
        cecho "${BAUX_TEST_COLORS[PASS]}" "\\x1B[1G${BAUX_TEST_PROMPTS[PASS]}"
    else
        ((++BAUX_TEST_COUNTS[FAIL]))
        cecho "${BAUX_TEST_COLORS[FAIL]}" "\\x1B[1G${BAUX_TEST_PROMPTS[FAIL]}" >&2
        cecho "${BAUX_TEST_COLORS[EMSG]}" "$BAUX_TEST_PAD_SPACES $(__location 0)" >&2
        echo -e "$err_msg" >&2
    fi
    return $status
}

skip() {
    BAUX_TEST_SKIP_FLAG=1
}

summary() {
    for it in TOTAL PASS FAIL SKIP; do
        echo -n "$(cecho ${BAUX_TEST_COLORS[$it]} \
            ${BAUX_TEST_PROMPTS[$it]}): ${BAUX_TEST_COUNTS[$it]}, "
    done
    local -i percentage=0
    [[ ${BAUX_TEST_COUNTS[TOTAL]} -ne 0 ]] \
        && percentage=$((BAUX_TEST_COUNTS[PASS] * 100 / BAUX_TEST_COUNTS[TOTAL]))
    echo "${percentage}% pass."
    return ${BAUX_TEST_COUNTS[FAIL]}
}

# vim:ft=sh:ts=4:sw=4
