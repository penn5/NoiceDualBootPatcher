#!/system/b/bin/sh

export PATH=$PATH:/system/b/bin:/system/a/bin #This means that we can use the binaries to do stuff.

#Right now we are running in the system_a interpreter.
#Next, we check which volume key is pressed first
echo MOUNTS.B Starting mounts.b.sh >> /dev/mounts/b
echo MOUNTS.B Checking for A success?
if [ -f /dev/mounts/b ]
then
    echo MOUNTS.B Found file... This indicates bootstrap succeeded. Performing final checks...
    echo MOUNTS.B And yet... if the real /system is mounted, this script wouldn't be able to run, as the interpreter here is set to use B. So we rerun the mounting and detection code.
else
    echo MOUNTS.B A_script didn't start.
fi
geteventout=$(getevent -c1 /dev/input/event0)
echo $geteventout | grep 72
isa=$?
echo $geteventout | grep 73
isb=$?
if [ $isa -eq 1 ]
then
echo MOUNTS.B >> /dev/mounts/b
echo MOUNTS.B Booting System A >> /dev/mounts/b
echo a > /dev/mounts/active
mount -o bind /system/a /system
exit 0
fi
if [ $isb -eq 1 ]
then
echo MOUNTS.B >> /dev/mounts/b
echo MOUNTS.B Booting System B >> /dev/mounts/b
echo b > /dev/mounts/active
mount -o bind /system/b /system #There will not be an error here because we aren't acutally deleting /system/a, just hiding it's directory structure. All normal stuff can happen now.
exit 0
fi


#Some notes

## There's a backup version of this script in mounts.b.sh which has the interpreter set to system_b's sh executable. This is so that even if system_a is corrupt, you can boot system_b. This means that this script needs to have some way to tell the other script that it worked, so that we don't wait for the volume keys twice. A simple way to do this is to check the status of /system for a bind-mount, but we won't do this. Instead we will use /splash2 as a temporary directory to store the status of the bootstrapper. This script is not set to required in the init.rc, so as to prevent dual-boot functioning on a 'normal' (single-boot) system partition. If there's no /system/a or /system/b both of the scripts will fail due to missing interpreters.
### This script is said backup, the notes are copied from the normal mounts.sh











#  This file is part of DualBootPatcher, copyright Penn Mackintosh.
#
#    DualBootPatcher is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    DualBootPatcher is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with DualBootPatcher.  If not, see <https://www.gnu.org/licenses/>.
