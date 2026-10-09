# Linux Disk & Storage Practice Lab

Two disposable environments for practising Linux storage administration: partitioning,
filesystems, mounting, fstab, LVM and recovery. You can break them freely and rebuild them in seconds.

| Variant | Folder | Best for |
|---|---|---|
| **Container** | [`container/`](container) | Quick practice. Three loop-backed 256 MB "disks" appear as `/dev/sda`, `/dev/sdb`, `/dev/sdc` |
| **KVM VM** | [`kvm/`](kvm) | Realistic practice: a Debian 12 cloud image with 3 extra virtio-scsi disks, boot and fstab recovery |

## Container variant
```bash
cd container
docker build -t disk-lab .
docker run -d --name disk-lab --privileged -p 2222:22 -v disk-lab-data:/disks disk-lab
ssh student@localhost -p 2222        # lab password: student
```
The entrypoint creates the disk images once, attaches them to free loop devices (and reuses them
after a restart), and starts sshd. `--privileged` is required for `losetup`.

## KVM variant
`kvm/user-data` and `kvm/meta-data` are a cloud-init NoCloud seed (user `student`, SSH enabled).
`kvm/domain.xml` is the libvirt definition: an OS disk plus `sdb`, `sdc` and `sdd` for practice.

```bash
D=/var/lib/libvirt/images/mount-lab; mkdir -p $D
cp debian-12-genericcloud-amd64.qcow2 $D/os-disk.qcow2 && qemu-img resize $D/os-disk.qcow2 10G
for d in sdb sdc sdd; do qemu-img create -f qcow2 $D/practice-$d.qcow2 1G; done
cloud-localds $D/seed.iso kvm/user-data kvm/meta-data
virsh define kvm/domain.xml && virsh start mount-lab
```

## Example exercises
- Create GPT partitions with `parted` / `gdisk`, then format them as ext4 and XFS
- Mount by UUID in `/etc/fstab` and test with `mount -a`
- Build an LVM volume group across two disks, then extend an LV online
- Break `/etc/fstab`, boot into emergency mode and fix it

> ⚠️ Lab passwords (`student` / `root`) and root SSH login are intentional. Never expose this lab to a network.

## Stack
Debian 12 · Docker · libvirt/KVM · cloud-init · util-linux, parted, gdisk, LVM2, e2fsprogs, xfsprogs
