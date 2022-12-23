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

    - mount --bind /cdrom /target/cdrom
    - chmod +x /target/cdrom/extra/script/install-pkgs.sh
    - curtin in-target --target=/target -- /cdrom/extra/script/install-pkgs.sh
    - umount /target/cdrom
    - rm -r /target/cdrom
    - mkdir -p /target/cdrom

        echo '#!/bin/bash' > ${script_file}
        echo "# The default installation package will be downloaded to /cdrom/extra/pkgs/ directory" >> ${script_file}
        echo "mkdir -p /target/extra/local-sources/package" >> ${script_file}
        echo "cp -r /cdrom/extra/pkgs/* /target/extra/local-sources/package/" >> ${script_file}
        echo "cp /target/extra/etc/apt/sources.list /target/extra/etc/apt/sources.list.bak" >> ${script_file}
        echo 'echo 'deb [trusted=yes] file:///extra/local-sources/packages/   ./' > /target/etc/apt/sources.list' >> ${script_file}
        echo 'apt-get update' >> ${script_file}

        for name in $read_file; do
          echo "apt-get install -y ${name}" >> ${script_file}
        done


                echo "mkdir -p /cdrom/extra/local-sources/package" >> ${script_file}


    - curtin in-target --target=/target -- cp -rp /cdrom/extra/pkgs/* /extra/local-sources/package/
    - curtin in-target --target=/target -- cp /cdrom/etc/apt/sources.list /cdrom/etc/apt/sources.list.bak
    - curtin in-target --target=/target -- echo 'deb [trusted=yes] file:///extra/local-sources/packages/   ./' > /cdrom/etc/apt/sources.list

            echo "cp -r /cdrom/extra/pkgs/* /cdrom/extra/local-sources/package/" >> ${script_file}
            echo "cp /cdrom/etc/apt/sources.list /cdrom/etc/apt/sources.list.bak" >> ${script_file}
            echo 'echo 'deb [trusted=yes] file:///extra/local-sources/packages/   ./' > /cdrom/etc/apt/sources.list' >> ${script_file}
    late-commands:
        - mkdir -p /target/cdrom
        - cp -rp /cdrom/extra /target/cdrom
        - chmod +x /target/cdrom/extra/script/install-pkgs.sh
        - curtin in-target --target=/target -- /cdrom/extra/script/install-pkgs.sh
        - cp /cdrom/extra/wsaiso/wsa.service /target/lib/systemd/system
        - curtin in-target --target=/target -- ln -sn /lib/systemd/system/wsa.service /etc/systemd/system/wsa.service
        - systemctl daemon-reload
        - cp /cdrom/rc-local.service /target/lib/systemd/system/rc-local.service
        - curtin in-target --target=/target -- ln -s /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service
        - cp -p /cdrom/rc.local /target/etc/rc.local
        - chmod +x /target/etc/rc.local
        - systemctl daemon-reload
        - cp -rp /cdrom/extra/wsaiso /target/opt


#    - mkdir -p /target/extra
#    - cp -rp /cdrom/extra/* /target/extra
#    - chmod +x /target/extra/script/install-pkgs.sh
#    - curtin in-target --target=/target -- /extra/script/install-pkgs.sh >> /extra/log.txt
#    - cp /cdrom/extra/wsaiso/wsa.service /target/lib/systemd/system
#    - curtin in-target --target=/target -- ln -sn /lib/systemd/system/wsa.service /etc/systemd/system/wsa.service
#    - systemctl daemon-reload
#    - cp /cdrom/rc-local.service /target/lib/systemd/system/rc-local.service
#    - curtin in-target --target=/target -- ln -s /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service
#    - cp -p /cdrom/rc.local /target/etc/rc.local
#    - chmod +x /target/etc/rc.local
#    - systemctl daemon-reload
#    - cp -rp /cdrom/extra/wsaiso /target/opt


    - cp -rp /cdrom/extra/wsaiso /target/opt
    - cp /cdrom/extra/wsaiso/wsa.service /target/lib/systemd/system
    - curtin in-target --target=/target -- ln -sn /lib/systemd/system/wsa.service /etc/systemd/system/wsa.service
    - systemctl daemon-reload
    - cp /cdrom/rc-local.service /target/lib/systemd/system/rc-local.service
    - curtin in-target --target=/target -- ln -s /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service
    - cp -p /cdrom/rc.local /target/etc/rc.local
    - chmod +x /target/etc/rc.local
    - systemctl daemon-reload