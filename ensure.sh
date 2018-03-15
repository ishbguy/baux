#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_ENSURE_SOURCED -eq 1 ]] && return
declare -gr BAUX_ENSURE_SOURCED=1
declare -gr BAUX_ENSURE_ABS_PATH=$(realpath "${BASH_SOURCE[0]}")
declare -gr BAUX_ENSURE_ABS_DIR="${BAUX_ENSURE_ABS_PATH%/*}"

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_ENSURE_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_ENSURE_ABS_DIR/baux.sh"
fi

ensure_equal() {
    ensure "$# -ge 2 || $# -le 3" "Need two integers args."
    ensure_not_empty "$1" "$2"

    [[ $1 -eq $2 ]] \
        || die "$(caller 0): ${FUNCNAME[0]} failed: $3\\nExpect: $1\\nActual: $2"
}

ensure_not_equal() {
    ensure "$# -ge 2 || $# -le 3" "Need two integers args."
    ensure_not_empty "$1" "$2"

    [[ $1 -ne $2 ]] \
        || die "$(caller 0): ${FUNCNAME[0]} failed: $3\\nNot Expect: $1\\nActual: $2"
}

ensure_match() {
    ensure "$# -ge 2 || $# -le 3" "Need two string args."

    [[ "$1" == "$2" ]] \
        || die "$(caller 0): ${FUNCNAME[0]} failed: $3\\nExpect: $1\\nActual: $2"
}

ensure_mismatch() {
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

# vim:ft=sh:ts=4:sw=4
