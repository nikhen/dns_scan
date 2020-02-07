## dns_scan


This is a script to target open DNS ports using nmap scripts.

The script takes an IP address and port number as arguments and runs nmap UDP and TCP scans against this port.

Common DNS misconfigurations are reqported.

#### Prerequisites

1. Nmap installation (i.e. typing nmap into your terminal should work)
2. bash

#### Usage

In the parent directory of this project, run

     bash dns_scan.sh IP_ADDRESS PORT_NUMBER

where *IP_ADDRESS* is a valid ip address and *PORT_NUMBER* an integer. Ideally, this corresponds to an open port - most likely 53 - discovered in previous nmap exploration.
