#! /usr/bin/env bats

SRC_DIR=${PWD}

source ${SRC_DIR}/baux.sh &>/dev/null

@test "test die" {
    run die TEST
    [ "${status}" -eq 1 ]
    [ "${output}" = "TEST" ]
}

@test "test check_tool" {
    run check_tool bats
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]

    run check_tool XXXX
    [ "${status}" -eq 1 ]
    [ "${output}" = "You need to install XXXX" ]
}

@test "test ensure" {
    run ensure
    [ "${status}" -eq 1 ]
    [ "${output}" = "ensure() args error." ]

    run ensure '1 == 1'
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]

    run bash -c "source ${SRC_DIR}/baux.sh; ensure '1 != 1'"
    [ "${status}" -eq 1 ]
    [ "${output}" = "() args error." ]
}

@test "test ensure_not_empty" {
    run ensure_not_empty
    [ "${status}" -eq 1 ]
    [ "${output}" = "ensure_not_empty() args error: Need one or more args." ]

    run ensure_not_empty ""
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "args error: Arguments should not be empty." ]]

    run ensure_not_empty " "
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "args error: Arguments should not be empty." ]]

    run ensure_not_empty one
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]

    run ensure_not_empty one ""
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "args error: Arguments should not be empty." ]]
}

@test "test cecho" {
    run cecho black test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[30mtest[0m" ]

    run cecho red test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[31mtest[0m" ]

    run cecho green test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[32mtest[0m" ]

    run cecho yellow test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[33mtest[0m" ]

    run cecho blue test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[34mtest[0m" ]

    run cecho magenta test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[35mtest[0m" ]

    run cecho cyan test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[36mtest[0m" ]

    run cecho white test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[37mtest[0m" ]

    run cecho other test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[34mtest[0m" ]
}

@test "test read_config" {
    TMP=$(mktemp)
    echo "user=test" >> ${TMP}
    echo "host=test.com" >> ${TMP}

    run read_config
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "Need license configs array and config file" ]]

    run read_config "" ""
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "should not be empty" ]]

    test_read_config() {
        local -A CONFIGS
        read_config CONFIGS ${TMP}
        echo ${CONFIGS[@]}
    }

    run test_read_config

    [ "${status}" -eq 0 ]
    [ "${output}" = "test.com test" ]

    rm ${TMP}
}

@test "test getoptions" {
    declare -A OPTS ARGS

    run getoptions OPTS ARGS
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "Need OPTIONS and ARGUMENTS" ]]

    run getoptions OPTS ARGS ""
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "should not be empty" ]]

    run bash -c "source ${SRC_DIR}/baux.sh; \
        declare -A OPTS ARGS;\
        getoptions OPTS ARGS 'a' -a a; \
        echo \${ARGS[a]}; \
        [[ \${OPTS[a]} -eq 1 ]]"
    [ "${status}" -eq 0 ]
    [ "${output}" == "" ]

    run bash -c "source ${SRC_DIR}/baux.sh; \
        declare -A OPTS ARGS;\
        getoptions OPTS ARGS 'a:' -a a; \
        echo \${ARGS[a]}; \
        [[ \${OPTS[a]} -eq 1 ]]"
    [ "${status}" -eq 0 ]
    [ "${output}" == "a" ]

    run bash -c "source ${SRC_DIR}/baux.sh; \
        declare -A OPTS ARGS;\
        getoptions OPTS ARGS 'a:' -a a -b; \
        echo \${ARGS[a]}; \
        [[ \${OPTS[a]} -eq 1 ]]"
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "illegal option" ]]
}
