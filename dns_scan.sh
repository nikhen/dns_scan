#!/bin/bash

function check_arguments() {
    echo "Checking command line arguments; show useage for invalid arguments"

    echo "Check ip syntax"

    echo "Check port"
}

function run_port_scan() {
    echo "Running port scans on dns port"
}

function display_result() {
    echo "Print result"
}

function main() {
    local ip=$1
    local port=$2
    echo "Starting Test Scan for IP" $ip $port

    check_arguments $ip $port
 
    run_port_scan $ip $port

    display_result
}

main $1 $2
