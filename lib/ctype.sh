#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_CTYPE_SOURCED -eq 1 ]] && return
declare -gr BAUX_CTYPE_SOURCED=1
declare -gr BAUX_CTYPE_ABS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)

# source dependences
if [[ $BAUX_SOUECED -ne 1 ]]; then
    [[ ! -e $BAUX_CTYPE_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_CTYPE_ABS_DIR/baux.sh"
fi

ispattern() {
    local pat="$1"; shift
    for var in "$@"; do
        [[ $var =~ $pat ]] || return 1
    done
}

# POSIX compatible
isalnum() { ispattern '^[[:alnum:]]+$' "$@"; }
isalpha() { ispattern '^[[:alpha:]]+$' "$@"; }
isblank() { ispattern '^[[:blank:]]+$' "$@"; }
iscntrl() { ispattern '^[[:cntrl:]]+$' "$@"; }
isdigit() { ispattern '^[[:digit:]]+$' "$@"; }
isgraph() { ispattern '^[[:graph:]]+$' "$@"; }
islower() { ispattern '^[[:lower:]]+$' "$@"; }
isprint() { ispattern '^[[:print:]]+$' "$@"; }
ispunct() { ispattern '^[[:punct:]]+$' "$@"; }
isspace() { ispattern '^[[:space:]]+$' "$@"; }
isupper() { ispattern '^[[:upper:]]+$' "$@"; }
isxdigit() { ispattern '^[[:xdigit:]]+$' "$@"; }

declare -gr BAUX_CTYPE_PAT_FLOAT='[[:digit:]]+\.[[:digit:]]+'
declare -gr BAUX_CTYPE_PAT_REALNUM='[[:digit:]]+(\.[[:digit:]]+)?'
declare -gr BAUX_CTYPE_PAT_IDENT='[_[:alpha:]][_[:alnum:]]*'

isfloat() { ispattern "^${BAUX_CTYPE_PAT_FLOAT}$" "$@"; }
isrealnum() { ispattern "^${BAUX_CTYPE_PAT_REALNUM}$" "$@"; }
isident() { ispattern "^${BAUX_CTYPE_PAT_IDENT}$" "$@"; }

# vim:ft=sh:ts=4:sw=4
