#! /usr/bin/env bats

SRC_DIR=$PWD

source $SRC_DIR/lib/ensure.sh

@test "test ensure" {
    run ensure
    [[ $status -eq 1 ]]
    [[ $output == "ensure() args error." ]]

    run ensure '1 == 1'
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure "1 != 1"
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]

    run ensure " != 1"
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]
}

@test "test ensure_not_empty" {
    run ensure_not_empty
    [[ $status -eq 1 ]]
    [[ $output =~ "Need one or more args." ]]

    run ensure_not_empty ""
    [[ $status -eq 1 ]]
    [[ $output =~ "Arguments should not be empty." ]]

    run ensure_not_empty " "
    [[ $status -eq 1 ]]
    [[ $output =~ "Arguments should not be empty." ]]

    run ensure_not_empty " one"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_not_empty "one "
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_not_empty one
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_not_empty one ""
    [[ $status -eq 1 ]]
    [[ $output =~ "Arguments should not be empty." ]]
}

@test "test ensure_is" {
    run ensure_is "" ""
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_is "test" "test"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_is "test" ""
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]
}

@test "test ensure_isnt" {
    run ensure_isnt "test" ""
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_isnt "test" "t"
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_isnt "test" "test"
    [[ $status -eq 1 ]]
    [[ $output =~ "failed" ]]

    run ensure_isnt "" ""
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
