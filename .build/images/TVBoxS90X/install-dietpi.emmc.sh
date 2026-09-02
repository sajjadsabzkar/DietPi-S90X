#!/bin/bash
# TVBox S90X: Install the running SD card DietPi installation to the intern eMMC
##########################################
# DietPi-S90X: For these cheap Amlogic TV boxes, the intern eMMC can be used as primary storage.
#
# This script copies the running SD card DietPi installation to the intern eMMC drive.
# The same partition layout (FAT boot partition + ext4 root partition) is used, hence the
# boot scripts and DietPi kernel files can be reused and the box boots both from SD and eMMC.
#
# Afterwards you can either:
# - Power off the box, remove the SD card and power on again to boot from eMMC, or
# - Keep the SD card inserted and boot DietPi from eMMC via "dietpi-drive_manager".
#
# Short alternative: dd the whole SD card to the eMMC drive, e.g.:
# sudo dd if=/dev/mmcblk0 of=/dev/mmcblk1 bs=4M status=progress conv=fsync
# NOTE: The eMMC drive must then be at least as large as the used part of the SD card.
##########################################
Error_Exit(){ echo "Error: $1"; exit 1; }
[[ $EUID -eq 0 ]] || Error_Exit 'Run this script as root, i.e. "sudo bash install-dietpi.emmc.sh"'
command -v 'dd' > /dev/null || Error_Exit 'Missing required command: dd'

# Determine the SD card and eMMC drives
FP_SDCARD=$(findmnt -Ufnro SOURCE /boot)
[[ $FP_SDCARD =~ ^/dev/mmcblk[0-9]+p[0-9]+$ ]] || Error_Exit "Unsupported /boot source: $FP_SDCARD"
FP_SD_DEV=${FP_SDCARD%p*}
FP_EMMC=/dev/mmcblk1
[[ -b $FP_SD_DEV ]] || Error_Exit "SD card drive not found: $FP_SD_DEV"
[[ -b $FP_EMMC ]] || Error_Exit "intern eMMC drive not found: $FP_EMMC"
[[ $FP_SD_DEV == "$FP_EMMC" ]] && Error_Exit 'Refusing to copy the SD card onto itself'

# Copy only the used size of the SD card
used_bytes=$(( ( $(sfdisk -qlo End "$FP_SD_DEV" | tail -1) + 1 ) * 512 ))
used_mb=$(( used_bytes / 1048576 + 1 ))
echo "Copying the first $used_mb MiB of $FP_SD_DEV to $FP_EMMC ..."
echo
read -r -p 'Really overwrite the intern eMMC drive (y/N)? ' answer
[[ $answer =~ ^[yY]$ ]] || Error_Exit 'Aborted by user'
dd if="$FP_SD_DEV" of="$FP_EMMC" bs=4M count=$(( used_mb / 4 + 1 )) status=progress conv=fsync,sync || Error_Exit 'Copy failed'
partprobe "$FP_EMMC" || true

echo
echo 'Done. Power the box off, remove the SD card and power on again to boot DietPi from the intern eMMC.'
echo 'NOTE: DietPi resizes the root filesystem automatically on the first boot.'