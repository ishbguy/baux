#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] && \
    { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_ENSURE_SOURCED -eq 1 ]] && return
declare -gr BAUX_ENSURE_SOURCED=1
declare -gr BAUX_ENSURE_ABS_DIR="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_SOURCED -ne 1 ]]; then
    [[ ! -e $BAUX_ENSURE_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_ENSURE_ABS_DIR/baux.sh"
fi

declare -g BAUX_ENSURE_DEBUG="${DEBUG:-1}"

if [[ $BAUX_ENSURE_DEBUG == "1" ]]; then
    ensure() {
        [[ $# -ge 1 ]] || die "${FUNCNAME[0]}() args error."

        local expr="$1"; shift
        local -a info=($(caller 0))
        (eval "[[ $expr ]]" &>/dev/null) || \
            die "${info[2]}:${info[0]}:${info[1]}: ${FUNCNAME[0]} '$expr' failed." "$@"
    }
    ensure_not_empty() {
        local -a info=($(caller 0))
        for arg in "$@"; do
            [[ -n $(echo "$arg" |sed -r 's/^\s+//;s/\s+$//') ]] || \
                die "${info[2]}:${info[0]}:${info[1]}: Arguments should not be empty."
        done
    }
    ensure_is() {
        ensure "$# -ge 2" "Need two string args."

        local -a info=($(caller 0))
        local expect="$1" actual="$2"; shift 2
        [[ "x$expect" == "x$actual" ]] || die "${info[2]}:${info[0]}:${info[1]}:" \
            "${FUNCNAME[0]} failed: $*\\nExpect: $expect\\nActual: $actual"
    }
    ensure_isnt() {
        ensure "$# -ge 2" "Need two string args."

        local -a info=($(caller 0))
        local nexpect="$1" actual="$2"; shift 2
        [[ "x$nexpect" != "x$actual" ]] || die "${info[2]}:${info[0]}:${info[1]}:" \
            "${FUNCNAME[0]} failed: $*\\nNot Expect: $nexpect\\nActual: $actual"
    }
    ensure_like() {
        ensure "$# -ge 2" "Need two string args."

        local -a info=($(caller 0))
        local expect="$1" actual="$2"; shift 2
        [[ $expect =~ $actual ]] || die "${info[2]}:${info[0]}:${info[1]}:" \
            "${FUNCNAME[0]} failed: $*\\nExpect: $expect\\nActual: $actual"
    }
    ensure_unlike() {
        ensure "$# -ge 2" "Need two string args."

        local -a info=($(caller 0))
        local nexpect="$1" actual="$2"; shift 2
        [[ ! $nexpect =~ $actual ]] || die "${info[2]}:${info[0]}:${info[1]}:" \
            "${FUNCNAME[0]} failed: $*\\nNot Expect: $expect\\nActual: $actual"
    }
    ensure_run() {
        ensure "$# -ge 1" "Need a cmd and a error message."

        local -a info=($(caller 0))
        local cmd="$1"; shift
        (eval "$cmd") || die "${info[2]}:${info[0]}:${info[1]}:" \
            "${FUNCNAME[0]} fail to run: '$cmd'." "$@"
    }
else
    ensure() { true; }
    ensure_not_empty() { true; }
    ensure_is() { true; }
    ensure_isnt() { true; }
    ensure_like() { true; }
    ensure_unlike() { true; }
    ensure_run() { eval "$1" || true; }
fi

# vim:ft=sh:ts=4:sw=4
