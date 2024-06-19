# OSX-KVM for iOS Development Environment

**Note:** This guide is a fork of the original [OSX-KVM](https://github.com/kholia/OSX-KVM) repository. The original repository contains additional information and resources that may be useful.
This fork is inteded to provide a more streamlined guide for running macOS as a build and development environment for iOS apps on a Linux server.

-   Create a new macOS VM on Linux follow the instructions in this readme.
-   You have allready created a macOS vm and want to run it headless follow the instructions in the [\_headless_readme.md](./_headless_readme.md) file.
-   You want to backup your macOS vm on Git LFS follow the instructions in the [\_lfs_gzip_readme.md](./_lfs_gzip_readme.md) file.
-   You want to build and run iOS apps on your macOS vm follow the instructions in the [\_usbfluxd_readme.md](./_usbfluxd_readme.md) file.

**Note:** If you don't run the macOS vm on a server and instead want to run it on your local machine you could also directly pass through the USB controller to the macOS vm and skip the usbfluxd setup.
Passing through the USB controller is dificult to setup and may not work on your hardware. If you want to try it follow the instructions in the [\_passthrough_readme.md](./_passthrough_readme.md) file.

### Installation Preparation

```bash
# Install prerequisites
sudo apt-get install qemu uml-utilities virt-manager git \
    wget libguestfs-tools p7zip-full make dmg2img tesseract-ocr \
    tesseract-ocr-eng genisoimage vim net-tools screen -y

# Navigate to your workspace

# Clone the repository and navigate to the repository root
git clone --depth 1 --recursive https://github.com/Steffen70/osx_kvm_ios_dev.git osx_kvm
cd osx_kvm

# KVM may need the following tweak on the host machine to work
sudo modprobe kvm; echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs

# To make this change permanent, you may use the following command (add the kvm.conf file to /etc/modprobe.d/ - adds the ignore_msrs=1 parameter to the kvm module)
sudo cp kvm.conf /etc/modprobe.d/kvm.conf  # for intel boxes only
sudo cp kvm_amd.conf /etc/modprobe.d/kvm.conf  # for amd boxes only

# Permissions - Add user to the kvm and libvirt groups (needed if you intent to run the vm as a non-root user)
sudo usermod -aG kvm $(whoami)
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG input $(whoami)

# Fetch the BaseSystem.dmg file for your desired macOS version (use the latest macOS version - older versions do not support the latest xcode versions)
./fetch-macOS-v2.py

# Convert the downloaded BaseSystem.dmg file into the BaseSystem.img file
dmg2img -i BaseSystem.dmg BaseSystem.img

# Create a virtual HDD image where macOS will be installed
qemu-img create -f qcow2 mac_hdd_ng.img 256G
```

### Installation

```bash
# Start the macOS VM installation process
./OpenCore-Boot.sh
```

-   Use the Disk Utility tool within the macOS installer to partition, and format the virtual disk attached to the macOS VM. Use APFS (the default) for modern macOS versions.

-   Go ahead, and install macOS via the macOS installer

-   You can find additional information on how to generate a unique serial number and install XCode in the [\_headless_readme.md](./_headless_readme.md) file.
