#!/bin/sh

export PATH=$PATH:/bin:/system/bin:/system/a/bin:/system/b/bin

#Right now we are running in the system_a interpreter.
#Next, we check which volume key is pressed first
echo MOUNTS.NONTREBLE The system has a valid /bin/sh >> /dev/mounts/nontreble
mount | grep /system
if [ $? -eq 1 ]
then
    echo MOUNTS.NONTREBLE The system is already mounted >> /dev/mounts/nontreble
    exit
else
    echo MOUNTS.NONTREBLE The system is not mounted >> /dev/mounts/nontreble
fi
mount /system
if [ $? -eq 0 ]
then
    echo MOUNTS.NONTREBLE The system has been mounted... nontreble done! >> /dev/mounts/nontreble
else
    echo MOUNTS.NONTREBLE Error mounting system... Retrying with defaults >> /dev/mounts/nontreble
    mount -t auto -o defaults,ro /dev/block/platform/soc/$(getprop ro.boot.bootdevice) /system
    if [ $? -eq 0 ]
    then
        echo MOUNTS.NONTREBLE Success with the default opts mount. Done. >> /dev/mounts/nontreble
    else
        echo MOUNTS.NONTREBLE Failed even with the special default mount >> /dev/mounts/nontreble
        echo MOUNTS.NONTREBLE Giving up. >> /dev/mounts/nontreble
    fi
fi
exit




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
