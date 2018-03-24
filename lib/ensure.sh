#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_ENSURE_SOURCED -eq 1 ]] && return
declare -gr BAUX_ENSURE_SOURCED=1
declare -gr BAUX_ENSURE_ABS_DIR=$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd)

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_ENSURE_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_ENSURE_ABS_DIR/baux.sh"
fi

declare -g BAUX_ENSURE_DEBUG="${DEBUG:-1}"

if [[ $BAUX_ENSURE_DEBUG == "1" ]]; then
    ensure() {
        local expression="$1"
        local message="$2"

        [[ $# -ge 1 ]] || die "${FUNCNAME[0]}() args error."

        [[ -n $message ]] && message=": $message"
        eval "[[ $expression ]]" &>/dev/null \
            || die "$(caller 0): ${FUNCNAME[0]} \"$expression\" failed$message."
    }

    ensure_not_empty() {
        for arg in "$@"; do
            [[ -n $(echo $arg |sed -r 's/^\s+//;s/\s+$//') ]] || die \
                "$(caller 0): Arguments should not be empty."
        done
    }

    ensure_is() {
        ensure "$# -ge 2 || $# -le 3" "Need two string args."

        [[ "$1" == "$2" ]] \
            || die "$(caller 0): ${FUNCNAME[0]} failed: $3\\nExpect: $1\\nActual: $2"
    }

    ensure_isnt() {
        ensure "$# -ge 2 || $# -le 3" "Need two string args."

        [[ "$1" != "$2" ]] \
            || die "$(caller 0): ${FUNCNAME[0]} failed: $3\\nNot Expect: $1\\nActual: $2"
    }

    ensure_like() {
        ensure "$# -ge 2 || $# -le 3" "Need two string args."

        [[ $1 =~ $2 ]] \
            || die "$(caller 0): ${FUNCNAME[0]} failed: $3\\nExpect: $1\\nActual: $2"
    }

    ensure_unlike() {
        ensure "$# -ge 2 || $# -le 3" "Need two string args."

        [[ ! $1 =~ $2 ]] \
            || die "$(caller 0): ${FUNCNAME[0]} failed: $3\\nNot Expect: $1\\nActual: $2"
    }
else
    ensure() { true; }
    ensure_not_empty() { true; }
    ensure_is() { true; }
    ensure_isnt() { true; }
    ensure_like() { true; }
    ensure_unlike() { true; }
fi

# vim:ft=sh:ts=4:sw=4
