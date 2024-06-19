## usbfluxd - USB over IP

### Linux Host

Download the latest release from the [GitHub repository](https://github.com/corellium/usbfluxd)

```bash
# Extract the tarball into `usbfluxd` directory
tar -xvf usbfluxd-*.tar

# Delete the tarball
rm usbfluxd-*.tar

# Move the contents of the extracted directory to the `usbfluxd` directory
mkdir usbfluxd
mv usbfluxd-*/* usbfluxd
rm -r usbfluxd-*

# Install dependencies
sudo apt-get update
sudo apt-get install -y libplist-dev usbmuxd socat

# You need to open multiple terminals to run the following commands because they will block the terminal.

# Start usbmuxd
sudo systemctl start usbmuxd

# Start socat server
sudo socat tcp-listen:5000,fork unix-connect:/var/run/usbmuxd

# Start usbfluxd host
sudo usbfluxd -f -n
```

#### Install the `usbfluxd_host.service`

```bash
# make `usbfluxd_host_service_install.sh` executable
chmod +x usbfluxd_host_service_install.sh

# Check if `usbfluxd` is available in the PATH (only needs to be available temporarily, the installation script will resolve the path during installation)
which usbfluxd

# If `usbfluxd` is not available in the PATH, add it to the PATH
cd $usbfluxd_location
export PATH=$(pwd):$PATH

# install the `usbfluxd_host.service`
sudo ./usbfluxd_host_service_install.sh

# Enable the `usbfluxd_host.service`
sudo systemctl enable usbfluxd_host.service

# You can check the status of the service
sudo systemctl status usbfluxd_host.service

# Or manually start and stop the service
sudo systemctl start usbfluxd_host.service
sudo systemctl stop usbfluxd_host.service
```

### macOS Guest

```bash
# Install homebrew
export HOMEBREW_NO_INSTALL_FROM_API=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install autoconf automake libtool pkg-config libplist libimobiledevice usbmuxd

# Add dependencies to the PATH
export PATH="/usr/local/opt/libtool/libexec/gnubin:$PATH"

# Clone the repository
git clone https://github.com/corellium/usbfluxd.git

# Run `autogen.sh` to generate the `configure` script
cd usbfluxd
./autogen.sh
make
sudo make install

# Add usbfluxd to the PATH
export PATH="/usr/local/sbin:$PATH"

# Start usbmuxd
sudo launchctl start usbmuxd

# Start usbfluxd
sudo usbfluxd -f -r 172.20.2.149:5000
```

#### Install the `usbfluxd.guest.plist` (macOS service)

```bash
# Make `usbfluxd_guest_service_install.sh` executable
chmod +x usbfluxd_guest_service_install.sh

# Set the IP address of the host machine
$HOST_IP="172.20.2.149"

# Install the `usbfluxd.guest.plist`
sudo ./usbfluxd_guest_service_install.sh

# Enable the `usbfluxd.guest.plist`
sudo launchctl load /Library/LaunchDaemons/usbfluxd.guest.plist

# You can check the status of the service
sudo launchctl list | grep usbfluxd.guest

# Or manually start and stop the service
sudo launchctl start usbfluxd.guest
sudo launchctl stop usbfluxd.guest
```
