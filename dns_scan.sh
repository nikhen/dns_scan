#!/bin/bash

NMAP_RESULT_FILE=dns_scan_$(date --iso-8601=s).gnmap

function print_usage_disclaimer() {
        echo "Please run this script with three command line arguments."
        echo "Usage:"
        echo "    bash dns_scan.sh IP_ADDRESS PORT_NUMBER HOSTNAME"
	echo ""
}

function print_variable() {
    echo $1 $2"."
}

function print_separator() {
    echo ""
}

function check_arguments() {
    if [ $# -eq 3 ]; then
        if [[ $2 =~ ^-?[0-9]+$ ]]; then
            print_variable "Scanning port" $2
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
    local enum_script_arguments="dns-srv-enum.domain="$domain
    local dns_fuzz_arguments="timelimit="$timelimit
    local dns_update_arguments="dns-update.hostname=dnswizard.com,dns-update.ip=192.0.2.1"

    print_variable "Fuzzing timelimit is set to" $timelimit
    print_separator

    nmap -sSU -p $port --script dns-nsid.nse $ip
    print_separator
    nmap -sU -p $port --script=dns-update --script-args=$dns_update_arguments $ip
    print_separator
    nmap -sn -PN --script=dns-zeustracker $ip
    print_separator
    nmap -p $port --script=dns-nsec3-enum.nse --script-args dns-nsec3-enum.domains=$domain $ip
    print_separator
    nmap -sSU -p $port --script=dns-zone-transfer.nse $ip -oN $NMAP_RESULT_FILE
    print_separator
    nmap --script=dns-srv-enum --script-args $enum_script_arguments
    print_separator
    nmap $ip -sSU -p $port --script=dns-fuzz.nse --script-args $dns_fuzz_arguments 
    print_separator
    echo "Port scan finished."
    print_separator
}

function display_result() {
    echo "Done."
}

function crack_services() {
    local IS_BRUTESPRAY_AVAILABLE=$(command -v brutespray | wc -l)

    if [ $IS_BRUTESPRAY_AVAILABLE -gt 0 ]
    then
        brutespray -f $NMAP_RESULT_FILE
    else
        echo "Install brutespray to try to crack services."
        echo "    apt install brutespray"
        print_separator
    fi
}

function clean_up() {
    rm $NMAP_RESULT_FILE
    rm -r brutespray-output
}

function main() {
    local ip=$1
    local port=$2
    local domain=$3

    print_variable "Scanning IP" $ip 
    print_variable "Domain name is" $domain

    check_arguments $ip $port $domain
 
    run_port_scan $ip $port $domain

    crack_services

    display_result

    clean_up
}

main $1 $2 $3
