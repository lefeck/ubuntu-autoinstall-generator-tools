#!/bin/bash
#

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# usage of the command line tool
function menu(){
cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [1] [2] [3] [4]

💁 This script will create fully-automated Ubuntu release version 20 to 22 installation media.

Available options:
    h   获取当前菜单
    1   构建基础镜像
    2   构建带有安装包的镜像
    3   构建带有安装包及本地服务的镜像，仅支持esxi
    4   构建带有安装包及本地服务的镜像，仅用于kvm
    q   退出脚本
EOF
exit
}
menu

while true; do
read -p "请输入你要构建镜像的编号:" value
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
done
