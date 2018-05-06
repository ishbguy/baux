#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_SOURCED -eq 1 ]] && return
declare -gr BAUX_SOURCED=1
declare -gr BAUX_ABS_DIR="$(dirname $(realpath "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_ENSURE_SOURCED -ne 1 ]]; then
    [[ ! -e $BAUX_ABS_DIR/ensure.sh ]] \
        && { echo "Can not source the dependent script ensure.sh." >&2; exit 1; }
    source "$BAUX_ABS_DIR/ensure.sh"
fi

# global variables
declare -gi BAUX_EXIT_CODE=0
declare -gA BAUX_IMPORT_FILES

die_hook() { true; }
die() {
    echo -e "$@" >&2
    die_hook
    exit $((++BAUX_EXIT_CODE))
}

warn() {
    echo -e "$@" >&2
    return $((++BAUX_EXIT_CODE))
}

proname() { basename "${0##+(-)}"; }
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
        echo -e "$HELP"
    else
        warn "You need to define a HELP variable."
    fi
    return $BAUX_EXIT_CODE
}

import() {
    ensure "$# -ge 1" "Need to specify an import file."
    ensure_not_empty "$@"

    for file in "$@"; do
        [[ -e $file ]] || die "$file does not exist."
        # ensure source one time
        [[ -z ${BAUX_IMPORT_FILES[$file]} ]] || continue
        local file_path=$(realpath "$file")
        source "$file_path"
        BAUX_IMPORT_FILES[$file_path]="$file_path"
    done
}

# vim:ft=sh:ts=4:sw=4
