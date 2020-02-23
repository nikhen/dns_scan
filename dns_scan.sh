#!/bin/bash

NMAP_RESULT_FILE=dns_scan_$(date --iso-8601=s).gnmap

function print_usage_disclaimer() {
        echo "Usage:"
        echo "    bash dns_scan.sh HOSTNAME"
	echo ""
}

function get_nameserver() {
    NAMESERVER_RECORD=$(dig ns $domain +short | grep -m1 "")
    local FOUND_NAMESERVER_RECORD=$(echo $NAMESERVER_RECORD | wc -m)

    if [ $FOUND_NAMESERVER_RECORD -gt 1 ]
    then
        NAMESERVER_RECORD=$(echo $NAMESERVER_RECORD | sed 's/.$//')
        print_variable "Found nameserver record: " $NAMESERVER_RECORD
    else
        print_variable "Error: Could not find nameserver record for domain " $domain
        print_usage_disclaimer
        exit 1
    fi
}

function print_variable() {
    echo $1 $2"."
}

function print_separator() {
    echo ""
}

function run_port_scan() {
    local target=$NAMESERVER_RECORD
    local timelimit=5m
    local enum_script_arguments="dns-srv-enum.domain="$domain
    local dns_fuzz_arguments="timelimit="$timelimit
    local dns_update_arguments="dns-update.hostname=dnswizard.com,dns-update.ip=192.0.2.1"
    local port=53

    print_variable "Fuzzing timelimit is set to" $timelimit
    print_variable "Domain from input is" $domain
    print_separator

    nmap -sSU -p $port --script dns-nsid.nse $target
    print_separator
    nmap -sU -p $port --script=dns-update --script-args=$dns_update_arguments $target
    print_separator
    nmap -sn -PN --script=dns-zeustracker $target --open
    print_separator
    nmap -p $port --script=dns-nsec3-enum.nse --script-args dns-nsec3-enum.domains=$domain $target
    print_separator
    nmap -sSU -p $port --script=dns-zone-transfer.nse $target
    print_separator
    nmap --script=dns-srv-enum --script-args $enum_script_arguments
    print_separator
    nmap $target -sSU -p $port --script=dns-fuzz.nse --script-args $dns_fuzz_arguments 
    print_separator
    nmap -A $target -oN $NMAP_RESULT_FILE --open
    echo "Port scan finished."
    print_separator
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
    local domain=$1

    get_nameserver
 
    run_port_scan

    crack_services

    clean_up
}

main $1
