#! /usr/bin/env bats

SRC_DIR=$PWD

DEBUG=1
source $SRC_DIR/baux.sh &>/dev/null

@test "test die" {
    run die TEST
    [[ $status -eq 1 ]]
    [[ $output == "TEST" ]]
}

@test "test warn" {
    run warn test
    [[ $status -eq 0 ]]
    [[ $output == "test" ]]

    run bash -c "source $SRC_DIR/baux.sh; \
        warn test; \
        exit \$BAUX_EXIT_CODE"
    [[ $status -eq 1 ]]
    [[ $output == "test" ]]
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

    run ensure_not_empty one
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run ensure_not_empty one ""
    [[ $status -eq 1 ]]
    [[ $output =~ "Arguments should not be empty." ]]
}

@test "test import" {
    tmp=$(mktemp)
    teardown() { rm $tmp; }

    if [[ $DEBUG == "1" ]]; then
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
    run bash -c "source $SRC_DIR/baux.sh; \
        import $tmp; \
        test-import"
    [[ $status -eq 0 ]]
    [[ $output =~ "test-import" ]]

    echo "test-import() { echo test-import; }" >$tmp
    run bash -c "source $SRC_DIR/baux.sh; \
        import $tmp $tmp; \
        test-import"
    [[ $status -eq 0 ]]
    [[ $output =~ "test-import" ]]
}
