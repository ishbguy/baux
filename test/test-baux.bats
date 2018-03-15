#! /usr/bin/env bats

SRC_DIR=$PWD

source $SRC_DIR/baux.sh &>/dev/null
import $SRC_DIR/utili.sh
import $SRC_DIR/ensure.sh

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

    run import
    [[ $status -eq 1 ]]
    [[ $output =~ "Need to specify an import file." ]]

    run import ""
    [[ $status -eq 1 ]]
    [[ $output =~ "should not be empty" ]]

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

@test "test random" {
    run random
    [[ $status -eq 0 ]]
    [[ $output =~ "" ]]

    run random test
    [[ $status -eq 0 ]]
    [[ $output =~ "test" ]]

    run random {1..100}
    [[ $status -eq 0 ]]
    [[ $output != "1 2 3 4 5 6 7 8 9 10" ]]
}

@test "test cecho" {
    run cecho black test
    [[ $status -eq 0 ]]
    [[ $output == "[30mtest[0m" ]]

    run cecho red test
    [[ $status -eq 0 ]]
    [[  $output == "[31mtest[0m" ]]

    run cecho green test
    [[ $status -eq 0 ]]
    [[ $output == "[32mtest[0m" ]]

    run cecho yellow test
    [[ $status -eq 0 ]]
    [[ $output == "[33mtest[0m" ]]

    run cecho blue test
    [[ $status -eq 0 ]]
    [[ $output == "[34mtest[0m" ]]

    run cecho magenta test
    [[ $status -eq 0 ]]
    [[ $output == "[35mtest[0m" ]]

    run cecho cyan test
    [[ $status -eq 0 ]]
    [[ $output == "[36mtest[0m" ]]

    run cecho white test
    [[ $status -eq 0 ]]
    [[ $output == "[37mtest[0m" ]]

    run cecho other test
    [[ $status -eq 0 ]]
    [[ $output == "[34mtest[0m" ]]
}

@test "test getoptions" {
    declare -A opts args

    run getoptions opts args
    [[ $status -eq 1 ]]
    [[ $output =~ "Need OPTIONS and ARGUMENTS" ]]

    run getoptions opts args ""
    [[ $status -eq 1 ]]
    [[ $output =~ "should not be empty" ]]

    run bash -c "source $SRC_DIR/utili.sh; \
        declare -A opts args;\
        getoptions opts args 'a' -a a; \
        echo \${args[a]}; \
        [[ \${opts[a]} -eq 1 ]]"
        echo $output
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run bash -c "source $SRC_DIR/utili.sh; \
        declare -A opts args;\
        getoptions opts args 'a:' -a a; \
        echo \${args[a]}; \
        [[ \${opts[a]} -eq 1 ]]"
    [[ $status -eq 0 ]]
    [[ $output == "a" ]]

    run bash -c "source $SRC_DIR/utili.sh; \
        declare -A opts args;\
        getoptions opts args 'a:' -a a -b; \
        echo \${args[a]}; \
        [[ \${opts[a]} -eq 1 ]]"
    [[  $status -eq 1 ]]
    [[ $output =~ "illegal option" ]]
}

@test "test check_tool" {
    run check_tool bats
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run check_tool XXXX
    [[ $status -eq 1 ]]
    [[ $output == "You need to install XXXX" ]]
}

@test "test read_config" {
    tmp=$(mktemp)
    teardown() { rm -rf $tmp; }
    echo "user=test" >> $tmp
    echo "host=test.com" >> $tmp

    run read_config
    [[ $status -eq 1 ]]
    [[ $output =~ "Need license configs array and config file" ]]

    run read_config "" ""
    [[ $status -eq 1 ]]
    [[ $output =~ "should not be empty" ]]

    test_read_config() {
        local -A configs
        read_config configs $tmp
        echo ${configs[@]}
    }

    run test_read_config

    [[ $status -eq 0 ]]
    [[ $output == "test.com test" ]]
}

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
