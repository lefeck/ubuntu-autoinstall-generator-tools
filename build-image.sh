#!/bin/bash
#

# usage of the command line tool
function menu(){
cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [h] [1] [2] [3] [4] [q]

💁 This script will create fully-automated Ubuntu release version 20 to 22 installation media.

Available options:
       h Get the current menu
       1 Build the base image
       2 Build image with installer
       3 Build image with installer and local services, esxi only
       4 Build image with installer and local services, only for kvm
       q Exit script
exit
EOF
}


read -p "please input your build images ID:" value
case $value in
    h)
    menu
    ;;
    1)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u example/user-data-simple.yml -n focal -d ubuntu-autoinstall-simple.iso
    ;;
    2)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u example/user-data-kvm-esxi.yml -n focal -p package-name.txt  -d ubuntu-autoinstall-pkgs.iso
    ;;
    3)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u  example/user-data-local-service.yml -n focal -p package-name.txt -c example/config-all.sh  \
              -j rc.local -s /root/service -d ubuntu-autoinstall-local-service.iso
    ;;
    4)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u example/user-data-kvm-esxi.yml -n focal -p package-name.txt -c example/config-kvm.sh \
          -j rc-kvm.local -t template/silver-peak-hardware-template.xml  -s /root/service -d ubuntu-autoinstall-silver-peak.iso -k 0
    ;;
    q)
    exit
    ;;
esac