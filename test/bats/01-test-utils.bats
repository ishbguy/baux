#!/usr/bin/env bats

SRC_DIR=$BATS_TEST_DIRNAME/../..
source $SRC_DIR/lib/utils.sh
load bats-aux

@test "test random" {
    run random
    [[ $output =~ "" ]]

    run random test
    [[ $output =~ "test" ]]

    run random {1..100}
    [[ $output != "1 2 3 4 5 6 7 8 9 10" ]]
}

@test "test cecho" {
    # color:code
    local -a colors=(
            'black:30'
            'red:31'
            'green:32'
            'yellow:33'
            'blue:34'
            'magenta:35'
            'cyan:36'
            'white:37'
            'else:34'
            )
    for c in "${colors[@]}"; do
        run cecho "${c%%:*}" test
        [[ $output == "[${c##*:}mtest[0m" ]] || run_error "run cecho '${c}' test failed."
    done
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

    run bash -c "source $SRC_DIR/lib/utils.sh; \
        declare -A opts args;\
        getoptions opts args 'a' -a a; \
        echo \${args[a]}; \
        [[ \${opts[a]} -eq 1 ]]"
        echo $output
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run bash -c "source $SRC_DIR/lib/utils.sh; \
        declare -A opts args;\
        getoptions opts args 'a:' -a a; \
        echo \${args[a]}; \
        [[ \${opts[a]} -eq 1 ]]"
    [[ $status -eq 0 ]]
    [[ $output == "a" ]]

    run bash -c "source $SRC_DIR/lib/utils.sh; \
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
    echo "host=best.com" >> $tmp

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
    [[ $output =~ "test" ]]
    [[ $output =~ "best.com" ]]
}

@test "test realdir" {
    run realdir
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    run realdir /etc/hosts /etc/passwd
    [[ $status -eq 0 ]]
    [[ $output == "/etc /etc" ]]

}
