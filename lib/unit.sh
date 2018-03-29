#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_UNIT_SOURCED -eq 1 ]] && return
declare -gr BAUX_UNIT_SOURCED=1
declare -gr BAUX_UNIT_ABS_DIR="$(dirname $(realpath "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_UNIT_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_UNIT_ABS_DIR/baux.sh"
fi

import "$BAUX_UNIT_ABS_DIR/utili.sh"
import "$BAUX_UNIT_ABS_DIR/trace.sh"

declare -gA BAUX_UNIT_PROMPTS
declare -gA BAUX_UNIT_COLORS
declare -gA BAUX_UNIT_COUNTS
declare -gi BAUX_UNIT_SKIP_FLAG=0

BAUX_UNIT_COUNTS[TOTAL]=0
BAUX_UNIT_COUNTS[PASS]=0
BAUX_UNIT_COUNTS[FAIL]=0
BAUX_UNIT_COUNTS[SKIP]=0

BAUX_UNIT_PROMPTS[TOTAL]="TOTAL"
BAUX_UNIT_PROMPTS[PASS]="PASS"
BAUX_UNIT_PROMPTS[FAIL]="FAIL"
BAUX_UNIT_PROMPTS[SKIP]="SKIP"

BAUX_UNIT_COLORS[TOTAL]="blue"
BAUX_UNIT_COLORS[PASS]="green"
BAUX_UNIT_COLORS[FAIL]="red"
BAUX_UNIT_COLORS[SKIP]="yellow"

__judge() {
    local expr="$1"
    ((++BAUX_UNIT_COUNTS[TOTAL]))
    if [[ $BAUX_UNIT_SKIP_FLAG -eq 1 ]]; then
        ((++BAUX_UNIT_COUNTS[SKIP]))
        BAUX_UNIT_SKIP_FLAG=0
        result="SKIP"
        return
    fi
    if (eval "[[ $expr ]]" &>/dev/null); then
        ((++BAUX_UNIT_COUNTS[PASS]))
        result="PASS"
    else
        ((++BAUX_UNIT_COUNTS[FAIL]))
        result="FAIL"
    fi
}

__issue() {
    local -u result="$1"
    local msg="$2"

    echo "${BAUX_UNIT_COUNTS[TOTAL]} $msg $(cecho \
        "${BAUX_UNIT_COLORS[$result]}" "${BAUX_UNIT_PROMPTS[$result]}")"
}

__location() {
    local idx="$(($1+1))"
    local -a frame=($(frame "$idx"| sed -r 's/\s+/\n/g'))
    local cmd=$(sed -ne "${frame[1]}p" "${frame[0]}" 2>/dev/null | sed -r 's/^\s+//')
    echo "$cmd [${frame[0]}:${frame[1]}:${frame[3]}]"
}

__diag() {
    local result="$1"
    local expect="$2"
    local actual="$3"
    [[ $result != "${BAUX_UNIT_PROMPTS[FAIL]}" ]] && return 0

    # fail
    cecho red "$(__location 1)" >&2
    cecho red "Expect: $expect" >&2
    cecho red "Actual: $actual" >&2
    return 1
}

ok() {
    ensure "$# -ge 1 && $# -le 2" "Need at least an expression."
    ensure_not_empty "$1"

    local expr="$1"
    local msg="${2:-$1}"
    local -u result
    __judge "$expr"
    __issue "$result" "$msg"
    [[ $result != "${BAUX_UNIT_PROMPTS[FAIL]}" ]] \
        || { cecho red "$(__location 0)" >&2; return 1; }
}

is() {
    ensure "$# -ge 2 && $# -le 3" "Need expect, actual, message(optional) args."
    
    local expect="$1"
    local actual="$2"
    local msg="${3:-[[ $1 == $2 ]]}"
    local -u result
    __judge "'$expect' == '$actual'"
    __issue "$result" "$msg"
    __diag "$result" "'$expect'" "'$actual'" 
}

