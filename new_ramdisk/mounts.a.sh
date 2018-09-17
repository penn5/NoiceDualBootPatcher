#!/system/a/bin/sh

export PATH=$PATH:/system/a/bin:/system/b/bin #This means that we can use the binaries to do stuff.

#Right now we are running in the system_a interpreter.
#Next, we check which volume key is pressed first
echo MOUNTS.A a >> /dev/mounts/a

geteventout=$(getevent -c1 /dev/input/event0)


echo $geteventout | grep 72
isa=$?
echo $geteventout | grep 73
isb=$?
echo $(mount) >> /dev/mounts/a
if [ $isa -eq 1 ]
then
echo MOUNTS.A >> /dev/mounts/a
echo MOUNTS.A Booting System A >> /dev/mounts/a
echo a > /dev/mounts/active
mount -o bind /system/a /system
exit 0
fi
if [ $isb -eq 1 ]
then
echo MOUNTS.A >> /dev/mounts/a
echo MOUNTS.A Booting System B >> /dev/mounts/a
echo b > /dev/mounts/active
mount -o bind /system/b /system #There will not be an error here because we aren't acutally deleting /system/a, just hiding it's directory structure. All normal stuff can happen now.
exit 0
fi


#Some notes

## There's a backup version of this script in mounts.b.sh which has the interpreter set to system_b's sh executable. This is so that even if system_a is corrupt, you can boot system_b. This means that this script needs to have some way to tell the other script that it worked, so that we don't wait for the volume keys twice. A simple way to do this is to check the status of /system for a bind-mount, but we won't do this. Instead we will use /splash2 as a temporary directory to store the status of the bootstrapper.




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
