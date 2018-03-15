#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

#set -x

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running."; exit 1; }

# readonly constants
declare -gr BAUX_TRUE=0
declare -gr BAUX_FALSE=1
declare -gr BAUX_SUCCESS=0
declare -gr BAUX_FAIL=1
declare -gr BAUX_OK=0

# global variables
declare -gi BAUX_EXIT_CODE=0
declare -gA BAUX_IMPORT_FILES

die_hook() { true; }
die() {
    echo "$@" >&2
    die_hook
    BAUX_EXIT_CODE=$((BAUX_EXIT_CODE+1))
    exit $BAUX_EXIT_CODE
}

warn() {
    echo "$@" >&2
    BAUX_EXIT_CODE=$((BAUX_EXIT_CODE+1))
}

proname() { echo "$0"; }
version() {
    if [[ -n $VERSION ]]; then
        echo "$(proname) $VERSION"
    else
        warn "You need to define a VERSION variable."
    fi
    return $BAUX_EXIT_CODE
}

usage() {
    version
    if [[ -n $HELP ]]; then
        echo "$HELP"
    else
        warn "You need to define a HELP variable."
    fi
    return $BAUX_EXIT_CODE
}

ensure() {
    local expression="$1"
    local message="$2"

    [[ $# -ge 1 ]] || die "${FUNCNAME[0]}() args error."
    
    [[ -n $message ]] && message=": $message"
    eval "[[ $expression ]]" || die "$(caller 0): ${FUNCNAME[0]} \"$expression\" failed$message."
}

ensure_not_empty() {
    ensure "$# -ge 1" "Need one or more args"

    for arg in "$@"; do
        arg="${arg## *}"
        arg="${arg%% *}"
        [[ -n $arg ]] || die \
            "$(caller 0): Arguments should not be empty."
    done
}

import() {
    ensure "$# -ge 1" "Need to specify an import file."
    ensure_not_empty "$@"
    
    for file in "$@"; do
        [[ -e $file ]] || die "$file does not exist."
        # ensure source one time
        [[ -z ${BAUX_IMPORT_FILES[$file]} ]] || continue
        source "$file" || die "Can not import $file."
        BAUX_IMPORT_FILES[$file]="$file"
    done
}

# vim:ft=sh:ts=4:sw=4
