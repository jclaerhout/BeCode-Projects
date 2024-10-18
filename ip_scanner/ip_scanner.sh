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

# Function to perform Whois lookup
whois_lookup() {
    local ip="$1"

    printf "## Whois lookup ##\n"
    # Perform a whois query and filter specific fields
    whois "$ip" | grep -E 'NetName|descr|Country|role|abuse-mailbox'
}

# Function to perform Reverse DNS lookup
reverse_dns_lookup() {
    local ip="$1"

    printf "\n## Reverse DNS Lookup ##\n"
    if host "$ip" &> /dev/null; then
        host "$ip" | awk '/domain name pointer/ {print $5}'
    else
        printf "No reverse DNS record found for %s\n" "$ip"
    fi
}

# Function to perform HTTP/HTTPS query
http_query() {
    local protocol="$1"
    local ip="$2"

    printf "\n## %s Query ##\n" "$protocol"
    response=$(curl --connect-timeout 5 --max-time 10 -o /dev/null -s -w "%{http_code}" "$protocol://$ip")
    
    if [[ "$response" == "000" ]]; then
        printf "No %s response from %s\n" "$protocol" "$ip"
    else
        printf "%s response code: %s\n" "$protocol" "$response"
    fi
}

# Function to perform Geolocation lookup
geolocation_lookup() {
    local ip="$1"

    printf "\n## Geolocation info ##\n"
    local geolocation
    geolocation=$(curl -s "http://ip-api.com/json/$ip")
    
    if [[ $(jq -r '.status' <<< "$geolocation") == "fail" ]]; then
        printf "Failed to retrieve geolocation info for %s\n" "$ip"
    else
        jq -r '. | "Country: \(.country)\nRegion: \(.regionName)\nCity: \(.city)\nISP: \(.isp)\nLat: \(.lat)\nLon: \(.lon)"' <<< "$geolocation"
    fi
}

# Main scanning process function
process_scan() {
    local ip="$1"

    whois_lookup "$ip"
    reverse_dns_lookup "$ip"
    http_query "http" "$ip"
    http_query "https" "$ip"
    geolocation_lookup "$ip"
}

# Main program loop
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
            
            process_scan "$IP_ADDRESS"
            exit 0
        else
            printf "The IP address contains invalid octets.\n"
        fi

    else
        printf "Invalid IP address format.\n"
    fi

    printf "\n"
done
