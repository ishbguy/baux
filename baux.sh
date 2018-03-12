#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

#set -x

baux_die_hook() { true; }
baux_die() {
    echo "$@" >&2
    baux_die_hook
    exit 1
}

baux_check_tool() {
    for TOOL in "$@"; do
        which "${TOOL}" >/dev/null 2>&1 \
            || baux_die "You need to install ${TOOL}"
    done
}

baux_ensure() {
    local EXPR="$1"
    local MESSAGE="$2"

    [[ $# -ge 1 ]] || baux_die "${FUNCNAME[0]}() args error."
    
    [[ -n $MESSAGE ]] && MESSAGE=": ${MESSAGE}"
    [ ${EXPR} ] || baux_die "${FUNCNAME[1]}() args error${MESSAGE}."
}

baux_ensure_not_empty() {
    baux_ensure "$# -ge 1" "Need one or more args"

    for arg in "$@"; do
        arg=$(echo "${arg}" | sed -re 's/^\s+//;s/\+$//')
        [[ -n ${arg} ]] || baux_die \
            "${FUNCNAME[1]}() args error: Arguments should not be empty."
    done
}

# echo a message with color
baux_cecho() {
    baux_ensure "2 == $#" "Need a COLOR name and a MESSAGE"
    baux_ensure_not_empty "$@"

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

baux_getoptions()
{
    baux_ensure "$# -ge 3" "Need OPTIONS and ARGUMENTS"
    baux_ensure_not_empty "$1" "$2" "$3"

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

baux_read_config() {
    baux_ensure "2 == $#" "Need LICENSE_CONFIGS array and CONFIG_FILE"
    baux_ensure_not_empty "$@"

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
