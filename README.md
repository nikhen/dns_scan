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
