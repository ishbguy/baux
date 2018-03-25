#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_SOUECED -eq 1 ]] && return
declare -gr BAUX_SOUECED=1
declare -gr BAUX_ABS_DIR=$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd)

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
    BAUX_EXIT_CODE=$((BAUX_EXIT_CODE+1))
    exit $BAUX_EXIT_CODE
}

warn() {
    echo -e "$@" >&2
    BAUX_EXIT_CODE=$((BAUX_EXIT_CODE+1))
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

if ! hash realpath &>/dev/null; then
    realpath() {
        ensure "$# -eq 1" "Need to specify a file."
        ensure_not_empty "$1"

        local dir=$(dirname "$1")
        [[ -d $dir ]] && builtin cd "$dir" || return 1
        echo "$(pwd)/$(basename "$1")"
    }
fi

import() {
    ensure "$# -ge 1" "Need to specify an import file."
    ensure_not_empty "$@"

    for file in "$@"; do
        [[ -e $file ]] || die "$file does not exist."
        # ensure source one time
        [[ -z ${BAUX_IMPORT_FILES[$file]} ]] || continue
        source "$file" || die "Can not import $file."
        local file_path=$(realpath "$file")
        BAUX_IMPORT_FILES[$file_path]="$file_path"
    done
}

# vim:ft=sh:ts=4:sw=4
