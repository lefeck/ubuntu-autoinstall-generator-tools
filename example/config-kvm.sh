#!/bin/bash
#

# setup root login
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# change root password
echo root:1qaz@WSX | chpasswd

# setup Number of file handles
tee -a /etc/security/limits.conf <<EOF
#
# setup Number of file handles
* soft nofile 204800
* hard nofile 204800
* soft nproc 204800
* hard nproc 204800
EOF

# get os release name
os_debain_release_name=$(cat /etc/os-release | grep -w NAME | awk -F'=' '{print $2}' | sed 's/\"//g')
os_debain_release_version=$(cat /etc/os-release | grep -w VERSION_ID | awk -F'=' '{print $2}' | sed 's/\"//g' | awk -F'.' '{print $1}')
latest_os_debain_release=${os_debain_release_name}-${os_debain_release_version}

if [ "${latest_os_debain_release}" == "Ubuntu-20" ]; then
    sed -i 's/^#\?GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/g' /etc/default/grub
    sed -ie '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
fi

# Enable serial console on Ubuntu
sed -i 's/^#\?GRUB_TERMINAL=.*/GRUB_TERMINAL=serial/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=""/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,9600"/g' /etc/default/grub
grep "GRUB_SERIAL_COMMAND" /etc/default/grub >/dev/null 2>&1 || sed -i '/GRUB_CMDLINE_LINUX=.*/a\GRUB_SERIAL_COMMAND="serial --speed=9600"' /etc/default/grub
#update grup
update-grub

# get all nic name for operation system, configure the one of Nic name
nic_names=$(ls /sys/class/net/ | grep -v "$(ls /sys/devices/virtual/net/)")

str_nic_name=$(echo ${nic_names} | tr ' ' '\n' | awk '{print length, $0}' | sort -n | cut -d" " -f2-)
new_nic_names=(${str_nic_name})

for ((i = 0; i <= ${#new_nic_names[*]}; i++)); do
	sed -i "s/eth${i}/${new_nic_names[${i}]}/g" /etc/netplan/00-installer-config.yaml
done

# move qcow2 image to specfiy the dirctory
img_path="/var/lib/libvirt/images/"
qcow2_file=$(find /opt/service/img/ -type f -name *.qcow2)
img_file=${qcow2_file##*/}
source_file=${img_path}${img_file}
mv /opt/service/img/${img_file} ${img_path}
chmod 755 ${source_file}

# Location of template file
template_file="/opt/template.xml"

# add images soure file
sed -i 's#source_file#'"${source_file}"'#g' ${template_file}

# add cpu number for template file
cpu_number=$(cat /proc/cpuinfo | grep "processor" | wc -l)
sed -i "s/cpu_num/${cpu_number}/g" ${template_file}

# add member size for template file
mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
free_size=$((${mem_total} - 638812))
sed -i "s/free_mem/${free_size}/g" ${template_file}

function ubuntu20_nic_mapping() {
	# add network interface card for template file
	# get all of the physical nic names
	for ((i = 0; i < ${#new_nic_names[*]}; i++)); do
		#  sed -i "s/eth${i}/${new_nic_names[${i}]}/g" /etc/netplan/00-installer-config.yaml
		nic_str_constant="nic_${i}_str"
		# to change the mac address from template file
		grep ${nic_str_constant} ${template_file}
		if [ $? -eq 0 ]; then
			sed -i "s/${nic_str_constant}/${new_nic_names[${i}]}/g" ${template_file}
		else
			break
		fi
	done
}

function ubuntu22_nic_mapping() {
	# add network interface card for template file
	# get all of the physical nic names
	for ((i = 0; i < ${#new_nic_names[*]}; i++)); do
		#  sed -i "s/eth${i}/${new_nic_names[${i}]}/g" /etc/netplan/00-installer-config.yaml
		nic_str_constant="nic_${i}_str"
		# to change the mac address from template file
		grep ${nic_str_constant} ${template_file}
		if [ $? -eq 0 ]; then
			sed -i "s/${nic_str_constant}/br${i}/g" ${template_file}
		else
			break
		fi
	done
}

if [ "${latest_os_debain_release}" == "Ubuntu-20" ]; then
	ubuntu20_nic_mapping
else
	ubuntu22_nic_mapping
fi

# local binary file
mv /opt/service/bin/getsn /usr/local/bin
chmod +x /usr/local/bin/getsn || true

#set allmulticast status for the macvtap
cat <<'eof' >/opt/allmulticast.sh
nic_list=$(ls /sys/class/net | grep  macvtap*)
new_nic_list=(${nic_list})
for i in ${new_nic_list[@]}; do
    ip link set dev ${i} allmulticast on
done
eof

# cleanup temporary files
rm -rf /opt/service
