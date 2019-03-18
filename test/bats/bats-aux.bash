[[ $BATS_AUX_SOURCED -eq 1 ]] && return

BATS_AUX_SOURCED=1

run_error() {
    echo -e "\t$*" >&2
    echo -e "\tstatus: $status" >&2
    echo -e "\toutput: $output" >&2
    false
}

