#!/bin/bash
#

# setup root login
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# change root password
echo root:test123 | chpasswd

# get all nic name for operation system, configure the one of Nic name
function get_first_nic_name() {
#!/bin/bash
nic_names=$(cat /proc/net/dev | awk '{i++; if(i>2){print $1}}' | sed 's/^[\t]*//g' | sed 's/[:]*$//g' | grep -v "lo" | grep -v "macvtap")

new_nic_names=()
short_nic=${nic_names[0]}
for i in ${nic_names[*]};do
    if [ ${#short_nic} -ge  ${#i} ]; then
        short_nic=${i}
    else
        continue
    fi
done

for i in ${nic_names[*]};do
    if [ ${#short_nic} -eq  ${#i} ];then
        new_nic_names[${#new_nic_names[*]}]=${i}
    else
        continue
    fi
done

nic_sort_names=$(echo ${new_nic_names[*]} | tr ' ' '\n' | sort -n)
echo ${nic_sort_names} | tr -s "\r\n" " "
 > /dev/null
nic_name=$(echo ${nic_sort_names} | awk '{print $1}')
echo $nic_name
sed -i "s/    ens136/    ${nic_name}/g" /etc/netplan/00-installer-config.yaml
}

get_first_nic_name

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
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,9600"/g' /etc/default/grub
grep "GRUB_SERIAL_COMMAND" /etc/default/grub > /dev/null 2>&1 || sed -i '/GRUB_CMDLINE_LINUX=.*/a\GRUB_SERIAL_COMMAND="serial --speed=9600"' /etc/default/grub
#update grup
update-grub

# Location of template file
template_file="/opt/template.xml"
echo "Generate mac address and cpu model"
generate_mac_num=$(grep "mac_str"  ${template_file} | wc -l)
for((i=1;i<=${generate_mac_num};i++)); do
        # Generate mac address
        mac=$(echo $RANDOM|md5sum|sed 's/../:&/g'|cut -c 1-15)
        constant="00"
        mac_str=${constant}${mac}
        mac_str_constant=$(echo mac_str${i})
        # to change the mac address from template file
        sed -i "s/${mac_str_constant}/${mac_str}/g" ${template_file}
done

# add cpu number for template file
cpu_number=$(cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l)
sed -i "s/cpu_num/${cpu_number}/g" ${template_file}

# add member size for template file
mem_total=$(grep MemTotal /proc/meminfo | awk  '{print $2}')
free_size=$((${mem_total}-638812))
sed -i "s/free_mem/${free_size}/g" ${template_file}

# add network interface card for template file
nic_list=$(cat /proc/net/dev | awk '{i++; if(i>2){print $1}}' | sed 's/^[\t]*//g' | sed 's/[:]*$//g' | grep -v "lo" | sort -n | grep -v "macvtap")
j=0
# shellcheck disable=SC2068
for i in ${nic_list[@]}; do
  j=$(expr $j + 1)
  nic_str="nic_str"
  nic_str_constant=$(echo nic_str${j})
	# to change the mac address from template file
  sed -i "s/${nic_str_constant}/${i}/g" ${template_file}
done

# centos 7 is ture
# get the cpu model of the physical machine
#cpu_string=$(virsh  capabilities | grep "<model>" | head -n 1)
#cpu_sub_string=$(echo ${cpu_string%<*})
#cpu_mid_string=$(echo ${cpu_sub_string##*>})
#echo $cpu_mid_string
#
## to change the cpu model from template file
#sed -i "s/${cpu_str}/${cpu_mid_string}/g" ${template_file}

img="ECV-8.3.3.5_86013.qcow2"
mv /opt/service/img/${img} /var/lib/libvirt/images/
chmod 755 /var/lib/libvirt/images/${img}
mv /opt/service/bin/getsn  /usr/local/bin
chmod +x /usr/local/bin/getsn || true
#rm -rf /opt/service