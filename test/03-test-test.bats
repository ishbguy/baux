#! /usr/bin/env bats

SRC_DIR=$PWD

source $SRC_DIR/test.sh

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
    is_type a array

    declare -A Array=()
    is_type A Array

    declare -n array_ref=Array
    is_type n array_ref

    declare -i integer=1
    is_type i integer

    declare -r ro=0
    is_type r ro

    declare -l lower=lower
    is_type l lower

    declare -u UPPER=UPPER
    is_type u UPPER

    declare -x EXPORT=export
    is_type x EXPORT

    test_fun() { true; }
    is_type f test_fun

    run is_type f test_fail
    [[ $status -eq 1 ]]
}
