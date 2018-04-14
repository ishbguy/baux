#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_VAR_SOURCED -eq 1 ]] && return
declare -gr BAUX_VAR_SOURCED=1
declare -gr BAUX_VAR_ABS_DIR="$(dirname $(realpath "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_VAR_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_VAR_ABS_DIR/baux.sh"
fi

declare -gA BAUX_VAR_TYPES
BAUX_VAR_TYPES[N]="normal"
BAUX_VAR_TYPES[a]="array"
BAUX_VAR_TYPES[A]="map"
BAUX_VAR_TYPES[n]="reference"
BAUX_VAR_TYPES[i]="integer"
BAUX_VAR_TYPES[r]="readonly"
BAUX_VAR_TYPES[l]="lower"
BAUX_VAR_TYPES[u]="upper"
BAUX_VAR_TYPES[x]="export"
BAUX_VAR_TYPES[f]="function"
BAUX_VAR_TYPES[U]="undefined"

typeof() {
    local -a types=()
    for var in "$@"; do
        local def=$(declare -p "$var" 2>/dev/null)
        if [[ -z $def ]]; then
            declare -F "$var" &>/dev/null \
                && types+=("${BAUX_VAR_TYPES[f]}") && continue
            types+=("${BAUX_VAR_TYPES[U]}") && continue
        fi
        [[ $def =~ -([-aAnirlux]) ]]
        local match="${BASH_REMATCH[1]}"
        [[ $match == '-' ]] && match=N
        types+=("${BAUX_VAR_TYPES[$match]}")
    done
    echo "${types[@]}"
}

defined() {
    local -a types=($(typeof "$@"))
    [[ ! ${types[*]} =~ ${BAUX_VAR_TYPES[U]} ]]
}

istype() {
    local type="$1"; shift
    local -a types=("$(typeof "$@")")
    types=("${types[@]//$type/}")
    [[ ${types[*]} =~ ^[[:space:]]*$ ]]
}

# test variabe declare
is_array() { istype array "$@"; }
is_map() { istype map "$@"; }
is_ref() { istype reference "$@"; }
is_int() { istype integer "$@"; }
is_lower() { istype lower "$@"; }
is_upper() { istype upper "$@"; }
is_export() { istype export "$@"; }
is_func() { istype function "$@"; }

# vim:ft=sh:ts=4:sw=4
