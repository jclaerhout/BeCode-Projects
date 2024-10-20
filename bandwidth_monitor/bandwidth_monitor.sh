#!/bin/bash

# Function to get the list of network interfaces
get_interfaces() {
    ip -o link show | awk -F': ' '{print $2}'
}

# Function to get the bytes for a given interface and type (rx_bytes or tx_bytes)
get_bytes() {
    local interface="$1"
    local type="$2"
    cat "/sys/class/net/$interface/statistics/$type"
}

# Function to monitor the bandwidth usage of a given interface
monitor_interface() {
    local interface="$1"
    local duration="$2"
    local log_file="bandwidth_usage.log"

    # Check if the log file exists, if not, create it
    if [[ ! -f "$log_file" ]]; then
        touch "$log_file"
    fi

    # Get the current timestamp
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Get the initial values for transmitted and received bytes
    local rx_bytes_initial
    local tx_bytes_initial
    rx_bytes_initial=$(get_bytes "$interface" "rx_bytes")
    tx_bytes_initial=$(get_bytes "$interface" "tx_bytes")

    # Display the countdown timer
    for ((i=1; i<=duration; i++)); do
        printf "\rElapsed time: %d/%d seconds" "$i" "$duration"
        sleep 1
    done
    echo

    # Get the final values for transmitted and received bytes
    local rx_bytes_final
    local tx_bytes_final
    rx_bytes_final=$(get_bytes "$interface" "rx_bytes")
    tx_bytes_final=$(get_bytes "$interface" "tx_bytes")

    # Calculate the difference in transmitted and received bytes
    local rx_bytes_diff=$((rx_bytes_final - rx_bytes_initial))
    local tx_bytes_diff=$((tx_bytes_final - tx_bytes_initial))

    # Convert bytes to megabytes
    local rx_mb=$(echo "scale=2; $rx_bytes_diff / 1024 / 1024" | bc)
    local tx_mb=$(echo "scale=2; $tx_bytes_diff / 1024 / 1024" | bc)
    local total_mb=$(echo "scale=2; $rx_mb + $tx_mb" | bc)

    # Log the bandwidth usage with the interface name
    echo "$timestamp $interface $total_mb MB" >> "$log_file"

    # Display the bandwidth usage
    echo -e "\nBandwidth usage for $interface at $timestamp:"
    echo "Transmitted: $tx_mb MB"
    echo "Received: $rx_mb MB"
    echo "Total: $total_mb MB"
}

# Store the interfaces in an array
IFS=$'\n' read -r -d '' -a interfaces < <(get_interfaces && printf '\0')

# Display the available interfaces in color
echo -e "Available interfaces: \e[32m${interfaces[*]}\e[0m\n"

while true; do
    read -rp "Please enter an interface to monitor (or type 'q' to quit): " INTERFACE
    if [[ "$INTERFACE" == "q" ]]; then
        echo "Exiting..."
        exit 0
    fi

    # Check if the entered interface is valid
    if [[ " ${interfaces[*]} " == *" $INTERFACE "* ]]; then

        # Ask for the duration
        while true; do
            read -rp "For how many seconds would you like to monitor the interface? " DURATION
            if [[ "$DURATION" =~ ^[1-9][0-9]*$ ]]; then
                break
            else
                echo -e "\n\e[31mInvalid duration. Please enter a positive number that does not start with zero.\e[0m\n"
            fi
        done

        echo -e "Monitoring interface: \e[32m$INTERFACE\e[0m"
        monitor_interface "$INTERFACE" "$DURATION"

        exit 0
    else
        echo -e "\n\e[31mInvalid interface.\e[0m Please try again.\n"
    fi
done