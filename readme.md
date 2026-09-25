# Project Infinity-X - Flashing Guide (OnePlus Nord CE 2 Lite / 3 Lite 5G / N30 - `larry`)

Official Flashing Guide and Partition Setup for **Project Infinity-X** on OnePlus Nord CE 2 Lite 5G / OnePlus Nord CE 3 Lite 5G / OnePlus Nord N30 5G (`larry`).

Supported Models: `CPH2467, CPH2465, CPH2513, CPH2515`

> [!CAUTION]
> **CRITICAL WARNING**:
> - Read the flashing steps carefully before proceeding.
> - From this build onwards, firmware is not pre-included and support for ARB users is restored.
> - You **MUST** flash the `copy-partitions` zip in recovery and reboot recovery before flashing the ROM. Failing to copy partitions across A/B slots can lead to a **hard brick**!
> - Remove all Google accounts from your device before proceeding to avoid Factory Reset Protection (FRP).
> - This process will wipe all user data. Take a complete backup of your files before starting.

---

## 📥 Downloads

| File | Description | Download Link |
| :--- | :--- | :--- |
| **Project Infinity-X ROM** | Android 15/16 QPR-2 Build | [Latest GitHub Releases](https://github.com/imCrest/Infinityx-Release/releases/latest) / [SourceForge Archive](https://sourceforge.net/projects/infinity-x-larry/files/) |
| **Copy Partitions** | A/B Slot Sync Tool | [Download (GitHub Release)](https://github.com/imCrest/Infinityx-Release/releases/download/ARB-4.0/copy-partitions-20220613-signed.zip) / [Download (Repo)](https://raw.githubusercontent.com/imCrest/Infinityx-Release/main/tools/copy-partitions-20220613-signed.zip) |
| **Boot Image** (`boot.img`) | Kernel & Ramdisk | [Download boot.img](https://github.com/imCrest/Infinityx-Release/releases/download/ARB-4.0/boot.img) |
| **Vendor Boot** (`vendor_boot.img`) | Recovery & Vendor Ramdisk | [Download vendor_boot.img](https://github.com/imCrest/Infinityx-Release/releases/download/ARB-4.0/vendor_boot.img) |
| **DTBO Image** (`dtbo.img`) | Device Tree Blob Overlay | [Download dtbo.img](https://github.com/imCrest/Infinityx-Release/releases/download/ARB-4.0/dtbo.img) |
| **Firmware Archive** | OOS14 / OOS15 Stock Firmware | [SourceForge Firmware](https://sourceforge.net/projects/infinity-x-larry/files/) |

---

## 📋 Requirements & Prerequisites

1. **Firmware Requirement**: Ensure your device is on the latest OOS14/OOS15 stock firmware according to your ARB status before continuing.
2. **Unlocked Bootloader**: An unlocked bootloader is mandatory.
3. **PC Tools**: Working ADB and Fastboot drivers installed on your PC.
4. **Files Ready**: Download all files above to your working folder on PC.

---

## 🚀 Step-by-Step Flashing Instructions

### Step 1: Enable Developer Options & USB Debugging
1. Open **Settings** ➔ **About Device** ➔ **Version**.
2. Tap **Build Number** 7 times until Developer Options are enabled.
3. Navigate to **Settings** ➔ **Additional Settings** ➔ **Developer Options**.
4. Enable:
   - **OEM Unlocking**
   - **USB Debugging**

### Step 2: Reboot to Bootloader Mode
Connect your device to your PC via USB and verify connection:
```bash
adb devices
```
Reboot to bootloader:
```bash
adb -d reboot bootloader
```

*(If your bootloader is locked, unlock it using `fastboot flashing unlock` and confirm on device).*

### Step 3: Flash Required Partition Images
In fastboot/bootloader mode, flash the downloaded partition images:
```bash
fastboot flash boot boot.img
fastboot flash dtbo dtbo.img
fastboot flash vendor_boot vendor_boot.img
```
*(Optional: If flashing vbmeta: `fastboot flash vbmeta vbmeta.img`)*

### Step 4: Reboot to Recovery
Reboot to recovery from bootloader mode:
```bash
fastboot reboot recovery
```
*(Or use Volume keys to highlight **Recovery Mode** and press the Power button).*

### Step 5: Sideload Copy-Partitions Zip (Crucial Step)
In Project Infinity-X Recovery:
1. Tap **Apply Update** ➔ **Apply from ADB**.
2. On your PC, sideload `copy-partitions-20220613-signed.zip`:
```bash
adb -d sideload copy-partitions-20220613-signed.zip
```
*(If signature verification prompt appears, tap **Yes** to continue).*

### Step 6: Reboot Recovery Again
After copy-partitions completes successfully:
1. Tap **Advanced** ➔ **Reboot to recovery**.
2. Wait for the phone to reboot back into recovery mode.

### Step 7: Format Data (Factory Reset)
In recovery:
1. Select **Factory Reset** ➔ **Format data / factory reset**.
2. Confirm the format *(ignore if recovery displays a minor metadata warning)*.

### Step 8: Sideload Project Infinity-X ROM
1. On your device, tap **Apply Update** ➔ **Apply from ADB**.
2. Connect device to PC and run:
```bash
adb -d sideload Project_Infinity-X-4.0-larry-*-GAPPS-UNOFFICIAL.zip
```
*(Replace with your actual ROM filename).*

### Step 9: Additional Packages (Optional)
- Once installation finishes, if recovery prompts to reboot to recovery to flash additional packages (e.g. Magisk or KernelSU), proceed accordingly.
- If not flashing additional packages, proceed to Step 10.

### Step 10: Final Format Data & Reboot
1. Select **Factory Reset** ➔ **Format data / factory reset** once again.
2. Select **Reboot to System**.

---

## 💡 Post-Installation & OTA Notes

* **First Boot**: First boot may take 3–5 minutes. Please be patient.
* **Built-in OTA Updates**: Over-The-Air updates are supported out-of-the-box. Subsequent updates can be installed seamlessly via **Settings ➔ System ➔ Updater**.
* **Support & Community**: Join the [OnePlus Nord CE 3 Lite / N30 Community](https://t.me/OnePlusNordCE3Lite) for queries and discussion.
