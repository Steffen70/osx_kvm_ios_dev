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

# Add a restart alias to .bash-alises (optional, but you need to restart the service often - so it's useful)
[ -f ~/.bash_aliases ] || touch ~/.bash_aliases; echo "alias restart_usbfluxd='sudo systemctl restart usbfluxd_host.service'" >> ~/.bash_aliases

# Reload the .bash_aliases (or restart the terminal)
source ~/.bashrc

# Restart the service
restart_usbfluxd
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
# sudo launchctl start usbmuxd
sudo launchctl start libusbmuxd

# Start usbfluxd
sudo usbfluxd -f -r 172.20.2.149:5000
```

I tried to create a service for `usbfluxd` on macOS, but I couldn't get it to work. You often need to restart the service to get it working again. So I recommend running the command manually.

But you can add an alias to your `.zshrc` to start `usbfluxd` with a single command.

```bash
# Check if you are using zsh (default shell on macOS)
echo $SHELL

# Create a .zshrc file if it doesn't exist
[ -f ~/.zshrc ] || touch ~/.zshrc

# Add the following line to your .zshrc (or .bash-aliases if you are using bash)
# Resolce usbfluxd to keep working even if usbfluxd is only available in the PATH temporarily
echo "alias start_usbfluxd='sudo $(which usbfluxd) -f -r 172.20.2.149:5000'" >> ~/.zshrc

# Reload the .bashrc or .zshrc (or restart the terminal)
source ~/.zshrc

# run the alias
start_usbfluxd
```
