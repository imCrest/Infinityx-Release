# Project Infinity-X 4.0 - Android 17 Flashing Guide (OnePlus Nord CE 2 Lite / 3 Lite 5G / N30 - `larry`)

Official Flashing & Partition Setup Guide for **Project Infinity-X 4.0 (Android 17)** on OnePlus Nord CE 2 Lite 5G, OnePlus Nord CE 3 Lite 5G, and OnePlus Nord N30 5G (`larry`).

Based on the [Official LineageOS Larry Wiki](https://wiki.lineageos.org/devices/larry/install/variant1) and device partition requirements.

### Supported Models (Exact Match Required):
- **CPH2467** (OnePlus Nord CE 2 Lite 5G)
- **CPH2465** (OnePlus Nord CE 3 Lite 5G)
- **CPH2513** (OnePlus Nord N30 5G)
- **CPH2515** (OnePlus Nord N30 5G)

---

> [!CAUTION]
> **CRITICAL WARNING & ARB INFORMATION**:
> - Read through the instructions completely at least once before following them.
> - **Firmware & ARB**: Ensure your device is on the latest official **OOS 14 / OOS 15** stock firmware matching your region before flashing.
> - **Mandatory Copy-Partitions**: On this A/B device, the inactive slot can contain outdated firmware or empty partitions. You **MUST** sideload `copy-partitions-20220613-signed.zip` and reboot recovery before installing the ROM. Skipping this step can lead to a **hard brick**!
> - **FRP Lock**: Remove all Google accounts from your device before proceeding to avoid Factory Reset Protection (FRP) lock.
> - This process completely wipes internal storage. Backup all important data before starting.

---

## Required Downloads

Download the required files to your PC before beginning:

| File | Description | Download Link |
| :--- | :--- | :--- |
| **ROM & Partition Images** | Project Infinity-X 4.0 (Android 17) ROM zip, `boot.img`, `vendor_boot.img`, `dtbo.img` | [SourceForge Files Directory](https://sourceforge.net/projects/infinity-x-larry/files/) |
| **Copy Partitions** | Mandatory A/B Slot Sync Script (`copy-partitions-20220613-signed.zip`) | [GitHub Release Asset](https://github.com/imCrest/Infinityx-Release/releases/download/ARB-4.0/copy-partitions-20220613-signed.zip) / [Direct Raw](https://raw.githubusercontent.com/imCrest/Infinityx-Release/main/tools/copy-partitions-20220613-signed.zip) |

---

## Basic Requirements

1. **PC Platform Tools**: Ensure your PC has the latest ADB and Fastboot drivers installed.
2. **Stock OS Call/SMS Test**: Boot your device with stock OS at least once and verify that you can place/receive calls, SMS, and VoLTE/VoWiFi to provision IMS.
3. **USB Cable & Ports**: Use a reliable USB-A to USB-C cable connected directly to your motherboard port (avoid USB hubs).

---

## Step-by-Step Installation Guide

### Step 1: Enable USB Debugging & OEM Unlocking
1. Open **Settings -> About Device -> Version**.
2. Tap **Build Number** 7 times until Developer options are unlocked.
3. Navigate to **Settings -> Additional Settings -> Developer Options**.
4. Enable:
   - **OEM Unlocking**
   - **USB Debugging**

---

### Step 2: Boot into Fastboot (Bootloader) Mode
1. Connect your device to your PC via USB.
2. Open a terminal / command prompt and verify the connection:
   ```bash
   adb devices
   ```
3. Reboot to bootloader:
   ```bash
   adb -d reboot bootloader
   ```
   *(Hardware key combination: Power off device, then hold **Volume Up + Volume Down + Power**).*
4. Verify your PC detects fastboot mode:
   ```bash
   fastboot devices
   ```

---

### Step 3: Unlock the Bootloader
*(Skip if your bootloader is already unlocked).*

```bash
fastboot flashing unlock
```
- Follow the on-screen prompts on your phone using the Volume buttons to navigate and the Power button to confirm unlock.
- The device will perform a factory wipe and reboot. Once booted, re-enable **USB Debugging** and reboot back into bootloader mode (`adb -d reboot bootloader`).

---

### Step 4: Flash Required Partitions
In fastboot/bootloader mode, flash the downloaded partition images:

```bash
fastboot flash boot boot.img
fastboot flash dtbo dtbo.img
fastboot flash vendor_boot vendor_boot.img
```

> [!NOTE]
> On `larry`, recovery is contained inside the `vendor_boot` partition. Flashing `vendor_boot.img` installs the Project Infinity-X Recovery.

---

### Step 5: Boot into Recovery Mode
Reboot to recovery from fastboot:
```bash
fastboot reboot recovery
```
*(Or use the Volume keys on your phone to highlight **Recovery Mode** on the bootloader screen and press Power).*

---

### Step 6: Ensure Both Slots Are Consistent (Copy-Partitions)
To ensure the inactive slot has matching firmware and prevent hard-bricks:

1. In Recovery, select **Apply update -> Apply from ADB**.
2. On your computer, sideload `copy-partitions-20220613-signed.zip`:
   ```bash
   adb -d sideload copy-partitions-20220613-signed.zip
   ```
3. When prompted on screen with `Signature verification failed`, tap **Yes** *(expected for add-on scripts)*.
4. Once completed, tap **Advanced -> Reboot to recovery** to restart recovery.

---

### Step 7: Factory Reset / Format Data
Once back in recovery:

1. Select **Factory Reset -> Format data / factory reset**.
2. Confirm the format *(ignore any minor metadata warnings)*.
3. Return to the main menu.

---

### Step 8: Sideload Project Infinity-X ROM
1. On your phone, select **Apply update -> Apply from ADB**.
2. Sideload the Project Infinity-X ROM package from your PC:
   ```bash
   adb -d sideload Project_Infinity-X-4.0-larry-*-GAPPS-UNOFFICIAL.zip
   ```
   *(Replace with the actual filename of your downloaded ROM).*

> [!TIP]
> **Understanding ADB Sideload Output**:
> - Normally ADB reports `Total xfer: 1.00x`.
> - In many cases, the progress on PC may pause around **47%** and output `adb: failed to read command: Success` or `No error`. This is completely normal and indicates a successful transfer.
> - When installation completes, recovery may prompt: *"Reboot to recovery to flash add-ons?"*.
>   - Select **No** (GApps are already built-in).
>   - Select **Yes** only if you plan to flash root packages like Magisk/KernelSU.

---

### Step 9: Final Format Data & Reboot
1. Select **Factory Reset -> Format data / factory reset** one final time.
2. Select **Reboot system now**.

---

## Post-Installation & OTA Notes

- **Initial Boot Time**: First boot takes roughly 3 to 5 minutes while the system sets up encryption.
- **Seamless OTA Updates**: Automatic Over-The-Air updates are supported out-of-the-box. Future updates can be checked and installed via **Settings -> System -> Updater**.
- **Community & Support**: Join the official [OnePlus Nord CE 3 Lite / N30 Community](https://t.me/OnePlusNordCE3Lite) on Telegram for assistance.
