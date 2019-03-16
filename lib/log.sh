#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_LOG_SOURCED -eq 1 ]] && return
declare -gr BAUX_LOG_SOURCED=1
declare -gr BAUX_LOG_ABS_DIR="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_SOURCED -ne 1 ]]; then
    [[ ! -e $BAUX_LOG_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_LOG_ABS_DIR/baux.sh"
fi

declare -g   BAUX_LOG_OUTPUT_FILE=
declare -g   BAUX_LOG_OUTPUT_LEVEL="debug"
declare -i   BAUX_LOG_LEVEL_BASE=0
declare -i   BAUX_LOG_LEVEL_TIME=8
declare -gra BAUX_LOG_LEVELS=("quiet" "panic" "fatal" "error" "warn" "info" "debug")
declare -gA  BAUX_LOG_LEVEL

for level in "${BAUX_LOG_LEVELS[@]}"; do
    BAUX_LOG_LEVEL[$level]=$((BAUX_LOG_LEVEL_TIME * BAUX_LOG_LEVEL_BASE++))
done

__datetime() { date '+%Y-%m-%d %H:%M:%S'; }

log() {
    ensure "$# -eq 2" "Need a log level and a log message."
    ensure_not_empty "$1"
    ensure "-n ${BAUX_LOG_LEVEL[$1]}" "Log level must be: ${BAUX_LOG_LEVEL[*]}"

    local level="$1"
    local message="$2"

    [[ ${BAUX_LOG_LEVEL[$level]} -gt ${BAUX_LOG_LEVEL[$BAUX_LOG_OUTPUT_LEVEL]} ]] && return

    # log out to a file or to standard output
    if [[ -n $BAUX_LOG_OUTPUT_FILE ]]; then
        [[ -e $BAUX_LOG_OUTPUT_FILE ]] || echo -n >$BAUX_LOG_OUTPUT_FILE \
            || warn "Can not create log file: $BAUX_LOG_OUTPUT_FILE" || return 1
        [[ -w $BAUX_LOG_OUTPUT_FILE ]] \
            || warn "Log file $BAUX_LOG_OUTPUT_FILE can not write" || return 1
        # append to log file
        exec 3>>$BAUX_LOG_OUTPUT_FILE
        exec 1>&3
        trap 'exec 3>&1; exec 3>&-' RETURN
    fi

    echo "$(__datetime)|$(proname)[$$]|${level^^}|${FUNCNAME[1]}| $message"
}

# vim:ft=sh:ts=4:sw=4
