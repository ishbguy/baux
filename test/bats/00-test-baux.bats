#!/usr/bin/env bats

SRC_DIR=$BATS_TEST_DIRNAME/../..
source $SRC_DIR/lib/baux.sh

@test "test die" {
    run die TEST
    [[ $status -eq 1 ]]
    [[ $output == "TEST" ]]
}

@test "test warn" {
    run warn test
    [[ $status -eq 1 ]]
    [[ $output == "test" ]]

    run bash -c "source $SRC_DIR/lib/baux.sh; \
        warn test"
    [[ $status -eq 1 ]]
    [[ $output == "test" ]]

    run bash -c "source $SRC_DIR/lib/baux.sh; \
        warn test; warn test"
    [[ $status -eq 2 ]]
    [[ $output =~ "test" ]]
}

@test "test proname" {
    run proname
    [[ $status -eq 0 ]]
    [[ $output =~ "bats-exec-test" ]]
}

@test "test version" {
    run version
    [[ $status -eq 1 ]]
    [[ $output =~ "You need to define a VERSION variable." ]]

    VERSION=0.0.1
    run version
    [[ $status -eq 0 ]]
    [[ $output =~ "bats-exec-test 0.0.1" ]]
}

@test "test usage" {
    run usage
    [[ $status -eq 2 ]]
    [[ $output =~ "You need to define a VERSION variable." ]]
    [[ $output =~ "You need to define a HELP variable." ]]

    HELP="usage help"
    VERSION=0.0.1
    run usage
    echo $output
    [[ $status -eq 0 ]]
    [[ $output =~ "bats-exec-test 0.0.1" ]]
    [[ $output =~ "usage help" ]]
}

@test "test import" {
    tmp=$(mktemp)
    teardown() { rm $tmp; }

    if [[ $BAUX_ENSURE_DEBUG == "1" ]]; then
        run import
        [[ $status -eq 1 ]]
        [[ $output =~ "Need to specify an import file." ]]

        run import ""
        [[ $status -eq 1 ]]
        [[ $output =~ "should not be empty" ]]
    fi

    run import xxxx
    [[ $status -eq 1 ]]
    [[ $output =~ "does not exist" ]]

    echo "test-import() { echo test-import; }" >$tmp
    run bash -c "source $SRC_DIR/lib/baux.sh; \
        import $tmp; \
        test-import"
    [[ $status -eq 0 ]]
    [[ $output =~ "test-import" ]]

    echo "test-import() { echo test-import; }" >$tmp
    run bash -c "source $SRC_DIR/lib/baux.sh; \
        import $tmp $tmp; \
        test-import"
    [[ $status -eq 0 ]]
    [[ $output =~ "test-import" ]]
}
