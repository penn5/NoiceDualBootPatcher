# DualBootPatcher
 
### This is a collection of scripts that will patch your ramdisk (part of the kernel) to allow you do dualboot your Android phone.

## Working
- It boots and works correctly on my Project Treble phone on both Oreo and Pie
- You can install magisk over the patched ramdisk, and it works.
- Android works and no noticable bugs are created

## Known Bugs
- Bluetooth pairings are lost every time you switch data (Needs Confirmation)
- On some weird devices (that don't conform to google specs) there is a risk that the boot.img requires AVB to work. This is also the case on Huawei's patch01 if I understand correctly. Currently, the system will simply pad the AVB field with nulls. This means that the checksum will fail if your device has a non-null AVB field (aka stock, unpatched boot.img). This will be fixed in a later release, as it will fail the checksum check. 

## Usage
0. Get the file containing your ramdisk from the phone or stock rom and put it in this folder with the name `boot.img`
1. Clone this repo
2. `make`
3. Run as either `fakeroot` (unsupported) or root (either `sudo` or `su`): `python3 main.py`
4. The output will be generated in `boot.img-repack`
5. Copy this file to the phone and flash it to the same partition it came from. Various checks are conducted to ensure it won't brick the phone.
6. Wipe data and cache in TWRP
7. Reboot!

## Getting Logs
- If it is booting, get /dev/mounts - this is a tmpfs with all the logs in
- If it isn't booting, send the `ramdisk` folder relative to this file.
