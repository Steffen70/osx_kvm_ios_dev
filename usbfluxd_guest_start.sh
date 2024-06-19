#!/bin/bash

# Start usbmuxd
sudo launchctl start usbmuxd

# Start usbfluxd
/usr/local/bin/usbfluxd -r %host_ip%:5000
