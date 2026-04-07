Project Infinity X (Unofficial) for OnePlus Nord CE 3 Lite 5G (larry)

Welcome to the unofficial build of Project Infinity X (Android 16 QPR-2) for the OnePlus Nord CE 3 Lite 5G (codenamed `larry`). 

Maintainer: SUJΛL (@imCrest)

---

## IMPORTANT WARNING

> [!WARNING]
> **DO NOT FLASH THIS ROM IF YOU ARE ON THE LATEST OOS FIRMWARES (1600 or 1301).**
>
> - These firmwares have triggered the ARB (Anti Roll Back) Fuse, which prevents downgrading.  
> - Flashing custom ROMs on these firmwares will result in a HARD BRICK.  
> - If you hard brick your device by ignoring this warning, it is your responsibility.  
> - As of February 2026, no free or unofficial method exists to recover from this ARB hard brick.  
> - Only an Official OnePlus Service Center can fix your device.  

---

## DOWNLOAD LINKS

We provide dual servers for fast and reliable downloads. All recovery images (boot.img, vendor_boot.img, dtbo.img) are available directly on our GitHub page.

- [Download via Server 1 (GitHub Releases)](https://github.com/imCrest/Infinityx-Release/releases)
- Server 2 (Pixeldrain): Mirror links are provided in our official Telegram channel release posts  

Note: This build is Non-ARB.

---

## FLASHING INSTRUCTIONS

Follow these steps carefully to ensure a smooth installation.

### PREREQUISITES

- Unlocked Bootloader  
- A PC/Laptop with ADB & Fastboot installed  
- Make sure you are NOT on OOS firmware 1600 or 1301  

---

### STEP 1 - DOWNLOAD FILES

Download the ROM .zip file (GApps or Vanilla), along with:
- boot.img  
- vendor_boot.img  
- dtbo.img  

---

### STEP 2 - BOOT TO FASTBOOT

- Power off your device  
- Hold Volume Down + Power Button  
- Connect your phone to PC  

---

### STEP 3 - FLASH IMAGES

```bash
fastboot flash boot boot.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash dtbo dtbo.img
```

---

### STEP 4 - ENTER RECOVERY

- Use volume buttons to navigate  
- Select Recovery Mode  
- Press power button to confirm  

---

### STEP 5 - FORMAT DATA

- Go to: Factory Reset → Format Data / Factory Reset  
- Confirm action  

This will wipe all internal storage. Backup your data first.

---

### STEP 6 - ADB SIDELOAD

- Go back to main menu  
- Select: Apply Update → Apply from ADB  

Then run on your PC:

```bash
adb sideload <drag_and_drop_ROM.zip_here>
```

---

### STEP 7 - REBOOT

- Once sideload reaches 47% or completes  
- Go back to main menu  
- Select Reboot System Now  

---

## FINISHED

Your device should now boot into Project Infinity X 🚀
