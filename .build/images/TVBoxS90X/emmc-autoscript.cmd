# TVBox S90X: chain-load U-Boot script for intern eMMC boot
#
# Loads and runs u-boot.emmc from the FAT boot partition of the intern eMMC,
# which then reads /boot/boot.scr to boot DietPi.
#
# Compile to the eMMC multiboot script with:
# mkimage -C none -A arm64 -T script -d emmc-autoscript.cmd emmc_autoscript

if fatload mmc 1 0x1000000 u-boot.emmc; then go 0x1000000; fi