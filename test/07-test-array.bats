#! /usr/bin/bats

SRC_DIR=$PWD
source $SRC_DIR/lib/array.sh


@test "test push" {
    array=()

    push array one
    [[ ${array[$((${#array[@]}-1))]} == "one" ]]

    push array ""
    [[ ${array[$((${#array[@]}-1))]} == "" ]]

    push array two
    [[ ${array[$((${#array[@]}-1))]} == "two" ]]

    push array three four
    [[ ${array[$((${#array[@]}-2))]} == "three" ]]
    [[ ${array[$((${#array[@]}-1))]} == "four" ]]
}

@test "test pop" {
    array=(one two "" three four)

    pop array
    [[ ${array[$((${#array[@]}-1))]} == "three" ]]
    pop array
    [[ ${array[$((${#array[@]}-1))]} == "" ]]
    pop array
    [[ ${array[$((${#array[@]}-1))]} == "two" ]]
    pop array
    [[ ${array[$((${#array[@]}-1))]} == "one" ]]
    pop array
    pop array
    run pop array
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "test _shift" {
    array=(one two "" three four)

    run _shift array
    [[ $status -eq 0 ]]
    [[ $output == "one" ]]

    _shift array
    [[ ${array[0]} == "two" ]]
    _shift array
    [[ ${array[0]} == "" ]]
    _shift array
    [[ ${array[0]} == "three" ]]
    _shift array
    [[ ${array[0]} == "four" ]]

    _shift array
    _shift array
    run _shift array
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "test unshift" {
    array=()

    unshift array ""
    [[ ${array[0]} == "" ]]

    unshift array one
    [[ ${array[0]} == "one" ]]

    unshift array two three
    [[ ${array[0]} == "two" ]]
    [[ ${array[1]} == "three" ]]
}

@test "test slice" {
    array=(one two three four five)

    run slice array 0
    [[ $status -eq 0 ]]
    [[ $output == "one" ]]

    run slice array 0 0
    [[ $status -eq 0 ]]
    [[ $output == "one one" ]]

    run slice array 0 1
    [[ $status -eq 0 ]]
    [[ $output == "one two" ]]

    run slice array 0 1 2
    [[ $status -eq 0 ]]
    [[ $output == "one two three" ]]

    run slice array 0 1 2 -1
    [[ $status -eq 1 ]]
    [[ $output =~ "little than 0" ]]

    run slice array 0 1 2 100 3
    [[ $status -eq 0 ]]
    [[ $output =~ "one two three four" ]]
    
    declare -A map=()
    map[one]=1
    map[two]=2
    map[three]=3
    map[four]=4

    run slice map one 100 two
    [[ $status -eq 0 ]]
    [[ $output =~ "1 2" ]]
}

@test "test keys" {
    array=(1 2 3 4 5)

    run keys array
    [[ $status -eq 0 ]]
    [[ $output == "0 1 2 3 4" ]]

    declare -A map=()
    map[one]=1
    map[two]=2
    map[three]=3
    map[four]=4

    run keys map
    echo $output
    [[ $status -eq 0 ]]
    [[ $output =~ "one" ]]
    [[ $output =~ "two" ]]
    [[ $output =~ "three" ]]
    [[ $output =~ "four" ]]
}

@test "test values" {
    array=(1 2 3 4 5)

    run values array
    [[ $status -eq 0 ]]
    [[ $output == "1 2 3 4 5" ]]

    array=()

    run values array
    [[ $status -eq 0 ]]
    [[ $output == "" ]]

    array=(" " " " " ")

    run values array
    [[ $status -eq 0 ]]
    [[ $output == "     " ]]
}

@test "test exists" {
    array=(1 2 3 4 5)

    run exists array 0
    [[ $status -eq 0 ]]

    run exists array 1
    [[ $status -eq 0 ]]

    run exists array 6
    [[ $status -eq 1 ]]

    declare -A map=()
    map[one]=1
    map[two]=2
    map[three]=3
    map[four]=4
    
    run exists map one
    [[ $status -eq 0 ]]

    run exists map two
    [[ $status -eq 0 ]]

    run exists map five
    [[ $status -eq 1 ]]
}

@test "test _join" {
    array=(one two three "" five)

    run _join : "${array[@]}"
    [[ $status -eq 0 ]]
    [[ $output == "one:two:three::five" ]]
}

@test "test _split" {
    declare -a array=()
    
    _split "one::three:" array ":"
    [[ ${array[0]} == "one" ]]
    [[ ${array[1]} == "" ]]
    [[ ${array[2]} == "three" ]]
    [[ ${array[3]} == "" ]]

    array=()

    _split "one  three " array
    [[ ${array[0]} == "one" ]]
    [[ ${array[1]} == "" ]]
    [[ ${array[2]} == "three" ]]
    [[ ${array[3]} == "" ]]

    array=()

    _split "   " array
    [[ ${array[0]} == "" ]]
    [[ ${array[1]} == "" ]]
    [[ ${array[2]} == "" ]]
    [[ ${array[3]} == "" ]]

    array=()

    _split "one  three " array ":"
    [[ ${array[0]} == "one  three " ]]
}

@test "test sort" {
    array=({10..0})

    __issorted $(_sort $(_sort -R ${array[@]}))
    __issorted $(select_sort $(_sort -R ${array[@]}))
    __issorted $(insert_sort $(_sort -R ${array[@]}))
    __issorted $(shell_sort $(_sort -R ${array[@]}))
}

@test "test search" {
    array=({1..100})

    run search array 49
    [[ $output == "48" ]]

    run search array 100
    [[ $output == "99" ]]

    run search array 49 100
    [[ $output == "48 99" ]]
}

@test "test lsearch" {
    array=({0..1000})

    NEED=$((RANDOM % 1000))
    run lsearch array  $NEED
    [[ $output == $NEED ]]

    NEED=$((RANDOM % 1000))
    run lsearch array $NEED
    [[ $output == $NEED ]]
}

@test "test bsearch" {
    array=({0..10})

    NEED=$((RANDOM % 10))
    run bsearch array $NEED
    [[ $output == $NEED ]]

    NEED=$((RANDOM % 10))
    run bsearch array $NEED
    [[ $output == $NEED ]]
}
