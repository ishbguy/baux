#! /usr/bin/env bats

SRC_DIR=$PWD
source $SRC_DIR/lib/trace.sh

@test "test frame" {
    one() {
        two $1
    }
    two() {
        three $1
    }
    three() {
        frame $1
    }
    run one 0
    [[ $output =~ "two" ]]
    run one 1
    [[ $output =~ "one" ]]
    run one 2
    [[ $output =~ "run" ]]
}

@test "test callstack" {
    one() {
        two $1
    }
    two() {
        three $1
    }
    three() {
        callstack $1
    }
    run one 0
    [[ $output =~ "main" ]]
}
