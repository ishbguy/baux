#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_ARRAY_SOURCED -eq 1 ]] && return
declare -gr BAUX_ARRAY_SOURCED=1
declare -gr BAUX_ARRAY_ABS_DIR="$(dirname $(realpath "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_SOURCED -ne 1 ]]; then
    [[ ! -e $BAUX_ARRAY_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_ARRAY_ABS_DIR/baux.sh"
fi

import "$BAUX_ARRAY_ABS_DIR/var.sh"

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
        [[ -n $idx && -n ${__array[$idx]} ]] || continue
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
    [[ -n $2 && -n ${__array[$2]} ]]
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

_uniq() {
    local -A uniq
    for it in "$@"; do
        [[ $it == "" ]] && continue
        uniq[$it]=1
    done
    echo "${!uniq[@]}"
}

__swap() {
    local -n __array="$1"
    local tmp=${__array[$2]}
    __array[$2]=${__array[$3]}
    __array[$3]=$tmp
}

__cmp() { [[ $1 -gt $2 ]]; }

__issorted() {
    local -a array=("$@")
    local len=${#array[@]}
    for ((i = 0; i < $((len-1)); i++)); do
        __cmp "${array[$i]}" "${array[$i+1]}" && return 1
    done
    return 0
}

_sort() {
    local opt="-n"
    eval "[[ $1 =~ ^- ]]" &>/dev/null && opt="$1" && shift
    echo "$@" | sed -r 's/\s+/\n/g' | sort "$opt"
}

# below search algo just for practise :)

select_sort() {
    local cmp=__cmp
    is_func "$1" && cmp=$1 && shift
    local -a array=("$@")

    for ((i = 0; i < ${#array[@]}; i++)); do
        for ((j = i+1; j < ${#array[@]}; j++)); do
            "$cmp" "${array[$i]}" "${array[$j]}" && __swap array "$i" "$j"
        done
    done
    echo "${array[@]}"
}

insert_sort() {
    local cmp=__cmp
    is_func "$1" && cmp="$1" && shift
    local -a array=("$@")
    
    for ((i = 1; i < ${#array[@]}; i++)); do
        for ((j = i; j > 0; j--)); do
            "$cmp" "${array[$j-1]}" "${array[$j]}" && __swap array "$j" "$((j-1))"
        done
    done
    echo "${array[@]}"
}

shell_sort() {
    local cmp=__cmp
    is_func "$1" && cmp="$1" && shift
    local -a array=("$@")
    local l=${#array[@]}
    local h=1
    
    while ((h < l/3)); do h=$((3*h+1)); done
    
    while ((h>=1)); do
        for ((i = h; i < ${#array[@]}; i++)); do
            for ((j = i; j >= h; j = j-h)); do
                "$cmp" "${array[$j-$h]}" "${array[$j]}" \
                    && __swap array "$j" "$((j-h))"
            done
        done
        h=$((h/3))
    done
    echo "${array[@]}"
}

search() {
    ensure "$# -ge 1" "Need at least an array name."
    is_array "$1" || is_map "$1" || die "$1 is not an array name."

    local -n __array="$1"; shift
    local -a indexs=()
    local -A keys
    for idx in "${!__array[@]}"; do
        keys[${__array[$idx]}]="$idx"
    done
    for need in "$@"; do
        [[ -n $need && -n ${keys[$need]} ]] \
            && indexs+=("${keys[$need]}")
    done
    echo "${indexs[@]}"
}

lsearch() {
    ensure "$# -eq 2" "Need an array name and a item"
    is_array "$1" || is_map "$1" || die "$1 is not an array name."

    local -n __array="$1"
    local need="$2"
    for idx in "${!__array[@]}"; do
        [[ ${__array[$idx]} == "$need" ]] && echo "$idx" && return 0
    done
    return 1
}

bsearch() {
    ensure "$# -eq 2" "Need an array name and a item"
    local cmp=__cmp
    is_func "$1" && cmp="$1" && shift
    is_array "$1" || is_map "$1" || die "$1 is not an array name."

    local -n __array="$1"
    local need="$2"
    local low mid hi
    
    low=0
    hi=$((${#__array[@]}-1))
    while ((low <= hi)); do
        mid=$(((low+hi)/2))
        [[ ${__array[$mid]} == "$need" ]] && echo "$mid" && return 0
        if __cmp "${__array[$mid]}" "$need" ; then
            hi=$((mid-1))

        else
            low=$((mid+1))
        fi
    done
    return 1
}

# vim:ft=sh:ts=4:sw=4
