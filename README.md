Target nameservers of a given domain to gather information and check for common nameserver misconfigurations.

This script wants you to give it a domain - it will then locate one of the corresponding nameservers and run UDP and TCP scans against the nameserver. Behind the scenes, it uses nmap scripting and will therefore report common DNS misconfigurations.

## How do I run a dns_scan?
Here are a few instructions you will find helpful to start checking nameservers.
### Prerequisites
It is assumed that you are runnning in a linux environment. Currently, this script requires the bash shell to run.
With a few twists and turns, other environments might be realistic. In addition, the following libraries are required:
1. Nmap installation (i.e. typing nmap into your terminal should work)

If these prerequisites are met, you may clone this repository and change to the parent directory (i.e. the directory where this file is located on your machine.)

You may then proceed as described below.

### Calling the Script

In the parent directory of this project, run

     bash dns_scan.sh -d HOSTNAME

where *HOSTNAME* is the target's hostname. This will target the hostname given.

If you have multiple hostnames, you may specify a file where multiple hostnames are listed:

     bash dns_scan.sh -f FILE_CONTAINING_HOSTNAMES

The script will then iterate over the list of hostnames and run a scan for every single one of them.

To get a list of all available options, set the -h flag

     bash dns_scan.sh -h

## How do I interpret these results?
In its current scope, this script is basically a wrapper for nmap specifically suited for scanning nameservers. As such, it performs
port scans and executes nse scripts suited for that purpose. Like nmap, it may be used by nameserver administrators, penetration testers and their friends
to check the nameservers for possible vulnerabilities.

You may find an introduction to the nameserver-specific checks that are performed useful. You may find such an introduction below. This may help you
in interpreting the output of this scanner.

In a previous version, this script took three input parameters: ip address, port number and host name. It assumed that you already had
done some reconnaissance, basically having identified open ports with DNS services behind. This scope seemed to be highly specialized
and did not suit with a general "audience". Therefore, in its current version, the script needs only a hostname and tries to
identify one of the corresponding nameservers from there. This is a broader scope which might not satisfy those with a specific purpose
in mind, but it will make using this tool much more accessible, as all you need to get started is now a hostname.

A note on scanning scope. It seems that it is enough to run all the scans on one of the nameservers identified. Therefore, the tool is particularly suited
to check general configurations common to multiple nameserver instances. It is not suited to monitor each and every single instance.
This should be kept in mind when interpreting scan results.

So let's get started and dive deeper into the scans performed and their interpretation.

### dns-nsid
The script retrieves the following information from the nameserver: nameserver id (nsid), server id (id.server) and version id (version.bind).
This information shows you which particular nameserver instance you are connected. The value of version.bind might reveal information on outdated server components containing known vulnerabilities.

### dns-update
An unauthenticated update of DNS records is triggered. You don't want this to be possible if you are the owner of the nameserver. To check for this
vulnerability, the script is configured to use bogus hostname and ip address. If successful, an attacker might be able to manipulate the
existing configuration.

### dns-zeustracker
This script checks if the ip address corresponding to the targeted server is part of a Zeus botnet. More information is available 
[here](https://zeustracker.abuse.ch/ztdns.php).

### dns-nsec3-enum
The script tries to identify nonexistant domains using a technique called [NSEC3 walking](https://nmap.org/nsedoc/scripts/dns-nsec3-enum.html).
Findings will be in the form of hashes which will have to be dealt with using an offlie cracking tool.

### dns-zone-transfer
Checks the name server for a zone transfer vulnerability. Any potential information find will be printed on the screen. You don't expect output here.
As an administrator or nameserver owner, you don't want output here for anyone.
If you find something, dig deeper.

### dns-srv-enum
Tries to enumerate various common services and their port numbers for a given domain. Findings may be regarded as informational or
a starting point for further exploration.

### fcrdns
Reports anomaluos results performing a so-called "forward-confirmed reverse DNS lookup" (Look [here](https://en.wikipedia.org/wiki/Forward-confirmed_reverse_DNS) if something unusual pops up...).

### Amplification vulnerability
The nameserver might be vulnerable to a [denial of service attack](https://isc.sans.edu/diary/DNS+queries+for+/5713). This is the case if this check generates substantial output. If you find something, you might verify using the online tool given in above reference.

### Check for rogue nameserver
There is a list of rogue nameservers published by the [FBI](https://fbi.gov/dns-changer-malware.pdf). If parts of the nameserver's IP address point to one of the subnets listed in the publication, an alert is raised.

### dns-brute
Enumerates hostnames by guessing subdomain names.

### dns-fuzz
This launches a DNS fuzzing attack against the targeted DNS server by introducing small errors in otherwise valid DNS requests.
Timelimit for fuzzing is set to 5m which is quite low for obtaining results, but quite high if you are in an environment where you 
probably shouldn't be fuzzing at all. Modify variable *dns_fuzzing_timelimit* in *dns_scan.sh* to change the value to your needs.

