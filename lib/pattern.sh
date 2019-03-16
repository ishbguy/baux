#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] \
    && { echo "Only allow to be sourced, not for running." >&2; exit 1; }

# source guard
[[ $BAUX_PATTERN_SOURCED -eq 1 ]] && return
declare -gr BAUX_PATTERN_SOURCED=1
declare -gr BAUX_PATTERN_ABS_DIR="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"

# source dependences
if [[ $BAUX_SOURCED -ne 1 ]]; then
    [[ ! -e $BAUX_PATTERN_ABS_DIR/baux.sh ]] \
        && { echo "Can not source the dependent script baux.sh." >&2; exit 1; }
    source "$BAUX_PATTERN_ABS_DIR/baux.sh"
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

declare -gr BAUX_PATTERN_FLOAT='[[:digit:]]+\.[[:digit:]]+'
declare -gr BAUX_PATTERN_REALNUM='[[:digit:]]+(\.[[:digit:]]+)?'
declare -gr BAUX_PATTERN_IDENT='[_[:alpha:]][_[:alnum:]]*'
declare -gr BAUX_PATTERN_IP='((((25[0-5])|(2[0-4][0-9]))|(1?[0-9]?[0-9]))\.){3}(((25[0-5])|(2[0-4][0-9]))|(1?[0-9]?[0-9]))'
# username in Linux system
declare -gr BAUX_PATTERN_USERNAME='[_a-z][_a-z0-9]{31}'
declare -gr BAUX_PATTERN_PORT='(6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]|[1-5]?([0-9]?){4})'
declare -gr BAUX_PATTERN_HOST='([_[:alnum:]]\.)*[_[:alnum:]]'

isfloat() { ispattern "^${BAUX_PATTERN_FLOAT}$" "$@"; }
isrealnum() { ispattern "^${BAUX_PATTERN_REALNUM}$" "$@"; }
isident() { ispattern "^${BAUX_PATTERN_IDENT}$" "$@"; }
isip() { ispattern "^${BAUX_PATTERN_IP}$" "$@"; }
isname() { ispattern "!${BAUX_PATTERN_USERNAME}$" "$@"; }
isport() { for p in "$@"; do [[ $p -ge 1 || $p -le 65535 ]] || return 1; done; }
ishost() { ispattern "^${BAUX_PATTERN_HOST}$" "$@"; }

tolower() { echo "${@:,,}"; }
toupper() { echo "${@:^^}"; }
ltrim() { echo "${@/#+( )/}"; }
rtrim() { echo "${@/%+( )/}"; }
sub() { local pat="$1" rep="$2"; shift 2; echo "${@/$pat/$rep}"; }
gsub() { local pat="$1" rep="$2"; shift 2; echo "${@//$pat/$rep}"; }

# vim:ft=sh:ts=4:sw=4
