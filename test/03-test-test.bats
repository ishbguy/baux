#! /usr/bin/env bats

SRC_DIR=$PWD

DEBUG=0
source $SRC_DIR/lib/test.sh

@test "test is_defined" {
    test=
    is_defined test
    test=""
    is_defined test
    test="test"
    is_defined test

    test_fun() { true; }
    run is_defined test_fun
    [[ $status -eq 0 ]]

    run is_defined test_fail
    [[ $status -eq 1 ]]

    one= two= three=
    is_defined one two three

    run is_defined one four two three
    [[ $status -eq 1 ]]

    run is_defined TEST
    [[ $status -eq 1 ]]
}

@test "test is_type" {
    declare -a array=()
    is_type array array

    declare -A Array=()
    is_type map Array

    declare -n array_ref=Array
    is_type reference array_ref

    declare -i integer=1
    is_type integer integer

    declare -r ro=0
    is_type readonly ro

    declare -l lower=lower
    is_type lower lower

    declare -u UPPER=UPPER
    is_type upper UPPER

    declare -x EXPORT=export
    is_type export EXPORT

    test_fun() { true; }
    is_type function test_fun

    run is_type function test_fail
    [[ $status -eq 1 ]]
}
