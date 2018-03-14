#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

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
declare -g  BAUX_EXIT_CODE=0

# vim:set ft=sh ts=4 sw=4:
