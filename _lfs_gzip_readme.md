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
# Reconstruct the original file
cat mac_hdd_ng.img.tar.gz.part-* | pv | gzip -d | tar -xvf -
```
