#! /usr/bin/env bats

SRC_DIR=$PWD
source $SRC_DIR/lib/test.sh

@test "test ok" {
    run ok "1 == 1" "Test equal"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run ok " 1 != 1" "Test not equal"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run ok " != 1" "Test bad expr (left)"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run ok " 1 != " "Test bad expr (right)"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run ok " != " "Test expr without two args"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]
}

@test "test is" {
    run is 1 1 "Test equal"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run is 1 0 "Test not equal"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run is "" "" "Test two spaces"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run is "1" "" "Test two spaces"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]
}

@test "test isnt" {
    run isnt 1 0 "Test not equal"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run isnt 1 1 "Test equal"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run isnt "" "" "Test two spaces"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run isnt "1" "" "Test two spaces"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]
}

@test "test like" {
    run like 0 0 "Test same char like"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run like 1 0 "Test different char"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run like "" "" "Test two spaces"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run like "1" "" "Test space like"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run like "" "1" "Test space like"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]
}

@test "test unlike" {
    run unlike 0 0 "Test same char unlike"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run unlike 1 0 "Test different char"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run unlike "" "" "Test two spaces"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run unlike "1" "" "Test space unlike"
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    run unlike "" "1" "Test space unlike"
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]
}

@test "test run_ok" {
    run run_ok '$status -eq 0' exit 0
    [[ $status -eq 0 ]]

    run run_ok '$status -eq 1' exit 0
    [[ $status -eq 1 ]]

    run run_ok '$status -eq 1' exit 1
    [[ $status -eq 0 ]]

    run run_ok '$status -eq 0' exit 1
    [[ $status -eq 1 ]]

    run run_ok '$output =~ "command not found"' xyz
    [[ $status -eq 0 ]]

    run run_ok '$output == ""' xyz
    [[ $status -eq 1 ]]
}

@test "test subtest" {
    run subtest "subtest PASS" 'is 1 1 "test is"'
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[PASS]} ]]

    run subtest "subtest FAIL" 'is 1 0 "test is"'
    [[ $status -eq 1 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[FAIL]} ]]

    skip
    run subtest "subtest SKIP" 'is 1 0 "test is"'
    [[ $status -eq 0 ]]
    [[ $output =~ ${BAUX_TEST_PROMPTS[SKIP]} ]]
}

@test "test skip & summary" {
    is 1 1 "test is"
    isnt 10 "test isnt"
    skip; like test test "test like"
    skip; subtest "test subtest" 'is 1 1 "test is"'
    run unlike test test "test unlike"

    run summary
    [[ $status -eq 0 ]]

    [[ ${BAUX_TEST_COUNTS[TOTAL]} -eq 4 ]]
    [[ ${BAUX_TEST_COUNTS[PASS]} -eq 2 ]]
    [[ ${BAUX_TEST_COUNTS[FAIL]} -eq 0 ]]
    [[ ${BAUX_TEST_COUNTS[SKIP]} -eq 2 ]]
}
