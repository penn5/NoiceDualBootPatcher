import subprocess, os, hashlib, gzip, tempfile, errno, re, shutil
def extractboot():

    tags = subprocess.check_output(['./unpackbootimg', '-i', './boot.img']).split(b'\n')[:-1]
    tags = {z.split(b' ')[0].replace(b'BOARD_',b'').replace(b'PAGE_SIZE', b'PAGESIZE').replace(b'HASH_TYPE', b'HASH').replace(b'KERNEL_CMDLINE', b'CMDLINE').replace(b'KERNEL_BASE', b'BASE').lower():z.split(b' ')[1] for z in tags}
    return tags
def repackboot(tags, ramdisk='./boot.img-ramdisk.gz', verify=False):
    try:
        os.remove('./boot.img-repack')
    except OSError as e:
        if e.errno != errno.ENOENT:
            raise
        else:
            print('not removing file')
    command = [b'./mkbootimg', b'--kernel', b'./boot.img-zImage', b'--ramdisk', ramdisk.encode('utf-8')]
    for tag_name,tag_value in tags.items():
        if tag_name != b'name':
            command += [b'--'+tag_name, tag_value]
    if os.path.isfile(b'./boot.img-dtb'):
        command += [b'--dt', b'./boot.img-dtb']
    command += [b'--output', b'./boot.img-repack']
    subprocess.check_call(command)
    print(ramdisk)
    f=open('./boot.img-repack', 'ab')
    f.seek(0,2)
    s = f.tell()
    ns = os.path.getsize('./boot.img')
    c0unt = 0
    if ns < s:
        print('WARNING: New boot.img is larger than original, despite no changes being made.\nTo exit, press enter. To continue, press any key followed by enter.')
        if input() == '':
            exit()
    elif ns == s:
        print('OOPS: You had no avb footer anyway')
    else:
        while f.tell() < ns:
            c0unt=ns-f.tell()
            f.write(b'\0'*c0unt)
            print(ns)
            print(f.tell())
            print(f.name)
        print('NOTE: Output padded with {} nuls'.format(c0unt))
        f.close()
    if verify == True:
        f=open('./boot.img-repack', 'rb')

        m=hashlib.md5()
        f.seek(0,0)
        x = f.read(512)
        while len(x) > 0:
            x = f.read(512)
            m.update(x)


        print(m.digest())

        a = m.digest()

        f.close()

        f=open('./boot.img', 'rb')

        m=hashlib.md5()
        f.seek(0,0)
        x = f.read(512)
        while len(x) > 0:
            x = f.read(512)
            m.update(x)
        print(m.digest())

        if m.digest() != a:
            print('ERROR: The md5\'s don\'t match')
            exit()
        else:
            print('NOTE: The md5\'s match')
        f.close()
def extractramdisk():

    with gzip.open('./boot.img-ramdisk.gz', 'rb') as ramdiskgz:
        ramdiskcpio = ramdiskgz.read() #Really, this should be chunked. But who has a 5gb ramdisk?
    f = tempfile.TemporaryFile()
    f.write(ramdiskcpio)
    f.seek(0,0)

    os.makedirs('./ramdisk', exist_ok=True)
    subprocess.check_output([b'cpio', b'-idmu', b'--no-absolute-filenames'], cwd='./ramdisk', stdin=f)
    f.close()

def repackramdisk():
    """Due to a dodgy cpio thing, the md5 won't match here."""
    new = subprocess.check_output([b'./gen_initramfs_list.sh', b'./ramdisk'])

    f2 = tempfile.NamedTemporaryFile(delete=False)
    f2.write(new)
    f2.flush()
    f2p = f2.name
    f2.close()

    new = subprocess.check_output([b'./gen_init_cpio', f2p])

    f = gzip.open('./boot.img-ramdisk.gz-repack', 'wb')
    f.write(new)
    f.close()


tags = extractboot()
repackboot(tags, verify=True)
extractramdisk()
#----------------------------------
# Functions that aren't relevant to repacking and unpacking the boot.img


def patch():
    shutil.copyfile('./new_ramdisk/mounts.a.sh', './ramdisk/mounts.a.sh')
    os.chmod('./ramdisk/mounts.a.sh', 0o750)
    shutil.copyfile('./new_ramdisk/mounts.b.sh', './ramdisk/mounts.b.sh')
    os.chmod('./ramdisk/mounts.b.sh', 0o750)
    shutil.copyfile('./new_ramdisk/mounts.nontreble.sh', './ramdisk/mounts.nontreble.sh')
    os.chmod('./ramdisk/mounts.nontreble.sh', 0o750)
    shutil.copyfile('./new_ramdisk/mounts.postdata.sh', './ramdisk/mounts.postdata.sh')
    os.chmod('./ramdisk/mounts.postdata.sh', 0o750)
    initrc = open('./ramdisk/init.rc', 'rb').read()
    repl="""

service mounts_a /mounts.a.sh
    oneshot
    seclabel u:r:init:s0
    user root
    group root

service mounts_b /mounts.b.sh
    oneshot
    seclabel u:r:init:s0
    user root
    group root

service mounts_nontreble /mounts.nontreble.sh
    oneshot
    seclabel u:r:init:s0
    user root
    group root

service mounts_postdata /mounts.postdata.sh
    oneshot
    seclabel u:r:init:s0
    user root
    group root

on early-init
    rm /splash2/mounts.sh.start
    mkdir /dev/mounts
    exec_start mounts_nontreble
    exec_start mounts_a
    exec_start mounts_b"""
    newinitrc, repls = re.subn(r'^on early-init$', repl, initrc.decode('utf-8'), flags=re.MULTILINE)
    print(repls)
    print(newinitrc)
    if repls != 1:
        print('ERROR: 1PATCHING INIT.RC FAILED BECAUSE THE REGEX DIDN\'T MATCH')
        exit()
    newinitrc, repls = re.subn(r'^on post-fs-data$', """on post-fs-data
    wait /dev/mounts/active
    exec_start mounts_postdata""", newinitrc, flags=re.MULTILINE)
    if repls != 1:
        print('ERROR: 2PATCHING INIT.RC FAILED BECAUSE THE REGEX DIDN\'T MATCH')
        exit()
    f = open('./ramdisk/init.rc', 'wb')
    f.write(newinitrc.encode('utf-8'))

#----------------------------------

patch()

repackramdisk()

repackboot(tags, ramdisk='./boot.img-ramdisk.gz-repack', verify=False)

print('SUCCESS')



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
