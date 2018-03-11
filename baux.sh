#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

#set -x

function die_hook() { true; }
function die()
{
    echo "$@" >&2
    die_hook
    exit 1
}

function check_tool()
{
    for TOOL in "$@"; do
        which "${TOOL}" >/dev/null 2>&1 \
            || die "You need to install ${TOOL}"
    done
}

function ensure()
{
    local EXPR="$1"
    local MESSAGE="$2"

    [[ $# -lt 1 ]] && die "${FUNCNAME[0]}() args error."
    
    [[ -n $MESSAGE ]] && MESSAGE=": ${MESSAGE}"
    [ ${EXPR} ] || die "${FUNCNAME[1]}() args error${MESSAGE}."
}

# echo a message with color
function cecho()
{
    ensure "2 == $#" "Need a COLOR name and a MESSAGE"

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

function read_config()
{
    ensure "2 == $#" "Need LICENSE_CONFIGS array and CONFIG_FILE"

    # make a ref of config array
    local -n __CONFIGS="$1"
    local CONFIG_FILE="$2"
    local OLD_IFS="${IFS}"
    local TMP_FILE

    [[ -e ${CONFIG_FILE} ]] || return 1

    # remove blank lines, comments, heading and tailing spaces
    TMP_FILE=$(mktemp)
    sed -re '/^\s*$/d;/^#.*/d;s/#.*//g;s/^\s+//;s/\s+$//' \
        "${CONFIG_FILE}" >"${TMP_FILE}"

    # read name-value pairs from config file
    while IFS="=" read -r NAME VALUE; do
        NAME="${NAME#\"}"; NAME="${NAME%\"}"
        VALUE="${VALUE#\"}"; VALUE="${VALUE%\"}"
        __CONFIGS["${NAME,,}"]="${VALUE}"
    done <"${TMP_FILE}"

    rm -rf "${TMP_FILE}"
    IFS="${OLD_IFS}"
}

# vim:ft=sh:ts=4:sw=4
