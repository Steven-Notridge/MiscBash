#!/bin/bash

# For a fresh Debian Non-GUI install.

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo."
    # Prompt the user for password and try to elevate privileges
    if su true; then
        echo "Successfully elevated privileges."
    else
        echo "Failed to elevate privileges. Exiting."
        exit 1
    fi
fi

# Get basic apps that I use often.
apt update && apt install sudo && apt install git && apt install iptables

# Get the username and strip to the first word.
username=$(tail -1 /etc/passwd)
username=$(echo "$username" | cut -d':' -f1)
echo "Username: $username found."

# Now to add user to sudoers. I'm aware this is bad practice but it's just a homelab.
user_as_sudo="${username}   ALL=(ALL:ALL) NOPASSWD: ALL"

# Use sed to add the new line after the specified pattern
sed -i "/^root[[:space:]]*ALL=(ALL:ALL)[[:space:]]*ALL/a\\$user_as_sudo" /etc/sudoers
echo "Script completed."
