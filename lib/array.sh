#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_ARRAY_SOURCED -eq 1 ]] && return
declare -gr BAUX_ARRAY_SOURCED=1
declare -gr BAUX_ARRAY_ABS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_ARRAY_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_ARRAY_ABS_DIR/baux.sh"
fi

import "$BAUX_ARRAY_ABS_DIR/test.sh"

push() {
    ensure "$# -ge 1" "Need at least an array name."
    is_array "$1" || die "$1 is not an array name."

    local -n __array="$1"; shift

    __array+=("$@")
}

pop() {
    ensure "$# -eq 1" "Only need an array name."
    is_array "$1" || die "$1 is not an array name."

    local -n __array="$1"

    [[ ${#__array[@]} -eq 0 ]] && return 0
    echo "${__array[$((${#__array[@]}-1))]}"
    __array=("${__array[@]:0:$((${#__array[@]}-1))}")
}

_shift() {
    ensure "$# -eq 1" "Only need an array name."
    is_array "$1" || die "$1 is not an array name."

    local -n __array="$1"

    [[ ${#__array[@]} -eq 0 ]] && return 0
    echo "${__array[0]}"
    __array=("${__array[@]:1:${#__array[@]}}")
}

unshift() {
    ensure "$# -ge 1" "Need at least an array name."
    is_array "$1" || die "$1 is not an array name."

    local -n __array="$1"; shift

    __array=("$@" "${__array[@]}")
}

slice() {
    ensure "$# -ge 1" "Need at least an array name."
    is_array "$1" || is_map "$1" || die "$1 is not an array name."

    local -n __array="$1"; shift
    local -a slices=()

    for idx in "$@"; do
        [[ $idx -ge 0 ]] || die "$idx is little than 0."
        [[ -n ${__array[$idx]} ]] || continue
        slices+=("${__array[$idx]}")
    done

    echo "${slices[@]}"
}

keys() {
    ensure "$# -eq 1" "Need only an array name."
    is_array "$1" || is_map "$1" || die "$1 is not an array name."

    local -n __array="$1"

    echo "${!__array[@]}"
}

values() {
    ensure "$# -eq 1" "Need only an array name."
    is_array "$1" || is_map "$1" || die "$1 is not an array name."

    local -n __array="$1"
    echo "${__array[@]}"
}

exists() {
    ensure "$# -eq 2" "Need an array name and a key"
    is_array "$1" || is_map "$1" || die "$1 is not an array name."
    
    local -n __array="$1"
    [[ -n ${__array[$2]} ]]
}

_join() {
    local sep="$1"
    local out="$2"
    shift 2

    for it in "$@"; do
        out+="$sep$it"
    done
    echo "$out"
}

_split() {
    ensure "$# -eq 2 || $# -eq 3" "Need at least a string and an array"
    is_array "$2" || die "$1 is not an array name."
    
    local string="$1"
    local -n __array="$2"
    local sep="${3:- }" # space as default seperator

    # no sep in string just save the original string
    [[ $string =~ $sep ]] || { __array=("$string"); return 0; }
    local right left
    while [[ -n $string && $string =~ $sep ]]; do
        right=${string%%$sep*}
        left=${string#$right$sep}
        __array+=("$right")
        string="$left"
    done
    # end is sep, append "" to array
    [[ $1 =~ $sep$ ]] && __array+=("")
    return 0
}

# vim:ft=sh:ts=4:sw=4
