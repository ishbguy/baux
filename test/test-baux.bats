#! /usr/bin/env bats

SRC_DIR=${PWD}

@test "test baux_die" {
    run bash -c "source ${SRC_DIR}/baux.sh; baux_die TEST"
    [ "${status}" -eq 1 ]
    [ "${output}" = "TEST" ]
}

@test "test baux_check_tool" {
    run bash -c "source ${SRC_DIR}/baux.sh; baux_check_tool bats"
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_check_tool XXXX"
    [ "${status}" -eq 1 ]
    [ "${output}" = "You need to install XXXX" ]
}

@test "test baux_ensure" {
    run bash -c "source ${SRC_DIR}/baux.sh; baux_ensure"
    [ "${status}" -eq 1 ]
    [ "${output}" = "baux_ensure() args error." ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_ensure '1 == 1'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_ensure '1 != 1'"
    [ "${status}" -eq 1 ]
    [ "${output}" = "() args error." ]
}

@test "test baux_ensure_not_empty" {
    run bash -c "source ${SRC_DIR}/baux.sh; baux_ensure_not_empty"
    [ "${status}" -eq 1 ]
    [ "${output}" = "baux_ensure_not_empty() args error: Need one or more args." ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_ensure_not_empty \"\""
    [ "${status}" -eq 1 ]
    [ "${output}" = "() args error: Arguments should not be empty." ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_ensure_not_empty one"
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_ensure_not_empty one \"\""
    [ "${status}" -eq 1 ]
    [ "${output}" = "() args error: Arguments should not be empty." ]
}

@test "test baux_cecho" {
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho black 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[30mtest[0m" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho red 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[31mtest[0m" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho green 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[32mtest[0m" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho yellow 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[33mtest[0m" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho blue 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[34mtest[0m" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho magenta 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[35mtest[0m" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho cyan 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[36mtest[0m" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho white 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[37mtest[0m" ]
    run bash -c "source ${SRC_DIR}/baux.sh; baux_cecho other 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[34mtest[0m" ]
}

@test "test baux_read_config" {
    TMP=$(mktemp)
    echo "user=test" >> ${TMP}
    echo "host=test.com" >> ${TMP}

    run bash -c "source ${SRC_DIR}/baux.sh; declare -A CONFIGS; \
        baux_read_config CONFIGS ${TMP}; \
        echo \"\${CONFIGS[@]}\""
    echo $output
    [ "${status}" -eq 0 ]
    [ "${output}" = "test.com test" ]

    rm ${TMP}
}
