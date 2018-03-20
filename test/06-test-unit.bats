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

@test "test isnt" {
    run isnt 1 0 "Test not equal"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run isnt 1 1 "Test equal"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run isnt "" "" "Test two spaces"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run isnt "1" "" "Test two spaces"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]
}

@test "test like" {
    run like 0 0 "Test same char like"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run like 1 0 "Test different char"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run like "" "" "Test two spaces"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run like "1" "" "Test space like"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run like "" "1" "Test space like"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]
}

@test "test unlike" {
    run unlike 0 0 "Test same char unlike"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run unlike 1 0 "Test different char"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]

    run unlike "" "" "Test two spaces"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run unlike "1" "" "Test space unlike"
    [[ $status -eq 1 ]]
    [[ $output =~ "FAIL" ]]

    run unlike "" "1" "Test space unlike"
    [[ $status -eq 0 ]]
    [[ $output =~ "OK" ]]
}
