#!/bin/bash

创建文件夹并下载依赖包:
mkdir -p /extra/local-sources/package
chmod +x /extra/local-sources/package
cd /extra/local-sources/package
line=samba
root@test:/extra/local-sources/packages# apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances \
         --no-pre-depends ${line} | grep -v i386 | grep "^\w") &>/dev/null

创建本地软件源的index文件:
dpkg-scanpackages ./  &>/dev/null  | gzip -9c > Packages.gz
apt-ftparchive packages ./ > Packages
apt-ftparchive release ./ > Release

cp /etc/apt/sources.list /etc/apt/sources.list.bak
cat << eof > /etc/apt/sources.list
deb [trusted=yes] file:///extra/local-sources/packages/   ./
eof

apt-get update

bash -x ubuntu-autoinstall-generator-tools.sh -a  -u user-data.yml -n  jammy  -p -f file-name.txt -o -t rc.local  -x  -s /root/tmp/  -d ubuntu-autoinstall-jammy.iso

            echo "cp -r /cdrom/extra/pkgs/* /cdrom/extra/local-sources/package/" >> ${script_file}
            echo "cp /cdrom/etc/apt/sources.list /cdrom/etc/apt/sources.list.bak" >> ${script_file}
            echo 'echo 'deb [trusted=yes] file:///extra/local-sources/packages/   ./' > /cdrom/etc/apt/sources.list' >> ${script_file}
    late-commands:


        - cp -rp /cdrom/mnt/wsaiso /target/opt
        - cp /cdrom/mnt/wsaiso/wsa.service /target/lib/systemd/system
        - curtin in-target --target=/target -- ln -sn /lib/systemd/system/wsa.service /etc/systemd/system/wsa.service
        - systemctl daemon-reload


all whole

    - cp -rp /cdrom/mnt /target/
    - chmod +x /target/mnt/script/install-pkgs.sh
    - chmod +x /target/mnt/script/config.sh
    - curtin in-target --target=/target -- /mnt/script/install-pkgs.sh
#    - curtin in-target --target=/target -- /mnt/script/config.sh
    - curtin in-target --target=/target -- cp /mnt/template.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
    - cp /cdrom/rc-local.service /target/lib/systemd/system/rc-local.service
    - curtin in-target --target=/target -- ln -s /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service
    - cp -p /cdrom/rc.local /target/etc/rc.local
    - chmod +x /target/etc/rc.local
    - systemctl daemon-reload
    - cp -rp /cdrom/mnt/wsa /target/opt
    - cp /cdrom/mnt/wsa/wsa.service /target/lib/systemd/system
    - curtin in-target --target=/target -- ln -sn /lib/systemd/system/wsa.service /etc/systemd/system/wsa.service
    - systemctl daemon-reload