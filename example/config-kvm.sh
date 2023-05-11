#!/bin/bash
#

# setup root login
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# change root password
echo root:1qaz@WSX | chpasswd

# setup Number of file handles
tee -a /etc/security/limits.conf << EOF
#
# setup Number of file handles
* soft nofile 204800
* hard nofile 204800
* soft nproc 204800
* hard nproc 204800
EOF

# Enable serial console on Ubuntu
# GRUB_SERIAL_COMMAND="serial --speed=9600" or GRUB_SERIAL_COMMAND="serial --speed=9600 --unit=0 --word=8 --parity=no --stop=1"
sed -i 's/^#\?GRUB_TERMINAL=.*/GRUB_TERMINAL=serial/g' /etc/default/grub
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=""/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,9600"/g' /etc/default/grub
grep "GRUB_SERIAL_COMMAND" /etc/default/grub > /dev/null 2>&1 || sed -i '/GRUB_CMDLINE_LINUX=.*/a\GRUB_SERIAL_COMMAND="serial --speed=9600"' /etc/default/grub
#update grup
update-grub

sed -i 's/^#\?DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=3s/g' /etc/systemd/system.conf
sed -i 's/^#\?DefaultTimeoutStartSec=.*/DefaultTimeoutStartSec=3s/g' /etc/systemd/system.conf
systemctl daemon-reload

# get all nic name for operation system, configure the one of Nic name
nic_names=$(ls /sys/class/net/ | grep -v "`ls /sys/devices/virtual/net/`")

str_nic_name=$(echo ${nic_names} | tr ' ' '\n' | awk '{print length, $0}' | sort -n | cut -d" " -f2-)
new_nic_names=(${str_nic_name})

for ((i=0;i<=${#new_nic_names[*]};i++));do
  sed -i "s/eth${i}/${new_nic_names[${i}]}/g" /etc/netplan/00-installer-config.yaml
done

img_path="/var/lib/libvirt/images/"
img_file="ECV-8.3.3.5_86013.qcow2"
source_file=${img_path}${img_file}
mv /opt/service/img/${img_file} ${img_path}
chmod 755 ${source_file}

# Location of template file
template_file="/opt/template.xml"

# add images soure file
sed -i 's#source_file#'"${source_file}"'#g' ${template_file}

# add cpu number for template file
cpu_number=$(cat /proc/cpuinfo| grep "processor"| wc -l)
sed -i "s/cpu_num/${cpu_number}/g" ${template_file}

# add member size for template file
mem_total=$(grep MemTotal /proc/meminfo | awk  '{print $2}')
free_size=$((${mem_total}-638812))
sed -i "s/free_mem/${free_size}/g" ${template_file}

# add network interface card for template file
#nic_list=$(cat /proc/net/dev | awk '{i++; if(i>2){print $1}}' | sed 's/^[\t]*//g' | sed 's/[:]*$//g' | grep -v "lo" | sort -n | grep -v "macvtap")
# get all of the physical nic names
for ((i=0;i<${#new_nic_names[*]};i++));do
#  sed -i "s/eth${i}/${new_nic_names[${i}]}/g" /etc/netplan/00-installer-config.yaml
    nic_str_constant="nic_${i}_str"
  	# to change the mac address from template file
  	grep ${nic_str_constant}  ${template_file}
  	if [ $? -eq 0 ];then
  	    sed -i "s/${nic_str_constant}/br${i}/g" ${template_file}
  	else
  	    break
  	fi
done


# local binary file
mv /opt/service/bin/getsn  /usr/local/bin
chmod +x /usr/local/bin/getsn || true


#set allmulticast status for the macvtap
cat << 'eof' > /opt/allmulticast.sh
nic_list=$(ls /sys/class/net | grep  macvtap*)
new_nic_list=(${nic_list})
for i in ${new_nic_list[@]}; do
    ip link set dev ${i} allmulticast on
done
eof

#rm -rf /opt/service
