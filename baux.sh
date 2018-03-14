#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# only allow sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] && exit 1

#set -x

die_hook() { true; }
die() {
    echo "$@" >&2
    die_hook
    exit 1
}

check_tool() {
    for TOOL in "$@"; do
        which "${TOOL}" >/dev/null 2>&1 \
            || die "You need to install ${TOOL}"
    done
}

ensure() {
    local EXPR="$1"
    local MESSAGE="$2"

    [[ $# -ge 1 ]] || die "${FUNCNAME[0]}() args error."
    
    [[ -n $MESSAGE ]] && MESSAGE=": ${MESSAGE}"
    [ ${EXPR} ] || die "${FUNCNAME[1]}() args error${MESSAGE}."
}

ensure_not_empty() {
    ensure "$# -ge 1" "Need one or more args"

    for arg in "$@"; do
        arg=$(echo "${arg}" | sed -re 's/^\s+//;s/\+$//')
        [[ -n ${arg} ]] || die \
            "${FUNCNAME[1]}() args error: Arguments should not be empty."
    done
}

# echo a message with color
cecho() {
    ensure "2 == $#" "Need a COLOR name and a MESSAGE"
    ensure_not_empty "$@"

    local COLOR_NAME="$1"
    local MESSAGE="$2"
    local COLOR=

    case "${COLOR_NAME}" in
        bla|black)  COLOR="\\x1B[30m" ;;
        re|red)     COLOR="\\x1B[31m" ;;
        gr|green)   COLOR="\\x1B[32m" ;;
        ye|yellow)  COLOR="\\x1B[33m" ;;
        blu|blue)   COLOR="\\x1B[34m" ;;
        ma|magenta) COLOR="\\x1B[35m" ;;
        cy|cyan)    COLOR="\\x1B[36m" ;;
        wh|white)   COLOR="\\x1B[37m" ;;
        *)          COLOR="\\x1B[34m" ;;
    esac
    echo -ne "${COLOR}${MESSAGE}[0m"
}

getoptions()
{
    ensure "$# -ge 3" "Need OPTIONS and ARGUMENTS"
    ensure_not_empty "$1" "$2" "$3"

    local -n __options="$1"
    local -n __arguments="$2"
    local argstring="$3"
    shift 3

    OPTIND=1
    while getopts "${argstring}" OPT; do
        [[ ${OPT} == ":" || ${OPT} == "?" ]] && die "${HELP}"
        __options[${OPT}]=1
        __arguments[${OPT}]="${OPTARG}"
    done
    shift $((OPTIND - 1))
}

read_config() {
    ensure "2 == $#" "Need LICENSE_CONFIGS array and CONFIG_FILE"
    ensure_not_empty "$@"

    # make a ref of config array
    local -n __CONFIGS="$1"
    local CONFIG_FILE="$2"
    local OLD_IFS="${IFS}"
    local TMP_FILE

    [[ -e ${CONFIG_FILE} ]] || return 1

    TMP_FILE=$(mktemp)
    # use trap to rm temp file and recover old IFS
    trap "rm -f ${TMP_FILE}; IFS=${OLD_IFS}" RETURN

    # remove blank lines, comments, heading and tailing spaces
    sed -re '/^\s*$/d;/^#.*/d;s/#.*//g;s/^\s+//;s/\s+$//' \
        "${CONFIG_FILE}" >"${TMP_FILE}"

    # read name-value pairs from config file
    while IFS="=" read -r NAME VALUE; do
        NAME="${NAME#\"}"; NAME="${NAME%\"}"
        VALUE="${VALUE#\"}"; VALUE="${VALUE%\"}"
        __CONFIGS["${NAME,,}"]="${VALUE}"
    done <"${TMP_FILE}"
}

# vim:ft=sh:ts=4:sw=4
