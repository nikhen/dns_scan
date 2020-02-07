#!/bin/bash

function print_usage_disclaimer() {
        echo "Please run this script with two command line arguments."
        echo "Usage:"
        echo "    bash dns_scan.sh IP_ADDRESS PORT_NUMBER"
	echo ""
}

function check_arguments() {
    if [ $# -eq 2 ]; then
        if [[ $2 =~ ^-?[0-9]+$ ]]; then
            echo "Scanning port" $2
        else
            print_usage_disclaimer
            echo "PORT_NUMBER has to be integer."
            exit 1
        fi
    else
        echo $# "command line arguments."
        print_usage_disclaimer
        exit 1
    fi
}

function run_port_scan() {
    echo "Running port scans on dns port" $port

    nmap -sSU -p $port --script=dns-nsid.nse $ip
    nmap -sSU -p $port --script=dns-srv-enum.nse $ip
    nmap -sSU -p $port --script=dns-fuzz.nse $ip
    nmap -sSU -p $port --script=dns-update.nse $ip
    nmap -sSU -p $port --script=dns-ip6-arpa-scan.nse $ip
    nmap -sSU -p $port --script=dns-zeustracker.nse $ip
    nmap -sSU -p $port --script=dns-nsec3-enum.nse $ip
    nmap -sSU -p $port --script=dns-zone-transfer.nse $ip
}

function display_result() {
    echo "Done."
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
