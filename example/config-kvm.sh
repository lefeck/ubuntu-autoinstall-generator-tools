#!/bin/bash
#

# setup root login
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo "MsTac@2001" | passwd  root --stdin > /dev/null 2>&1
# configure the Nic name
Nic_Name=`cat /proc/net/dev | awk '{i++; if(i>2){print $1}}' | sed 's/^[\t]*//g' | sed 's/[:]*$//g' | grep -v "lo"  | head -n 1`
sed -i "s/    ens136/    ${Nic_Name}/g" /etc/netplan/00-installer-config.yaml

# setup Number of file handles
tee -a /etc/security/limits.conf << EOF

# setup Number of file handles
* soft nofile 204800
* hard nofile 204800
* soft nproc 204800
* hard nproc 204800
EOF

# Enable serial console on Ubuntu
# GRUB_SERIAL_COMMAND="serial --speed=9600" or GRUB_SERIAL_COMMAND="serial --speed=9600 --unit=0 --word=8 --parity=no --stop=1"
sed -i 's/^#\?GRUB_TERMINAL=.*/GRUB_TERMINAL=serial/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,9600"/g' /etc/default/grub
grep "GRUB_SERIAL_COMMAND" /etc/default/grub > /dev/null 2>&1 || sed -i '/GRUB_CMDLINE_LINUX=.*/a\GRUB_SERIAL_COMMAND="serial --speed=9600"' /etc/default/grub
#update grup
update-grub

# Location of template file
template_file="/root/sliver-peak.xml"
echo "Generate mac address and cpu model"
for((i=1;i<=3;i++)); do
        # Generate mac address
        mac=$(echo $RANDOM|md5sum|sed 's/../:&/g'|cut -c 1-15)
        quotes="'"
        constant="00"
        mac_str=${quotes}${constant}${mac}${quotes}
        mac_str_constant=$(echo mac_str${i})
        # to change the mac address from template file
        sed -i "s/${mac_str_constant}/${mac_str}/g" ${template_file}
done

# get the cpu model of the physical machine
cpu_string=$(virsh  capabilities | grep "<model>" | head -n 1)
cpu_sub_string=$(echo ${cpu_string%<*})
cpu_mid_string=$(echo ${cpu_sub_string##*>})
echo $cpu_mid_string

# to change the cpu model from template file
sed -i "s/${cpu_str}/${cpu_mid_string}/g" ${template_file}

img="ECV-8.3.3.5_86013.qcow2"
cp -rp /opt/service/img/${img} /var/lib/libvirt/images/
cp -rp /opt/service/bin/getsn  /usr/local/bin
chmod +x /usr/local/bin/getsn || true