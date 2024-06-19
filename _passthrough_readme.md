## USB Controller Passthrough

This guide provides instructions to passthrough a USB controller to a virtual machine.

### Step 1: Configure GRUB

Edit the GRUB configuration to enable IOMMU:

```bash
sudo nano /etc/default/grub
```

Replace `GRUB_CMDLINE_LINUX_DEFAULT='quiet splash'` with:

```bash
GRUB_CMDLINE_LINUX_DEFAULT='quiet splash intel_iommu=on'
```

Update GRUB:

```bash
sudo update-grub
```

### Step 2: Load VFIO Modules

Edit `/etc/modules` to load the VFIO modules at boot:

```bash
sudo nano /etc/modules
```

Add the following lines:

```bash
vfio
vfio_iommu_type1
vfio_pci
```

### Step 3: Update Initramfs and Reboot

Update initramfs and reboot the system:

```bash
sudo update-initramfs -k all -u
sudo shutdown -h now
```

### Step 4: Bind Devices to VFIO-PCI

Unbind the USB controller and the associated device from their current drivers and bind them to the `vfio-pci` driver:

```bash
# Unbind the USB controller from xhci_hcd
echo "0000:00:14.0" | sudo tee /sys/bus/pci/drivers/xhci_hcd/unbind
# Bind the USB controller to vfio-pci
echo "8086 9d2f" | sudo tee /sys/bus/pci/drivers/vfio-pci/new_id
echo "0000:00:14.0" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind

# Unbind the thermal subsystem from intel_pch_thermal
echo "0000:00:14.2" | sudo tee /sys/bus/pci/drivers/intel_pch_thermal/unbind
# Bind the thermal subsystem to vfio-pci
echo "8086 9d31" | sudo tee /sys/bus/pci/drivers/vfio-pci/new_id
echo "0000:00:14.2" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind
```

**Note:** You have to replace the device IDs with the correct ones for your system.

Check the device IDs:

```bash
lspci -nn
```

Check if there are other devices in the same IOMMU group:

```bash
find /sys/kernel/iommu_groups/ -type l
```

Check what driver is currently bound to the device:

```bash
lspci -nnk | grep -A 3 "8086:9d2f"
```

Update permissions so KVM can access the device:

```bash
sudo chmod 666 /dev/vfio/4
```

**Note:** The nuber `4` in `/dev/vfio/4` is the group number of the device. You may need to replace it with the correct group number for your system.

### Step 5: Create a Service to Rebind Devices on Boot

Create a script to unbind and bind the devices:

```bash
sudo nano /usr/local/bin/vfio-bind.sh
```

Add the following content:

```bash
#!/bin/bash
echo "0000:00:14.0" > /sys/bus/pci/drivers/xhci_hcd/unbind
echo "0000:00:14.2" > /sys/bus/pci/drivers/intel_pch_thermal/unbind
echo "8086 9d2f" > /sys/bus/pci/drivers/vfio-pci/new_id
echo "0000:00:14.0" > /sys/bus/pci/drivers/vfio-pci/bind
echo "8086 9d31" > /sys/bus/pci/drivers/vfio-pci/new_id
echo "0000:00:14.2" > /sys/bus/pci/drivers/vfio-pci/bind
```

Make the script executable:

```bash
sudo chmod +x /usr/local/bin/vfio-bind.sh
```

Create a systemd service to run the script at boot:

```bash
sudo nano /etc/systemd/system/vfio-bind.service
```

Add the following content:

```bash
[Unit]
Description=Bind USB controller to vfio-pci
After=sysinit.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/vfio-bind.sh
ExecReload=/usr/local/bin/vfio-bind.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

Enable the service:

```bash
sudo systemctl enable vfio-bind.service
```

### Step 6: Configure QEMU

Add the following line to the boot script to passthrough the USB controller:

```bash
-device vfio-pci,host=00:14.0,bus=pcie.0
```

### Troubleshooting

1. **Check if the correct driver is loaded:**

    ```bash
    lspci -nnk | grep -A 3 "8086:9d2f"
    ```

2. **Check if VFIO modules are loaded:**

    ```bash
    lsmod | grep vfio
    ```

3. **Check IOMMU group devices:**

    ```bash
    find /sys/kernel/iommu_groups/ -type l
    ```

4. **Set memory lock limit:**

    ```bash
    sudo nano /etc/security/limits.d/99-memlock.conf
    ```

    Add the following lines:

    ```bash
    dste hard memlock 9216000
    dste soft memlock 9216000
    ```

    Verify the memory lock limit:

    ```bash
    su - dste
    ulimit -l
    ```

    **Note:** Replace `dste` with your username.

**Note:** Some USB controllers may not support reset capability, which can cause the VM to fail. In such cases, consider using a different USB controller.
