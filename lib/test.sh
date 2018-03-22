#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_TEST_SOURCED -eq 1 ]] && return
declare -gr BAUX_TEST_SOURCED=1
declare -gr BAUX_TEST_ABS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd)

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_TEST_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_TEST_ABS_DIR/baux.sh"
fi

is_defined() {
    for var in "$@"; do
        def=$(declare -p "$var" 2>/dev/null)
        if [[ -z $def ]]; then
            declare -F "$var" &>/dev/null || return 1
        fi
    done
    return 0
}

declare -A BAUX_TEST_TYPES
BAUX_TEST_TYPES[-]="normal"
BAUX_TEST_TYPES[a]="array"
BAUX_TEST_TYPES[A]="map"
BAUX_TEST_TYPES[n]="reference"
BAUX_TEST_TYPES[i]="integer"
BAUX_TEST_TYPES[r]="readonly"
BAUX_TEST_TYPES[l]="lower"
BAUX_TEST_TYPES[u]="upper"
BAUX_TEST_TYPES[x]="export"

typeof() {
    local -a types=()
    for var in "$@"; do
        local def=$(declare -p "$var" 2>/dev/null)
        if [[ -z $def ]]; then
            declare -F "$var" &>/dev/null && types+=("function") && continue
            types+=("undefined") && continue
        fi
        [[ $def =~ -([-aAnirlux]) ]]
        types+=("${BAUX_TEST_TYPES[${BASH_REMATCH[1]}]}")
    done
    echo "${types[@]}"
}

is_type() {
    local type="$1"; shift
    local -a types=($(typeof "$@"))
    types=("${types[@]//$type/}")
    [[ ${types[*]} =~ ^[[:space:]]*$ ]]
}

# test variabe declare
is_array() { is_type array "$@"; }
is_map() { is_type map "$@"; }
is_ref() { is_type reference "$@"; }
is_int() { is_type integer "$@"; }
is_lower() { is_type lower "$@"; }
is_upper() { is_type upper "$@"; }
is_export() { is_type export "$@"; }
is_func() { is_type function "$@"; }

# vim:ft=sh:ts=4:sw=4
