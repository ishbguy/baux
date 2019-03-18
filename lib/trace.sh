#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_TRACE_SOURCED -eq 1 ]] && return
declare -gr BAUX_TRACE_SOURCED=1
declare -gr BAUX_TRACE_ABS_DIR="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_SOURCED -ne 1 ]]; then
    [[ ! -e $BAUX_TRACE_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_TRACE_ABS_DIR/baux.sh"
fi

frame() {
    ensure "$# -le 1" "Need zero or one index number."

    local -i idx=0
    [[ -n $1 && $1 =~ [0-9]+ ]] && idx="$1"

    # ensure not over flow
    [[ $((idx+2)) -lt ${#FUNCNAME[@]} ]] || return

    # contruct a frame array include: file line func caller line_content
    local -a frame
    frame+=("${BASH_SOURCE[$((idx+2))]}")
    frame+=("${BASH_LINENO[$((idx+1))]}")
    frame+=("${FUNCNAME[$((idx+1))]}")
    frame+=("${FUNCNAME[$((idx+2))]}")

    echo "${frame[@]}"
}

callstack() {
    ensure "$# -le 1" "Need zero or one index number."

    local -i idx=0
    [[ -n $1 && $1 =~ [0-9]+ ]] && idx="$1"
    # skip the current func
    local depth=$((${#FUNCNAME[@]} - 1))

    local indent="+"
    for ((i = idx; i < depth; i++)); do
        local -a frame=($(frame "$i"))
        local cmd=$(sed -ne "${frame[1]}p" "${frame[0]}" | sed -r 's/^\s+//')
        echo "$indent $cmd [${frame[0]}:${frame[1]}:${frame[3]}]"
        indent="  $indent"
    done
}

# vim:ft=sh:ts=4:sw=4
