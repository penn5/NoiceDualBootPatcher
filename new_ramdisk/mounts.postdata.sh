#!/system/bin/sh
# the above interpreter should exist by now...

echo MOUNTS.POSTDATA > /dev/mounts/postdata
echo $(mount) >> /dev/mounts/postdata
# in the initscript we await for /dev/mounts/active, so we can be sure that it exists and contains either 'a' or 'b'
echo mount -o bind /data/$(cat /dev/mounts/active) /data >> /dev/mounts/postdata
echo NOW RUNNING >> /dev/mounts/postdata
mount -o bind /data/$(cat /dev/mounts/active) /data >> /dev/mounts/postdata
echo $? >> /dev/mounts/postdata
echo YAY... it ran! >> /dev/mounts/postdata

#It'd be good to log stuff into a pstore, but i cant work out how... any PR is appreciated.




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
