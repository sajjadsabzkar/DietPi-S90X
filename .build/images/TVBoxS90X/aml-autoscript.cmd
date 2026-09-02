# TVBox S90X: Amlogic vendor U-Boot multiboot script
#
# This script is run by the vendor firmware from the FAT boot partition as aml_autoscript.
# It sets the U-Boot environment to boot SD, USB or eMMC via a chain-loaded U-Boot
# (u-boot.ext / u-boot.emmc) and the s905_autoscript / emmc_autoscript scripts.
#
# Compile to the Amlogic multiboot script with:
# mkimage -C none -A arm64 -T script -d aml-autoscript.cmd aml_autoscript
#
# NOTE: The vendor U-Boot runs this script in 32-bit mode, hence the load address must be settable from aarch64 U-Boot as well.

echo ""
echo "!!!!!!! UPDATE UBOOT aml_autoscript IGA !!!!!!!"
sleep 3

defenv

# Disable / comment if box will not boot
if printenv bootfromsd; then exit; else setenv ab 0; fi;

# Update info
setenv upgrade_step 2
setenv system_part b

# Test if s905_autoscript on SD part 1/2 , USB OR emmc_autoscript Internal then run start_autoscript

# START bootcmd
setenv bootcmd 'if mmcinfo; then setenv bootsd "sdyes"; else setenv bootsd "sdno"; fi; echo "!!!SDCARD BOOT !!!!! ${bootsd}"; if test -e mmc 0:1 s905_autoscript || test -e mmc 0:2 s905_autoscript || test -e usb 0 s905_autoscript || test "${bootsd}" = "sdno" && test -e mmc 1 emmc_autoscript
 then
     echo ""
     echo "BOOT s905_autoscript OR emmc_autoscript"
     echo ""
     run start_autoscript

 fi
echo "STORE BOOT"
echo ""
run storeboot'
# END bootcmd

# Sdcard RUN s905_autoscript from part 1 OR 2 START s905_autoscript
setenv start_mmc_autoscript 'echo start_mmc_autoscript; echo ""; if fatload mmc 0:2 1020000 s905_autoscript || fatload mmc 0:1 1020000 s905_autoscript; then autoscr 1020000; fi;'

# USB scan RUN s905_autoscript dev 0 - 4
setenv start_usb_autoscript 'for usbdev in 0 1 2 3; do if fatload usb ${usbdev} 1020000 s905_autoscript; then autoscr 1020000; fi; done'

# Internal RUN  emmc_autoscript
setenv start_emmc_autoscript 'echo start_emmc_autoscript;echo "";fatload mmc 1 1020000 emmc_autoscript && autoscr 1020000'

# BOOT order SD , USB , INTERNAL  IF FOUND SD USB eMMCe RUN start_XXYY_autoscript
setenv start_autoscript 'echo "START AUTOSCRIPT";if mmcinfo; then run start_mmc_autoscript; fi; if usb start; then run start_usb_autoscript; fi; run start_emmc_autoscript'

echo ""
echo  "!!!!!!! UPDATE END REBOOT !!!!!!!"
echo ""

saveenv
sleep 5
reboot