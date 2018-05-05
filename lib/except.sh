#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_EXCEPT_SOURCED -eq 1 ]] && return
declare -gr BAUX_EXCEPT_SOURCED=1
declare -gr BAUX_EXCEPT_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# source dependences
if [[ $BAUX_SOURCED -ne 1 ]]; then
    [[ ! -e $BAUX_EXCEPT_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_EXCEPT_ABS_DIR/baux.sh"
fi

import "$BAUX_EXCEPT_ABS_DIR/array.sh"
import "$BAUX_EXCEPT_ABS_DIR/trace.sh"

declare -ga BAUX_EXCEPT_STACK
declare -gA BAUX_EXCEPT_SET_FLAGS
declare -ga BAUX_EXCEPT_TRAP_CMD

__backup_set_flags() {
    local -n flags="$1"
    local flags_str="$(echo "$-")"
    local len="${#flags_str}"
    
    for ((i = 0; i < $len; i++)); do
        flags[${flags_str:$i:1}]=1
    done
}

__restore_set_flags() {
    local -n flags="$1"; shift
    for f in "$@"; do
        [[ ${flags[$f]} == 1 ]] && set -$f
    done
}

__trap_cmd() {
    trap -p $1 | sed -r "s/.*'(.*)'.*/\1/"
}

__restore_trap_cmd() {
    local cmd="$1"
    local SIG="$2"
    [[ -n $cmd ]] || return
    trap "$cmd" $SIG
}

shopt -s expand_aliases
alias try='\
    push BAUX_EXCEPT_TRAP_CMD "$(__trap_cmd ERR)"; \
    trap 'break' ERR; \
    __try_loop_one=1 && while ((__try_loop_one--)); do'

alias try_end='done; __restore_trap_cmd "$(pop BAUX_EXCEPT_TRAP_CMD)" ERR'

alias catch='\
    [[ ${#BAUX_EXCEPT_STACK[@]} -ne 0 ]] \
    && __catch_loop_one=1 && while ((__catch_loop_one--)); do'

alias catch_end='done && pop BAUX_EXCEPT_STACK 1>/dev/null'

throw() { push BAUX_EXCEPT_STACK "$*"; warn "$@"; }

# vim:ft=sh:ts=4:sw=4
