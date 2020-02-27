#!/bin/bash

function print_usage_disclaimer() {
        echo "" && echo "Usage:"
        echo "    bash dns_scan.sh [-d HOSTNAME] [-f FILE_LOCATION] [-m MAXIMUM_TARGETS] [-h]"
	echo ""
        echo "    -d HOSTNAME: set hostname of single target"
        echo "    -f FILE_LOCATION: set location of a file containing additional hostnames (one per line)"
        echo "    -m MAXIMUM_TARGETS: set maximum number of targets (default: 1000)"
        echo "    -v: verbose output"
        echo "    -h: show this help"
}

function get_nameserver() {
    local domain=$1
    print_variable "Getting nameserver record for " $domain
    NAMESERVER_RECORD=$(dig ns $domain +short | grep -m1 "")
    local FOUND_NAMESERVER_RECORD=$(echo $NAMESERVER_RECORD | wc -m)

    if [ $FOUND_NAMESERVER_RECORD -gt 1 ]
    then
        NAMESERVER_RECORD=$(echo $NAMESERVER_RECORD | sed 's/.$//')
        print_variable "Found nameserver record: " $NAMESERVER_RECORD
    else
        print_variable "Error: Could not find nameserver record for domain" $domain
        echo "    Try 'dig ns" $domain"' to find possible clues."
        return 51
    fi
}

function get_targets_from_file() {
    if [ -z $INPUT_FILE_LOCATION ]; then
        return 1
    fi

    local filename=$INPUT_FILE_LOCATION

    local i=1
    while read line; do
        TARGET_LIST+=($line)
        if [ ${#TARGET_LIST[@]} -ge $MAXIMUM_TARGETS ]
        then
            print_variable "Maximum number of targets: " $MAXIMUM_TARGETS
            break
        fi
        i=$((i+1))
    done < $filename
}

function print_variable() {
    echo $(date)":" $1 $(tput setaf 2)$2$(tput sgr0)"."
}

function announce_port_scan() {
    echo $(date)":" $(tput setaf 6)$1$(tput sgr0)
}

function print_global_progress() {
    print_separator
    echo $(date)": Scanning domain ("$2"/"$3")"$(tput setaf 3) $1 $(tput sgr0)
}

function print_separator() {
    echo ""
}

function run_port_scan() {
    if [ $VERBOSITY -gt 0 ]; then
        nmap $1 $2 $3 $4 -v
    else
        nmap $1 $2 $3 $4 | sed s/Starting.*// | sed s/Host.*// | sed s/Nmap.*// | sed s/PORT.*// | sed s/53.*// | sed /^$/d
    fi
}

function run_port_scans() {
    local domain=$1
    local target=$NAMESERVER_RECORD
    local dns_fuzzing_timelimit=5m
    local enum_script_arguments="dns-srv-enum.DOMAIN="$domain
    local dns_fuzz_arguments="timelimit="$dns_fuzzing_timelimit
    local dns_update_arguments="dns-update.hostname=dnswizard.com,dns-update.ip=192.0.2.1"
    local port=53

    print_variable "Fuzzing timelimit is set to" $dns_fuzzing_timelimit
    print_variable "Domain from input is" $domain

    announce_port_scan "Obtaining nameserver identifier information."
    run_port_scan -sSU "--script dns-nsid.nse" $target "-p "$port

    announce_port_scan "Trying DNS update."
    run_port_scan -sU "--script=dns-update --script-args="$dns_update_arguments $target "-p "$port

    announce_port_scan "Checking zeustracker."
    run_port_scan "-sn -PN" "--script=dns-zeustracker" $target
 
    announce_port_scan "NSEC3 Enumeration."
    run_port_scan -sU "--script=dns-nsec3-enum" $target "-p "$port

    announce_port_scan "Checking zone transfer vulnerability."
    run_port_scan -sSU "--script=dns-zone-transfer.nse" $target "-p "$port

    announce_port_scan "Service enumeration."
    run_port_scan -sSU "--script=dns-srv-enum --script-args "$enum_script_arguments $target "-p "$port

    announce_port_scan "Forward-confirmed Reverse DNS lookup."
    run_port_scan "-sn -Pn" "--script fcrdns" $target

    check_amplification_vulnerability 

    announce_port_scan "Brute force hostname guessing."
    run_port_scan -sn "--script dns-brute" $target

    print_variable "Starting dns fuzzing with timeout set to " $dns_fuzzing_timelimit
    run_port_scan -sSU "--script=dns-fuzz.nse --script-args="$dns_fuzz_arguments $target "-p"$port
}

function check_amplification_vulnerability() {
    announce_port_scan "Checking for DNS amplification vulnerability of "$NAMESERVER_RECORD
    dig . NS @$NAMESERVER_RECORD | sed s/^[\;].*$// | sed /^$/d
}

function clean_up() {
    rm $NMAP_RESULT_FILE
}

function check_domain() {
    local domain=$1
    if [ -z $domain ]
    then
        print_usage_disclaimer
        exit 1
    fi
}

function iterate_over_targets() {
    number_of_targets=${#TARGET_LIST[@]}
    n=1
    for target_domain in "${TARGET_LIST[@]}"
    do
        print_global_progress $target_domain $n $number_of_targets
        get_nameserver $target_domain
        if [ $? -lt 50 ]; then
            run_port_scans $target_domain
        else
            print_variable "Skipping port scan for domain" $target_domain
        fi
        n=$((n+1))
    done
}

function main() {
    get_targets_from_file
    iterate_over_targets
}

# Processing input parameters; setting global variables
declare -a TARGET_LIST
NMAP_RESULT_FILE=_dns_scan_$(date --iso-8601=s).gnmap
MAXIMUM_TARGETS=100
VERBOSITY=0

while getopts "d:f:m:hv" arg; do 
  case ${arg} in
    d) 
      DOMAIN=${OPTARG}
      check_domain $DOMAIN
      TARGET_LIST[0]=$DOMAIN
      print_variable "Added domain to targets:" $DOMAIN
      ;;
    f) 
      INPUT_FILE_LOCATION=${OPTARG}
      ;;
    m) 
      MAXIMUM_TARGETS=${OPTARG}
      print_variable "Set maximum number of targets to " $MAXIMUM_TARGETS
      ;;
    h)
      print_usage_disclaimer
      exit 1
      ;;
    v)
      VERBOSITY=1
      ;;
  esac
done

# Call to main function
main
