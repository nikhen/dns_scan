## dns_scan

This is a script to target open DNS ports using nmap scripts.

The script takes a domain name as argument, locates one of the corresponding nameservers,  and runs nmap UDP and TCP scans against this port.

Common DNS misconfigurations are reported.

If a brutespray installation is detected, discovered services are targeted for a brute-force attack.

#### Prerequisites

1. Nmap installation (i.e. typing nmap into your terminal should work)
2. [OPTIONAL]: brutespray installation

#### Usage

In the parent directory of this project, run

     bash dns_scan.sh HOSTNAME

where *HOSTNAME* is the target's hostname.
