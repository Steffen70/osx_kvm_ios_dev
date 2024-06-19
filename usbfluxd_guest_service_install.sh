#!/bin/bash

# Check if $HOST_IP is set else inform the user
if [ -z "$HOST_IP" ]; then
  echo "Please set the HOST_IP environment variable to the IP address of the host machine."
  exit 1
fi

# Fetch script directory
REPO_PATH=$(dirname "$(readlink -f "$0")")

# Replace %host_ip% in the start script with the actual IP
sed -i "s|%host_ip%|$HOST_IP|g" "$REPO_PATH/usbfluxd_guest_start.sh"

# Make the start script executable
chmod +x "$REPO_PATH/usbfluxd_guest_start.sh"

# Copy the modified start script to /usr/local/bin/
sudo cp "$REPO_PATH/usbfluxd_guest_start.sh" /usr/local/bin/

# Reset the start script in git repo
git checkout -- "$REPO_PATH/usbfluxd_guest_start.sh"

# Copy the service plist to /Library/LaunchDaemons/
sudo cp "$REPO_PATH/usbfluxd.guest.plist" /Library/LaunchDaemons/

# Load the service
# sudo launchctl load /Library/LaunchDaemons/usbfluxd.guest.plist