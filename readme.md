# 🚀 Project Infinity X – Safe Build (ARB)

## ⚠️ IMPORTANT INFO

> **WARNING**: Please read carefully before flashing
> - ✅ No ARB issues
> - ✅ No hard brick risk
> - ✅ Safe to flash

---

## 📥 DOWNLOAD

All files available at: **[Latest Release](https://github.com/imCrest/Infinityx-Release/releases/latest)**

Download the following from the release page:
- GApps Build (ROM package)
- boot.img
- vendor_boot.img
- dtbo.img

---

## ✅ PREREQUISITES

- Unlocked bootloader
- ADB & Fastboot installed
- USB drivers for your device
- All required files downloaded
- USB cable
- Backup of important data

---

## 🔧 FLASHING STEPS

**Step 1:** Download all files from release page

**Step 2:** Boot to fastboot mode
```bash
adb reboot fastboot
```

**Step 3:** Flash images
```bash
fastboot flash boot boot.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash dtbo dtbo.img
```

**Step 4:** Reboot to recovery
```bash
fastboot reboot recovery
```

**Step 5:** Format data in recovery menu

**Step 6:** ADB sideload ROM
```bash
adb sideload infinityx_rom.zip
```

**Step 7:** Reboot system
```bash
fastboot reboot
```

---

## 📝 NOTES

- No ARB risk - safe build
- Always backup before flashing
- First boot takes longer
- Flash at your own risk
