# Best DNS For Baypass 403 And set for Resolve.conf

This script helps you test the latency of multiple DNS servers by measuring the response times for a specific domain. The script reads a list of DNS server addresses from a text file (`dns_servers.txt`) and displays the response times for each server, sorted from fastest to slowest. The script uses the `dig` command to query the DNS servers and outputs the results in a user-friendly format.

## Features

- Tests the response time for multiple DNS servers in parallel.
- Outputs DNS response times in milliseconds (ms).
- Results are sorted by response time for easy comparison.
- Easy to use with minimal setup.

## Prerequisites

- Linux-based OS (Ubuntu, Rocky Linux, etc.)
- `dig` command installed (usually comes with the `dnsutils` package).

## Setup Instructions
1. Clone this repository:
   ```bash
   git clone https://github.com/alireza-daneshfahim/DNS-Best-Speed.git 
   cd DNS-Best-Speed-For-Resolve/
   ```
2. Modify dns_servers.txt
Open dns_servers.txt and add or update the list of DNS servers you want to test (one per line).

3. Run the script and view results:
   ```bash
   ./dns_best_speed_set_reslove.sh
   ```

The script will output the DNS response times, sorted from fastest to
slower and set Best Speed DNS Response to /etc/resolv.conf 
