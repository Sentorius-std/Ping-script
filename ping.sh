#!/bin/bash

# Function to calculate elapsed time
calculate_time() {
    start_time=$1
    end_time=$2
    elapsed_time=$((end_time - start_time))
    minutes=$((elapsed_time / 60))
    seconds=$((elapsed_time % 60))
    echo "$minutes minutes, $seconds seconds elapsed"
}

# Function to calculate percentage and time remaining
calculate_progress() {
    total=$1
    current=$2
    elapsed_time=$3
    time_per_ping=$((elapsed_time / current))

    # Calculate percentage of completion
    percentage=$(( (current * 100) / total ))

    # Estimate the remaining time using the time per ping
    if [ $current -eq 0 ]; then
        remaining_time="Calculating..."
    else
        remaining_pings=$((total - current))
        remaining_seconds=$((time_per_ping * remaining_pings))
        remaining_minutes=$((remaining_seconds / 60))
        remaining_seconds=$((remaining_seconds % 60))
        remaining_time="${remaining_minutes}m ${remaining_seconds}s remaining"
    fi

    # Clear the line and display the progress
    echo -ne "Progress: $percentage% - Elapsed: $elapsed_time seconds - $remaining_time\r"
}

# Function to ping the network and print reachable hosts
ping_network() {
    network=$1
    total=254 # Total number of possible hosts in a /24 network

    # Get the start time of the scan
    start_time=$(date +%s)

    # Loop through all the IPs in the network range
    for i in {1..254}; do
        # Construct the IP address
        ip="$network.$i"
        
        # Ping each host with 3 packets, 7 second timeout
        ping -c 3 -W 3 $ip > /dev/null 2>&1
        
        # If the host responds to the ping, print it
        if [ $? -eq 0 ]; then
            echo "$ip is up"
        fi

        # Get the current time to calculate elapsed time
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        # Update the progress and time remaining
        calculate_progress $total $i $elapsed_time
    done

    # Final summary with total elapsed time
    end_time=$(date +%s)
    calculate_time $start_time $end_time
    echo -ne "\nScan completed!\n"
}

# Ask for user input for the network (x.x.x.0 format, no /24)
read -p "Enter the network (e.g., 192.168.1): " network

# Remove any trailing `/24` from the input
network="${network%%/24}"

# Call the ping_network function
ping_network $network
