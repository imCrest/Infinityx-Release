# Project Infinity X - ARB-Safe Flashing Guide

Safe flashing instructions for **A/B devices**.

> [!IMPORTANT]
> Read every step carefully before flashing.
>
> - ARB-safe build
> - This process will wipe all data
> - Follow the guide exactly

## Downloads

- ROM: [Latest Release](https://github.com/imCrest/Infinityx-Release/releases/latest)
- Firmware: [Download Here](https://sourceforge.net/projects/larry-rom-archive/files/Firmware/firmware_cph2467_1800.zip/download)

### Files You Need

Download these files before starting:

- ROM zip
- `boot.img`
- `vendor_boot.img`
- `dtbo.img`
- `flash_fw.bat` (included in the firmware package)

## Requirements

- Backup all important data
- Unlocked bootloader
- PC with ADB and Fastboot installed
- USB drivers for your device
- USB cable
- Extracted firmware package on your PC

## Step 1: Enable Developer Options

1. Open **Settings** -> **About Phone**
2. Tap **Build Number** 7 times
3. Go to **Developer Options**
4. Enable:
   - **USB Debugging**
   - **OEM Unlocking**

## Step 2: Verify Device Connection

```bash
adb devices
```

## Step 3: Reboot to Bootloader

```bash
adb -d reboot bootloader
```

## Step 4: Unlock Bootloader

```bash
fastboot flashing unlock
```

- Confirm the unlock on your device
- Your phone will wipe data and reboot automatically

## Step 5: Enter Fastboot Mode Again

After the device reboots:

- Power off the device
- Hold **Volume Down + Power** to enter fastboot mode again

## Step 6: Flash Firmware to Both Slots

Run the included firmware script:

```bat
flash_fw.bat
```

- This flashes firmware to both **A/B slots**
- Make sure the firmware package is extracted before running the script

## Step 7: Flash Required Partitions

```bash
fastboot flash boot boot.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash dtbo dtbo.img
```

## Step 8: Reboot to Recovery

```bash
fastboot reboot recovery
```

## Step 9: Format Data

In recovery:

- Select **Factory Reset** or **Format Data**

## Step 10: Sideload the ROM

On your phone:

- Go to **Apply Update**
- Select **Apply from ADB**

Then run:

```bash
adb -d sideload <your-rom.zip>
```

## Step 11: Flash Additional Packages If Prompted

- If recovery asks for additional packages, select **Yes**

## Step 12: Format Data Again

- Perform **Format Data** once more after sideloading

## Step 13: Reboot to System

- Select **Reboot to System**

## Notes

- First boot can take several minutes
- Keep your battery sufficiently charged before flashing
- Double-check that all files match your device before starting
- Flash at your own risk

## Done

Your device should now boot into **Project Infinity X**.
