#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_TEST_SOURCED -eq 1 ]] && return
declare -gr BAUX_TEST_SOURCED=1
declare -gr BAUX_TEST_ABS_PATH=$(realpath "${BASH_SOURCE[0]}")
declare -gr BAUX_TEST_ABS_DIR="${BAUX_TEST_ABS_PATH%/*}"

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_TEST_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_TEST_ABS_DIR/baux.sh"
fi


is_defined() {
    ensure "$# -ge 1" "Need at least one variable name."
    ensure_not_empty "$@"

    for var in "$@"; do
        def=$(declare -p "$var" 2>/dev/null)
        if [[ -z $def ]]; then
            declare -F "$var" &>/dev/null || return 1
        fi
    done
    return 0
}

is_type() {
    ensure "$# -ge 2" "Need at least a type name and a variable name."
    ensure_not_empty "$@"

    local type="$1"; shift
    ensure "${#type} -ne 1 || ${type} =~ [aAnifrlux]" "Type should be [a|A|n|i|f|r|l|u|x]."
    is_defined "$@" || return 1

    for var in "$@"; do
        if [[ $type == "f" ]]; then
            declare -F "$var" &>/dev/null || return 1
        else
            def=$(declare -p "$var" 2>/dev/null)
            [[ $def =~ -([-aAnirlux]) ]] || return 1
            [[ ${BASH_REMATCH[1]} == "$type" ]] || return 1
        fi
    done
    return 0
}

# vim:ft=sh:ts=4:sw=4
