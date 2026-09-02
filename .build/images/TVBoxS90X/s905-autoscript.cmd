# TVBox S90X: chain-load U-Boot script for SD/USB boot
#
# Loads and runs u-boot.ext from the FAT boot partition of SD (mmc 0) or USB,
# which then reads /boot/boot.scr to boot DietPi.
#
# Compile to the SD multiboot script with:
# mkimage -C none -A arm64 -T script -d s905-autoscript.cmd s905_autoscript

if mmcinfo; then
	if fatload mmc 0:1 0x1000000 u-boot.ext; then go 0x1000000; fi
	if fatload mmc 0:2 0x1000000 u-boot.ext; then go 0x1000000; fi
fi
if usb start; then
	if fatload usb 0:1 0x1000000 u-boot.ext; then go 0x1000000; fi
	if fatload usb 0:2 0x1000000 u-boot.ext; then go 0x1000000; fi
fi
if fatload mmc 1:1 0x1000000 u-boot.emmc; then go 0x1000000; fi