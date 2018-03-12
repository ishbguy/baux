#! /usr/bin/env bats

SRC_DIR=${PWD}

source ${SRC_DIR}/baux.sh &>/dev/null

@test "test baux_die" {
    run baux_die TEST
    [ "${status}" -eq 1 ]
    [ "${output}" = "TEST" ]
}

@test "test baux_check_tool" {
    run baux_check_tool bats
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]

    run baux_check_tool XXXX
    [ "${status}" -eq 1 ]
    [ "${output}" = "You need to install XXXX" ]
}

@test "test baux_ensure" {
    run baux_ensure
    [ "${status}" -eq 1 ]
    [ "${output}" = "baux_ensure() args error." ]

    run baux_ensure '1 == 1'
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]

    run bash -c "source ${SRC_DIR}/baux.sh; baux_ensure '1 != 1'"
    [ "${status}" -eq 1 ]
    [ "${output}" = "() args error." ]
}

@test "test baux_ensure_not_empty" {
    run baux_ensure_not_empty
    [ "${status}" -eq 1 ]
    [ "${output}" = "baux_ensure_not_empty() args error: Need one or more args." ]

    run baux_ensure_not_empty ""
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "args error: Arguments should not be empty." ]]

    run baux_ensure_not_empty one
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]

    run baux_ensure_not_empty one ""
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "args error: Arguments should not be empty." ]]
}

@test "test baux_cecho" {
    run baux_cecho black test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[30mtest[0m" ]

    run baux_cecho red test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[31mtest[0m" ]

    run baux_cecho green test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[32mtest[0m" ]

    run baux_cecho yellow test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[33mtest[0m" ]

    run baux_cecho blue test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[34mtest[0m" ]

    run baux_cecho magenta test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[35mtest[0m" ]

    run baux_cecho cyan test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[36mtest[0m" ]

    run baux_cecho white test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[37mtest[0m" ]

    run baux_cecho other test
    [ "${status}" -eq 0 ]
    [ "${output}" = "[34mtest[0m" ]
}

@test "test baux_read_config" {
    TMP=$(mktemp)
    echo "user=test" >> ${TMP}
    echo "host=test.com" >> ${TMP}

    run baux_read_config
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "Need LICENSE_CONFIGS array and CONFIG_FILE" ]]

    run baux_read_config "" ""
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "should not be empty" ]]

    test_read_config() {
        local -A CONFIGS
        baux_read_config CONFIGS ${TMP}
        echo ${CONFIGS[@]}
    }

    run test_read_config

    [ "${status}" -eq 0 ]
    [ "${output}" = "test.com test" ]

    rm ${TMP}
}

@test "test baux_getoptions" {
    declare -A OPTS ARGS

    run baux_getoptions OPTS ARGS
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "Need OPTIONS and ARGUMENTS" ]]

    run baux_getoptions OPTS ARGS ""
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "should not be empty" ]]

    run bash -c "source ${SRC_DIR}/baux.sh; \
        declare -A OPTS ARGS;\
        baux_getoptions OPTS ARGS 'a' -a a; \
        echo \${ARGS[a]}; \
        [[ \${OPTS[a]} -eq 1 ]]"
    [ "${status}" -eq 0 ]
    [ "${output}" == "" ]

    run bash -c "source ${SRC_DIR}/baux.sh; \
        declare -A OPTS ARGS;\
        baux_getoptions OPTS ARGS 'a:' -a a; \
        echo \${ARGS[a]}; \
        [[ \${OPTS[a]} -eq 1 ]]"
    [ "${status}" -eq 0 ]
    [ "${output}" == "a" ]

    run bash -c "source ${SRC_DIR}/baux.sh; \
        declare -A OPTS ARGS;\
        baux_getoptions OPTS ARGS 'a:' -a a -b; \
        echo \${ARGS[a]}; \
        [[ \${OPTS[a]} -eq 1 ]]"
        echo $output
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "illegal option" ]]
}
