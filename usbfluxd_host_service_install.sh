#!/bin/bash

# Get usbfluxd location
USBFLUXD_PATH=$(which usbfluxd)

# Fetch script directory
REPO_PATH=$(dirname "$(readlink -f "$0")")

# Replace %usbfluxd% in the service file with the actual path
sed -i "s|%usbfluxd%|$USBFLUXD_PATH|g" "$REPO_PATH/usbfluxd_host.service"

# Copy the modified service file to /etc/systemd/system/
sudo cp "$REPO_PATH/usbfluxd_host.service" /etc/systemd/system/

# Reset the service in git repo
git checkout -- "$REPO_PATH/usbfluxd_host.service"

# Reload systemd daemon to apply the new service file
sudo systemctl daemon-reload

# Enable the service to start on boot
# sudo systemctl enable usbfluxd_host.service