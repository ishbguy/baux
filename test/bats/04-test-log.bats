#! /usr/bin/env bats

SRC_DIR=$BATS_TEST_DIRNAME/../..
source $SRC_DIR/lib/log.sh
load bats-aux

@test "test log" {
    teardown() { rm -f bats.log; }
    local -a levels=(
            debug
            info
            warn
            error
            fatal
            panic
            )
    for l in "${levels[@]}"; do
        run log "$l" test
        [[ $output =~ test ]] || run_error "run log $l test failed."
    done
    BAUX_LOG_OUTPUT_FILE=bats.log
    for l in "${levels[@]}"; do
        run log "$l" test
        [[ $(cat bats.log) =~ test ]] || run_error "run log $l test failed."
    done
    BAUX_LOG_OUTPUT_FILE=
    BAUX_LOG_OUTPUT_LEVEL=quiet
    for l in "${levels[@]}"; do
        run log "$l" test
        [[ $output == '' ]] || run_error "run log $l test failed."
    done
}
