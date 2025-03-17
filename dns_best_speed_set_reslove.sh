#!/bin/bash

# Check if the dns_servers.txt file exists
if [[ ! -f dns_servers.txt ]]; then
    echo "Error: dns_servers.txt not found!"
    exit 1
fi

echo "Testing DNS latency..."
echo "-------------------------------------"
echo "DNS Server          Response Time (ms)"
echo "-------------------------------------"

TEST_DOMAIN="download.docker.com"
RESULTS_FILE=$(mktemp)

# Function to test a DNS server
test_dns() {
    local DNS_SERVER=$1
    local RESPONSE_TIME=$(timeout 10 dig @$DNS_SERVER $TEST_DOMAIN +stats | awk '/Query time:/ {print $4}')
    
    if [[ -z "$RESPONSE_TIME" ]]; then
        RESPONSE_TIME="Timeout"
    else
        RESPONSE_TIME="${RESPONSE_TIME} ms"
    fi

    printf "%-20s %s\n" "$DNS_SERVER" "$RESPONSE_TIME" >> "$RESULTS_FILE"
}

export -f test_dns
export TEST_DOMAIN RESULTS_FILE

# Run DNS tests in parallel
cat dns_servers.txt | grep -v '^#' | grep -v '^$' | xargs -P 10 -I {} bash -c 'test_dns "{}"'

# Wait for all background processes to finish
wait

# Print sorted results (numeric values first, followed by timeouts)
{ grep -E '[0-9]+ ms' "$RESULTS_FILE" | sort -nk2; grep -E 'Timeout' "$RESULTS_FILE"; }

# Find the fastest DNS server
BEST_DNS=$(grep -E '[0-9]+ ms' "$RESULTS_FILE" | sort -nk2 | head -n 1 | awk '{print $1}')

# Remove temporary results file
rm -f "$RESULTS_FILE"

echo "-------------------------------------"
echo "Best DNS Server: $BEST_DNS"

# If a valid DNS server is found, update /etc/resolv.conf
if [[ -n "$BEST_DNS" ]]; then
    echo "Updating /etc/resolv.conf with the fastest DNS server..."
    
    # Check if the script is running as root
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root to modify /etc/resolv.conf"
        echo "Try running: sudo $0"
        exit 1
    fi

    # Replace the nameserver in resolv.conf
    echo -e "nameserver $BEST_DNS\noptions timeout:1 attempts:3" > /etc/resolv.conf
    echo "DNS updated successfully!"
else
    echo "No valid DNS server found!"
fi

