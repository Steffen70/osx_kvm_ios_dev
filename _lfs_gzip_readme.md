## LFS - split and compress image with Gzip

#### Compress and Split:

```bash
# Compress the file with gzip and split into 1GB parts
tar -cf - mac_hdd_ng.img | pv | gzip -9 | split -b 1G - mac_hdd_ng.img.tar.gz.part-
```

**Push to remote:**

```bash
chmod +x commit_and_push_parts.sh

./commit_and_push_parts.sh
```

#### Reconstruct:

```bash
# Make sure lfs is installed - install it with apt-get
sudo apt install git-lfs

# Download the parts
git lfs pull

# Reconstruct the original file
cat mac_hdd_ng.img.tar.gz.part-* | pv | gzip -d | tar -xvf -

# Install qemu (the only dependency you really need to run the image)
# - the package name is qemu-system in newer linux versions (before qemu)
sudo apt install qemu-system -y

# Run the image
./OpenCore-Boot.sh
```
