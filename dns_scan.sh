#!/bin/bash

function print_usage_disclaimer() {
        echo "Please run this script with three command line arguments."
        echo "Usage:"
        echo "    bash dns_scan.sh IP_ADDRESS PORT_NUMBER HOSTNAME"
	echo ""
}

function check_arguments() {
    if [ $# -eq 3 ]; then
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
    local timelimit=5m

    echo "Running port scans on dns port" $port
    echo "Timelimit is set to" $timelimit

    nmap -sSU -p $port --script=dns-nsid.nse $ip
    nmap -sSU -p $port --script=dns-update.nse --script-args=dns-update.hostname=dnswizard.com,dns-update.ip=192.0.2.1 $ip
    nmap -sn -PN --script=dns-zeustracker $ip
    nmap -sSU -p $port --script=dns-nsec3-enum.nse --script-args dns-nsec3-enum.domains=$domain $ip
    nmap -sSU -p $port --script=dns-zone-transfer.nse $ip
    nmap --script=dns-srv-enum.nse --script-args "dns-srv-enum.domain="$domain $ip -v
    nmap -sSU -p $port --script=dns-fuzz.nse $ip --script-args timelimit=$timelimit
}

function display_result() {
    echo "Done."
}

function main() {
    local ip=$1
    local port=$2
    local domain=$3

    echo "Starting Test Scan for IP" $ip $port ". Domain name is" $domain

    check_arguments $ip $port $domain
 
    run_port_scan $ip $port $domain

    display_result
}

main $1 $2 $3
