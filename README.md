## dns_scan

This is a script to target open DNS ports using nmap scripts.

The script takes a domain name as argument, locates one of the corresponding nameservers,  and runs nmap UDP and TCP scans against this port.

Common DNS misconfigurations are reported.

If a brutespray installation is detected, discovered services are targeted for a brute-force attack.

### How to run this script
Here are a few instructions you will need to run this script.
#### Prerequisites
First of all it is assumed that you are runnning in a linux environment. Currently, this script requires the bash shell to run.
With a few twists and turns, other environments might be realistic. In addition, the following libraries are required.
1. Nmap installation (i.e. typing nmap into your terminal should work)
2. [OPTIONAL]: brutespray installation

If these prerequisites are met, you may clone this repository and change to the parent directory (i.e. the directory where this file is located on your machine. You may then proceed as described below.

#### Usage

In the parent directory of this project, run

     bash dns_scan.sh HOSTNAME

where *HOSTNAME* is the target's hostname.

### How to interpret results
In its current scope, this script is basically a wrapper for nmap specifically suited for scanning nameservers. As such, it performs
port scans and scripts suited for that purpose. Like nmap, it may be used by nameserver administrators, penetration testers and their friends
to check the nameservers of their domain for possible vulnerabilities.

You may find an introduction to the nameserver specific checks that are performed on the namenservers of a given domain. This may help you
interpret the output of this tool.

In a previous version, this script took three input parameters: ip address, port number and host name. It assumed that you already had
done some reconnaissance, basically having identified open ports with DNS services behind. This scope seemed to be highly specialized
and did not suit with how the script was used. Therefore, in its current version, the script takes only the hostname and tries to
identify one of the corresponding nameservers from there. This is a broader scope which might not satisfy those with a specific purpose
in mind, but it will make using this tool much more accessible, as all you need to run it is now a hostname.

It is assumed that it is sufficient to run all the scans on one of the nameservers identified. Therefore, the tool is particularly suited
to check general configurations common to multiple nameserver instances. It is not suited to monitor each and every single instance.
This should be kept in mind when interpreting scan results.

So let's get started and hdive deeper into the scans performed and their interpretation.

#### dns-nsid
The script retrieves the following information from the nameserver: nameserver id (nsid), server id (id.server) and version id (version.bind).
This information shows you which particular nameserver instance you are connected.
#### dns-update
An unauthenticated update of DNS records is triggered. You don't want this to be possible if you are the owner of the nameserver. To check for this
vulnerability, the script is configured to use bogus hostname and ip address. If successful, an attacker might be able to manipulate the
existing configuration.
#### dns-zeustracker
This script checks if the ip address corresponding to the targeted server is part of a Zeus botnet. More information is available 
[here](https://zeustracker.abuse.ch/ztdns.php).
#### dns-nsec3-enum
The script tries to identify nonexistant domains using a technique called [NSEC3 walking](https://nmap.org/nsedoc/scripts/dns-nsec3-enum.html).
Findings will be in the form of hashes which will have to be dealt with using an offlie cracking tool.
#### dns-zone-transfer
Checks the name server for a zone transfer vulnerability. Any potential information find will be printed on the screen. You don't expect output here.
As an administrator or nameserver owner, you don't want output here for anyone.
If you find something, dig deeper.
#### dns-srv-enum
Tries to enumerate various common services and their port numbers for a given domain. Findings may be regarded as informational or
a starting point for further exploration.
#### dns-fuzz
This launches a DNS fuzzing attack against the targeted DNS server by introducing small errors in otherwise valid DNS requests.
Timelimit for fuzzing is set to 5m which is quite low for obtaining results, but quite high if you are in an environment where you 
probably shouldn't be fuzzing at all. Modify variable *dns_fuzzing_timelimit* in *dns_scan.sh* to change the value to your needs.

#### Aggressive Port Scan
An aggressive port scan (*nmap -A*) on 1000 most popular tcp ports is performed to identify services on top of DNS that are running on the nameserver.
The results of this scan are used as a starting point for a brute force attack using brutespray. This way, possible vulnerabilities in these
services can be identified. If brutespray is not installed, this step is skipped.

