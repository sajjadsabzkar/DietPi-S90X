# TVBox S90X DietPi boot files

These text files are the sources of the boot files that the DietPi installer generates/profile on the FAT boot partition of images for cheap Amlogic S905X/S905W/S905D/S912/S905X2/S905X3 "S90X" Android TV boxes. No binary boot blobs are stored in this repository.

## Boot chain

The boxes ship with an Android firmware incl. vendor U-Boot in the internal eMMC. The boot flow is:

1. The vendor firmware scans SD/USB/eMMC for a FAT partition with an `aml_autoscript` script, runs it via `autoscr`.
2. `aml_autoscript` sets the environment and triggers `s905_autoscript` (SD/USB) or `emmc_autoscript` (internal eMMC).
3. `s905_autoscript`/`emmc_autoscript` load the Armbian multiboot U-Boot (`u-boot.ext`/`u-boot.emmc`) and run it via `go`.
4. That U-Boot reads `boot.scr` from the FAT partition, which is generated from `boot.cmd` via `mkimage` and boots DietPi.

## Files

- `boot.cmd`: DietPi boot script source, compiled to `boot.scr`. Detects whether it was loaded from SD (`mmc 0:1`), eMMC (`mmc 1:1`) or USB and loads kernel, initramfs, device tree and overlays from the same partition, since the chain-loaded U-Boot does not set the usual environment defaults. Default device tree is `amlogic/meson-gxl-s905x-p212.dtb`, overridable via `fdtfile=` in `/boot/dietpiEnv.txt`.
- `aml-autoscript.cmd`: compiled to `aml_autoscript`, identical to the proven Amlogic vendor multiboot script, incl. the SD/USB/eMMC boot priority and `storeboot`.
- `s905-autoscript.cmd`: compiled to `s905_autoscript`, loads `u-boot.ext` from SD/USB FAT partitions.
- `emmc-autoscript.cmd`: compiled to `emmc_autoscript`, loads `u-boot.emmc` from the internal eMMC.
- `99-dietpi-uboot`: initramfs post-update hook for the FAT boot partition, which copies `initrd.img-<version>` to `initrd.img` instead of creating a symlink.
- `install-dietpi.emmc.sh`: helper script, copied to the FAT boot partition as `install-dietpi.emmc.sh`, to install the running SD card DietPi installation to the internal eMMC.

## U-Boot binaries

The actual U-Boot binaries (`u-boot-s905x-s912` as default `u-boot.ext`, `u-boot-s905x2-s922` for S905X2/S905X3 boxes) are **compiled from source** by the `tvbox-uboot-build` GitHub Actions workflow and shipped to the fork's `tvbox-s90x-u-boot` release as the `linux-u-boot-110-current` package, which the DietPi installer downloads and installs (`dpkg -i`) at image build time.

The build follows the instructions of the Armbian `aml-s9xx-box` board config (used by balbes150/hexdump0815), which has `BOOTCONFIG='none'` and boots via the vendor U-Boot plus these chain-load scripts:

- `u-boot-s905x-s912`: U-Boot `v2020.07` + `u-boot-s905x-s912.patch`, `libretech-cc_defconfig`: https://github.com/armbian/build/tree/main/config/optional/boards/aml-s9xx-box/_packages/bsp-cli/boot/build-u-boot
- `u-boot-s905x2-s922`: U-Boot `v2024.01` + `u-boot-s905x2-s922.patch`, `sei510_defconfig` (same source directory).

To boot S905X2/S905X3 boxes, rename/copy `u-boot-s905x2-s922` (already on the boot partition) to `u-boot.ext`.