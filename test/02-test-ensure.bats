#! /usr/bin/env bats

SRC_DIR=$PWD

DEBUG=1
source $SRC_DIR/ensure.sh

@test "test ensure_equal" {
    run ensure_equal 1 1
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_equal 1 0
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]
}

@test "test ensure_not_equal" {
    run ensure_not_equal 1 0
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_not_equal 1 1
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]
}

@test "test ensure_match" {
    run ensure_match "" ""
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_match "test" "test"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_match "test" ""
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]
}

@test "test ensure_mismatch" {
    run ensure_mismatch "test" ""
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_mismatch "test" "t"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_mismatch "test" "test"
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]

    run ensure_mismatch "" ""
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]
}

@test "test ensure_like" {
    run ensure_like "" ""
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_like "test" ""
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_like "test" "te"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_like "test" "test"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_like "test" "tst"
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]

    run ensure_like "test" "test-test"
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]
}

@test "test ensure_unlike" {
    run ensure_unlike "test" "tst"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_unlike "test" "test-test"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_unlike "test" "test"
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]

    run ensure_unlike "test" ""
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]

    run ensure_unlike "" ""
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]
}
