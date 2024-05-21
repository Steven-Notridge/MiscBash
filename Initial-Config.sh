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

# Quick update.
apt update

# Check to see if these are installed anyway, and install them if they are not present.
HAS_TREE="$(type "tree" &> /dev/null && echo true || echo false)"
HAS_IPTABLES="$(type "iptables" &> /dev/null && echo true || echo false)"
HAS_SUDO="$(type "sudo" &> /dev/null && echo true || echo false)"
HAS_GIT="$(type "git" &> /dev/null && echo true || echo false)"

if [ "${HAS_TREE}" != "false" ]; then
    echo "Tree not detected, will now install."
    apt install tree
fi

if [ "${HAS_IPTABLES}" != "false" ]; then
    echo "Iptables not detected, will now install."
    apt install iptables
fi

if [ "${HAS_SUDO}" != "false" ]; then
    echo "Sudo not detected, will now install."
    apt install sudo
fi

if [ "${HAS_GIT}" != "false" ]; then
    echo "git not detected, will now install."
    apt install git
fi

# Get the username and strip to the first word.
username=$(tail -1 /etc/passwd)
username=$(echo "$username" | cut -d':' -f1)
echo "Username: $username found."

# Now to add user to sudoers. I'm aware this is bad practice but it's just a homelab.
user_as_sudo="${username}   ALL=(ALL:ALL) NOPASSWD: ALL"

# Use sed to add the new line after the specified pattern
sed -i "/^root[[:space:]]*ALL=(ALL:ALL)[[:space:]]*ALL/a\\$user_as_sudo" /etc/sudoers
echo "Script completed."
