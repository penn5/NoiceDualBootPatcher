# NoiceDualBootPatcher
 
### This is a collection of scripts that will patch your ramdisk (part of the kernel) to allow you do dualboot your Android phone.

## Working
- It boots and works correctly on my Project Treble phone on both Oreo and Pie
- You can install magisk over the patched ramdisk, and it works.
- Android works and no noticable bugs are created

## Known Bugs
- Bluetooth pairings are lost every time you switch data (Needs Confirmation)
- On some weird devices (that don't conform to google specs) there is a risk that the boot.img requires AVB to work. This is also the case on Huawei's patch01 if I understand correctly. Currently, the system will simply pad the AVB field with nulls. This means that the checksum will fail if your device has a non-null AVB field (aka stock, unpatched boot.img). This will be fixed in a later release, as it will fail the checksum check. 

## Usage
0. Clone this repo
1. Get the file containing your ramdisk from the phone or stock rom and put it in this folder with the name `boot.img`
2. `make`
3. Run as either `fakeroot` (unsupported) or root (either `sudo` or `su`): `python3 main.py`
4. The output will be generated in `boot.img-repack`
5. Copy this file to the phone and flash it to the same partition it came from. Various checks are conducted to ensure it won't brick the phone.
6. Wipe data and cache in TWRP
7. Reboot!

## Installing a dual system
0. Download the zip file for the system
1. Extract it.
2. If there are any .br files, extract them too (brotli)
3. Use https://github.com/xpirt/sdat2img to covert it to a system.img
4. Send this system.img to the phone
5. Enter the twrp shell (Advanced --> Terminal) and run (replacing paths with the correct ones) `rm -rf /mnt/tmp;mkdir /mnt/tmp;mount -o loop -t auto /path/to/system.img /mnt/tmp`
6. Exit the twrp shell and enter File Manager
7. Navigate to /mnt/tmp
8. Click the blue folder icon in the bottom right corner.
9. Select 'Copy'
10.Navigate to /system/(a|b) (make the folder if it doesn't exist)
11.Click the blue folder icon again and paste the files. This will take a while.
12.Reboot System!
N.B. I will make a wrapper for this soonish - Done - https://github.com/penn5/DualBootInstaller

## Getting Logs
- If it is booting, get /dev/mounts - this is a tmpfs with all the logs in
- If it isn't booting, send the `ramdisk` folder relative to this file.
