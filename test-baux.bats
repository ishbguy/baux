#! /usr/bin/env bats

@test "test die" {
    run bash -c "source ${PWD}/baux.sh; die TEST"
    [ "${status}" -eq 1 ]
    [ "${output}" = "TEST" ]
}

@test "test check tool" {
    run bash -c "source ${PWD}/baux.sh; check_tool bats"
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]
    run bash -c "source ${PWD}/baux.sh; check_tool XXXX"
    [ "${status}" -eq 1 ]
    [ "${output}" = "You need to install XXXX" ]
}

@test "test ensure" {
    run bash -c "source ${PWD}/baux.sh; ensure"
    [ "${status}" -eq 1 ]
    [ "${output}" = "ensure() args error." ]
    run bash -c "source ${PWD}/baux.sh; ensure '1 == 1'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "" ]
    run bash -c "source ${PWD}/baux.sh; ensure '1 != 1'"
    [ "${status}" -eq 1 ]
    [ "${output}" = "() args error." ]
}

@test "test cecho" {
    run bash -c "source ${PWD}/baux.sh; cecho black 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[30mtest[0m" ]
    run bash -c "source ${PWD}/baux.sh; cecho red 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[31mtest[0m" ]
    run bash -c "source ${PWD}/baux.sh; cecho green 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[32mtest[0m" ]
    run bash -c "source ${PWD}/baux.sh; cecho yellow 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[33mtest[0m" ]
    run bash -c "source ${PWD}/baux.sh; cecho blue 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[34mtest[0m" ]
    run bash -c "source ${PWD}/baux.sh; cecho magenta 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[35mtest[0m" ]
    run bash -c "source ${PWD}/baux.sh; cecho cyan 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[36mtest[0m" ]
    run bash -c "source ${PWD}/baux.sh; cecho white 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[37mtest[0m" ]
    run bash -c "source ${PWD}/baux.sh; cecho other 'test'"
    [ "${status}" -eq 0 ]
    [ "${output}" = "[34mtest[0m" ]
}

@test "test read_config" {
    TMP=$(mktemp)
    echo "user=test" >> ${TMP}
    echo "host=test.com" >> ${TMP}

    run bash -c "source ${PWD}/baux.sh; declare -A CONFIGS; \
    read_config CONFIGS ${TMP}; \
    echo \"\${CONFIGS[@]}\""
    echo $output
    [ "${status}" -eq 0 ]
    [ "${output}" = "test.com test" ]

    rm ${TMP}
}
