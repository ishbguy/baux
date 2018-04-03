#! /usr/bin/env bats

SRC_DIR=$PWD

DEBUG=0
source $SRC_DIR/lib/check.sh

@test "test defined" {
    test=
    defined test
    test=""
    defined test
    test="test"
    defined test

    test_fun() { true; }
    run defined test_fun
    [[ $status -eq 0 ]]

    run defined test_fail
    [[ $status -eq 1 ]]

    one= two= three=
    defined one two three

    run defined one four two three
    [[ $status -eq 1 ]]

    run defined TEST
    [[ $status -eq 1 ]]
}

@test "test istype" {
    declare -a array=()
    istype array array
    run istype map array
    [[ $status -eq 1 ]]

    declare -A Array=()
    istype map Array

    declare -n array_ref=Array
    istype reference array_ref

    declare -i integer=1
    istype integer integer

    declare -r ro=0
    istype readonly ro

    declare -l lower=lower
    istype lower lower

    declare -u UPPER=UPPER
    istype upper UPPER

    declare -x EXPORT=export
    istype export EXPORT

    test_fun() { true; }
    istype function test_fun

    run istype function test_fail
    [[ $status -eq 1 ]]
}
