#!/bin/bash

# Function to check if the IP octets are valid
check_ip_octets() {
    local octet1="$1"
    local octet2="$2"
    local octet3="$3"
    local octet4="$4"

    if [[ "$octet1" -gt 255 || "$octet2" -gt 255 || "$octet3" -gt 255 || "$octet4" -gt 255 ]]; then
        printf "Invalid IP address: each octet must be <= 255\n" >&2
        return 1
    fi
    return 0
}

while true; do
    read -rp "Please enter an IP address to scan (or type 'q' to quit): " IP_ADDRESS

    if [[ "$IP_ADDRESS" == "q" ]]; then
        printf "Exiting the program.\n"
        exit 0
    fi

    if [[ "$IP_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IFS='.' read -r octet1 octet2 octet3 octet4 <<< "$IP_ADDRESS"

        if check_ip_octets "$octet1" "$octet2" "$octet3" "$octet4"; then
            printf "Scanning IP address: %s\n\n" "$IP_ADDRESS"
            
            whois "$IP_ADDRESS" | grep -E 'NetName|descr|Country|role|abuse-mailbox'

            exit 0
        else
            printf "The IP address contains invalid octets.\n"
        fi

    else
        printf "Invalid IP address format.\n"
    fi

    printf "\n"
done
