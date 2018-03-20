#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_UNIT_SOURCED -eq 1 ]] && return
declare -gr BAUX_UNIT_SOURCED=1
declare -gr BAUX_UNIT_ABS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_UNIT_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_UNIT_ABS_DIR/baux.sh"
fi

import "$BAUX_UNIT_ABS_DIR/utili.sh"
import "$BAUX_UNIT_ABS_DIR/trace.sh"

declare -gi BAUX_UNIT_COUNT=0
declare -gi BAUX_UNIT_PASS=0
declare -gi BAUX_UNIT_FAIL=0
declare -gi BAUX_UNIT_SKIP=0
declare -gi BAUX_UNIT_SKIP_FLAG=0
declare -gi BAUX_UNIT_SUB_FLAG=0
declare -ga BAUX_UNIT_TESTS=()
declare -ga BAUX_UNIT_SUB_TESTS=()

__judge() {
    local expr="$1"
    ((++BAUX_UNIT_COUNT))
    if (eval "[[ $expr ]]" &>/dev/null); then
        ((++BAUX_UNIT_PASS))
        result="OK"
    else
        ((++BAUX_UNIT_FAIL))
        result="FAIL"
    fi
}

__issue() {
    local -u result="$1"
    local msg="$2"
    local -A colors
    colors[OK]="green"
    colors[FAIL]="red"
    colors[SKIP]="yellow"

    echo "$BAUX_UNIT_COUNT $(cecho ${colors[$result]} $result) $msg"
}

__location() {
    local idx="$(($1+1))"
    local -a frame=($(frame "$idx"| sed -r 's/\s+/\n/g'))
    local cmd=$(sed -ne "${frame[1]}p" "${frame[0]}" | sed -r 's/^\s+//')
    echo "$cmd [${frame[0]}:${frame[1]}:${frame[3]}]"
}

__diag() {
    local result="$1"
    local expect="$2"
    local actual="$3"
    [[ $result != "FAIL" ]] && return 0

    # fail
    cecho red "$(__location 1)"
    cecho red "Expect: $expect"
    cecho red "Actual: $actual"
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
    [[ $result != "FAIL" ]] || { cecho red "$(__location 0)"; return 1; }
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

subtest() {
    ensure "$# -eq 2" "Need test name and test instructions"
    ensure_not_empty "$1"

    local name=$(echo "$1" | sed -r 's/[[:punct:][:space:]]/_/g')
    local cmd="$2"
    local ouput

    eval "$name() {
    $cmd
    }" &>/dev/null || die "subtest '$1' init fail."

    # exec in sub shell for avoiding exit
    (eval "$name")
}

skip() {
    true
}

summary() {
    true
}

# vim:ft=sh:ts=4:sw=4
