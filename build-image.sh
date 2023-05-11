#!/bin/bash
#

# usage of the command line tool
function menu(){
cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [h] [1] [2] [3] [4] [q]

💁 This script will create fully-automated Ubuntu release version 20 to 22 installation media.

Available options:
       p Get the current menu
       s Build the base image
       n Build image with installer
       a Build image with installer and local services, esxi only
       ke Build image with installer and local services, only in the esxi for kvm
       khs Build image with installer and local services, only in the hardware for kvm, block device is standard.
       khn Build image with installer and local services, only in the hardware for kvm, block device is nvme.
       q Exit script
EOF
}
menu

read -p "please input your build images ID: " value
case $value in
    p)
    menu
    exit
    ;;
    s)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u example/user-data-simple.yml -n jammy -d ubuntu22-autoinstall-simple.iso
    ;;
    n)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u example/user-data-kvm-esxi.yml -n jammy -p package-name.txt  -d ubuntu-autoinstall-pkgs.iso
    ;;
    a)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u  example/user-data-local-service.yml -n jammy -p package-name.txt -c example/config-all.sh  \
              -j rc.local -s /root/service -d ubuntu-autoinstall-local-service.iso
    ;;
    ke)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u example/user-data-kvm-esxi.yml -n jammy -p package-name.txt -c example/config-kvm.sh \
          -j rc-kvm.local -t template/silver-peak-template.xml  -s /root/service -d ubuntu-autoinstall-silver-peak.iso -k 0
    ;;
    khs)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u example/user-data-kvm-standard-hardware.yml -n jammy -p package-name.txt -c example/config-kvm.sh \
            -j rc-kvm.local -t template/silver-peak-template.xml  -s /root/service -d ubuntu22-silverpeak-standard.iso -k 0
      ;;
    khn)
    bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u example/user-data-kvm-nvme-hardware.yml -n jammy -p package-name.txt -c example/config-kvm.sh \
            -j rc-kvm.local -t template/silver-peak-template.xml  -s /root/service -d ubuntu22-silverpeak-nvme.iso -k 0
      ;;
    q)
    exit
    ;;
esac