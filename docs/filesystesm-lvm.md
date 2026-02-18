sudo lsblk | grep -v '^loop'

NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                         8:0    0   1.8T  0 disk 
├─sda1                      8:1    0     1M  0 part 
├─sda2                      8:2    0   1.5G  0 part /boot
└─sda3                      8:3    0   1.8T  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0   512G  0 lvm  /
nvme0n1                   259:0    0   2.9T  0 disk 
└─nvme0n1p1               259:1    0   2.9T  0 part /data01
nvme1n1                   259:2    0   2.9T  0 disk 
└─nvme1n1p1               259:3    0   2.9T  0 part /data02

sudo lvextend -L +412g /dev/mapper/ubuntu--vg-ubuntu--lv

# for uuid
sudo blkid

/etc/fstab

<UUID or Label>  <Mount point>  <File system type>  <Mount options>  <fs_freq>  <fs_passno>

/dev/sda2: UUID="a420287b-9972-4018-b691-8251719240e6" TYPE="ext4" PARTUUID="388d9440-fe72-474f-943d-ce1e936c9b8b"
/dev/sda3: UUID="Xmfxv4-Mbxn-WN9v-gs3b-KcoN-yEzV-50NbCv" TYPE="LVM2_member" PARTUUID="077979d0-568c-4365-b6eb-7df96dbf08e7"
/dev/nvme1n1p1: UUID="08ea8190-78b1-4190-bd65-dff3485e5595" TYPE="ext4" PARTUUID="58823f3d-100a-4e54-aee8-7f6793b6f1ee"
/dev/nvme0n1p1: UUID="bbf49c40-b296-404d-97ed-aa5616a344e0" TYPE="ext4" PARTUUID="285df2b2-f11e-4360-b6ea-3a5efcea5861"
/dev/mapper/ubuntu--vg-ubuntu--lv: UUID="bbc226e7-104a-4c51-ae57-40125e3af341" TYPE="ext4"
/dev/loop0: TYPE="squashfs"
/dev/loop1: TYPE="squashfs"
/dev/loop2: TYPE="squashfs"
/dev/loop3: TYPE="squashfs"
/dev/loop4: TYPE="squashfs"
/dev/loop5: TYPE="squashfs"
/dev/loop6: TYPE="squashfs"
/dev/loop7: TYPE="squashfs"
/dev/sda1: PARTUUID="0e5df741-e6ec-4258-9221-0efb4cc2d04d"

# du - summarizes disk usage of each FILE, recuresively dor directories

du -hs /path-to-director

du -h | sort -h

sudo du -h -d 1 /var/sna

# LVM

link: https://wiki.ubuntu.com/Lvm

## What is LVM

LVM stands for Logical Volume Management. It is a system of managing logical volumes, or filesystems, that is much more advanced and flexible than the traditional method of partitioning a disk into one or more segments and formatting that partition with a filesystem.

## Why use LVM

For a long time I wondered why anyone would want to use LVM when you can use gparted to resize and move partitions just fine. The answer is that lvm can do these things better, and some nifty new things that you just can't do otherwise. I will explain several tasks that lvm can do and why it does so better than other tools, then how to do them. First you should understand the basics of lvm.

## The Basics
There are 3 concepts that LVM manages:

- Volume Groups
- Physical Volumes
- Logical Volumes

A Volume Group is a named collection of physical and logical volumes. Typical systems only need one Volume Group to contain all of the physical and logical volumes on the system, and I like to name mine after the name of the machine. Physical Volumes correspond to disks; they are block devices that provide the space to store logical volumes. Logical volumes correspond to partitions: they hold a filesystem. Unlike partitions though, logical volumes get names rather than numbers, they can span across multiple disks, and do not have to be physically contiguous.