#! /usr/bin/env bats

SRC_DIR=$PWD

source $SRC_DIR/lib/utili.sh

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

    if [[ $BAUX_ENSURE_DEBUG == 1 ]]; then
        run getoptions opts args
        [[ $status -eq 1 ]]
        [[ $output =~ "Need OPTIONS and ARGUMENTS" ]]

        run getoptions opts args ""
        [[ $status -eq 1 ]]
        [[ $output =~ "should not be empty" ]]
    fi

    run bash -c "source $SRC_DIR/lib/utili.sh; \
        declare -A opts args;\
        getoptions opts args 'a' -a a; \
        echo \${args[a]}; \
        [[ \${opts[a]} -eq 1 ]]"
        echo $output
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run bash -c "source $SRC_DIR/lib/utili.sh; \
        declare -A opts args;\
        getoptions opts args 'a:' -a a; \
        echo \${args[a]}; \
        [[ \${opts[a]} -eq 1 ]]"
    [[ $status -eq 0 ]]
    [[ $output == "a" ]]

    run bash -c "source $SRC_DIR/lib/utili.sh; \
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

    if [[ $BAUX_ENSURE_DEBUG == "1" ]]; then
        run read_config
        [[ $status -eq 1 ]]
        [[ $output =~ "Need license configs array and config file" ]]

        run read_config "" ""
        [[ $status -eq 1 ]]
        [[ $output =~ "should not be empty" ]]
    fi

    test_read_config() {
        local -A configs
        read_config configs $tmp
        echo ${configs[@]}
    }

    run test_read_config

    [[ $status -eq 0 ]]
    [[ $output == "test.com test" ]]
}
