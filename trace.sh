#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_TRACE_SOURCED -eq 1 ]] && return
declare -gr BAUX_TRACE_SOURCED=1
declare -gr BAUX_TRACE_ABS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
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

    # contruct a frame array include: file line funcname line_content
    local -A frame
    frame[file]="${BASH_SOURCE[$((idx+2))]}"
    frame[line]="${BASH_LINENO[$((idx+1))]}"
    frame[caller]="${FUNCNAME[$((idx+2))]}"
    local line_content=$(sed -n -e "${frame[line]}p" "${frame[file]}" \
        | sed -r 's/^\s+//')
    frame[line_content]="$line_content"

    echo "${frame[line_content]} [${frame[file]}:${frame[line]}:${frame[caller]}]"
}

callstack() {
    ensure "$# -le 1" "Need zero or one index number."

    local -i idx=0
    [[ -n $1 && $1 =~ [0-9]+ ]] && idx="$1"
    # skip the current func
    local depth=$((${#FUNCNAME[@]} - 1))

    local indent="+ "
    for ((i = idx; i < depth; i++)); do
        echo "$indent$(frame $i)"
        indent="  $indent"
    done
}

# vim:ft=sh:ts=4:sw=4