isnt() {
    ensure "$# -ge 2 && $# -le 3" "Need expect, actual, message(optional) args."
    
    local expect="$1"
    local actual="$2"
    local msg="${3:-[[ $1 != $2 ]]}"
    local -u result
    __judge "'$expect' != '$actual'"
    __issue "$result" "$msg"
    __diag "$result" "'$expect'" "'$actual'" 
}

like() {
    ensure "$# -ge 2 && $# -le 3" "Need expect, actual, message(optional) args."
    
    local expect="$1"
    local actual="$2"
    local msg="${3:-[[ $1 =~ $2 ]]}"
    local -u result
    __judge "'$expect' =~ '$actual'"
    __issue "$result" "$msg"
    __diag "$result" "'$expect'" "'$actual'" 
}

unlike() {
    ensure "$# -ge 2 && $# -le 3" "Need expect, actual, message(optional) args."
    
    local expect="$1"
    local actual="$2"
    local msg="${3:-[[ ! $1 =~ $2 ]]}"
    local -u result
    __judge "! '$expect' =~ '$actual'"
    __issue "$result" "$msg"
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
    
    output=$(eval "$@" 2>&1)
    status=$?

    __judge "$expr"
    __issue "$result" "$msg"
    [[ $result != "${BAUX_UNIT_PROMPTS[FAIL]}" ]] \
        || { cecho red "$(__location 0)\nStatus: $status\nOutput: '$output'" >&2; \
        return 1; }
}

subtest() {
    ensure "$# -eq 2" "Need test name and test instructions"
    ensure_not_empty "$1"

    local name="$1"
    local tests="$2"
    local encode_name=$(echo "$name" | sed -r 's/[[:punct:][:space:]]/_/g')
    local err_msg status

    eval "$encode_name() {
        BAUX_UNIT_COUNTS[TOTAL]=0
        BAUX_UNIT_COUNTS[PASS]=0
        BAUX_UNIT_COUNTS[FAIL]=0;
        $tests
        return \${BAUX_UNIT_COUNTS[FAIL]}
    }" &>/dev/null || die "subtest \"$name\" init fail."

    ((++BAUX_UNIT_COUNTS[TOTAL]))
    echo -ne "${BAUX_UNIT_COUNTS[TOTAL]} subtest: $name "

    # return if skip
    if [[ $BAUX_UNIT_SKIP_FLAG -eq 1 ]]; then
        BAUX_UNIT_SKIP_FLAG=0
        ((++BAUX_UNIT_COUNTS[SKIP]))
        cecho "${BAUX_UNIT_COLORS[SKIP]}" "${BAUX_UNIT_PROMPTS[SKIP]}"
        return 0
    fi
    # exec in sub shell for avoiding exit
    err_msg=$(eval "$encode_name" 2>&1 >/dev/null)
    status="$?"
    if [[ $status -eq 0 ]]; then
        ((++BAUX_UNIT_COUNTS[PASS]))
        cecho "${BAUX_UNIT_COLORS[PASS]}" "${BAUX_UNIT_PROMPTS[PASS]}"
        return 0
    else
        ((++BAUX_UNIT_COUNTS[FAIL]))
        cecho "${BAUX_UNIT_COLORS[FAIL]}" "${BAUX_UNIT_PROMPTS[FAIL]}\n$err_msg" >&2
        return 1
    fi
}

skip() {
    BAUX_UNIT_SKIP_FLAG=1
}

summary() {
    for it in TOTAL PASS FAIL SKIP; do
        echo -n "$(cecho ${BAUX_UNIT_COLORS[$it]} \
            ${BAUX_UNIT_PROMPTS[$it]}): ${BAUX_UNIT_COUNTS[$it]}, "
    done
    echo
    return ${BAUX_UNIT_COUNTS[FAIL]}
}

# vim:ft=sh:ts=4:sw=4
