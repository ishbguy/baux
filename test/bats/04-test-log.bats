#! /usr/bin/env bats

SRC_DIR=$PWD
source $SRC_DIR/lib/log.sh

@test "test log" {
    run log debug "test"
    [[ $status -eq 0 ]]
    [[ $output =~ test ]]

    BAUX_LOG_OUTPUT_LEVEL=info
    run log debug "test"
    echo $output
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    teardown() { rm -f bats.log; }
    BAUX_LOG_OUTPUT_FILE=bats.log
    BAUX_LOG_OUTPUT_LEVEL=debug
    run log debug "test"
    echo $output
    [[ $status -eq 0 ]]
    [[ $(cat bats.log) =~ "test" ]]
}
