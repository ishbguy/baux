#! /usr/bin/env bats

SRC_DIR=$PWD
source $SRC_DIR/unit.sh

@test "test ok" {
    run ok "1 == 1" "Test equal"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run ok " 1 != 1" "Test not equal"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run ok " != 1" "Test bad expr (left)"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run ok " 1 != " "Test bad expr (right)"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run ok " != " "Test expr without two args"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]
}

@test "test is" {
    run is 1 1 "Test equal"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run is 1 0 "Test not equal"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run is "" "" "Test two spaces"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run is "1" "" "Test two spaces"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]
}

@test "test is" {
    run is 1 1 "Test equal"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run is 1 0 "Test not equal"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run is "" "" "Test two spaces"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run is "1" "" "Test two spaces"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]
}
