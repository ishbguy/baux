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

check_tool() {
    for tool in "$@"; do
        which "$tool" >/dev/null 2>&1 \
            || die "You need to install $tool"
    done
}

ensure() {
    local expression="$1"
    local message="$2"

    [[ $# -ge 1 ]] || die "${FUNCNAME[0]}() args error."
    
    [[ -n $message ]] && message=": $message"
    eval "[[ $expression ]]" || die "${FUNCNAME[1]}() args error$message."
}

ensure_not_empty() {
    ensure "$# -ge 1" "Need one or more args"

    for arg in "$@"; do
        arg="${arg## *}"
        arg="${arg%% *}"
        [[ -n $arg ]] || die \
            "${FUNCNAME[1]}() args error: Arguments should not be empty."
    done
}

# echo a message with color
cecho() {
    ensure "2 == $#" "Need a color name and a message"
    ensure_not_empty "$@"

    local color_name="$1"
    local message="$2"
    local color=

    case "$color_name" in
        bla|black)  color="\\x1B[30m" ;;
        re|red)     color="\\x1B[31m" ;;
        gr|green)   color="\\x1B[32m" ;;
        ye|yellow)  color="\\x1B[33m" ;;
        blu|blue)   color="\\x1B[34m" ;;
        ma|magenta) color="\\x1B[35m" ;;
        cy|cyan)    color="\\x1B[36m" ;;
        wh|white)   color="\\x1B[37m" ;;
        *)          color="\\x1B[34m" ;;
    esac
    echo -ne "$color$message\\x1B[0m"
}

# random given args
random() {
    local -i count="${#@}"
    local -a in=("$@")
    local -a out
    local -A hits

    [[ $count -gt 1 ]] || echo "$@"
    for ((i = 0; i < count; i++)); do
        local idx
        while true; do
            idx=$((RANDOM % count))
            [[ -z ${hits[${in[$idx]}]} ]] && break
        done
        hits[${in[$idx]}]="${in[$idx]}"
        out+=("${in[$idx]}")
    done
    echo "${out[@]}"
}

getoptions()
{
    ensure "$# -ge 3" "Need OPTIONS and ARGUMENTS"
    ensure_not_empty "$1" "$2" "$3"

    local -n __options="$1"
    local -n __arguments="$2"
    local arg_string="$3"
    shift 3

    OPTIND=1
    while getopts "$arg_string" opt; do
        [[ $opt == ":" || $opt == "?" ]] && die "$(usage)"
        __options[$opt]=1
        __arguments[$opt]="$OPTARG"
    done
    shift $((OPTIND - 1))
}

read_config() {
    ensure "2 == $#" "Need license configs array and config file"
    ensure_not_empty "$@"

    # make a ref of config array
    local -n __configs="$1"
    local config_file="$2"
    local old_ifs="$IFS"
    local tmp_file

    [[ -e $config_file ]] || return $BAUX_FAIL

    tmp_file=$(mktemp)
    # use trap to rm temp file and recover old IFS
    trap 'rm -f $tmp_file; IFS=$old_ifs' RETURN

    # remove blank lines, comments, heading and tailing spaces
    sed -re '/^\s*$/d;/^#.*/d;s/#.*//g;s/^\s+//;s/\s+$//' \
        "$config_file" >"$tmp_file"

    # read name-value pairs from config file
    while IFS="=" read -r name value; do
        name="${name#\"}"; name="${name%\"}"
        value="${value#\"}"; value="${value%\"}"
        __configs["${name,,}"]="$value"
    done <"$tmp_file"
}

# vim:ft=sh:ts=4:sw=4
