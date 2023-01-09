#!/bin/bash
#
sed -i '/^bind-address/c\port = 13306' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#key_buffer_size/c\key_buffer_size = 128M' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#max_allowed_packet/c\max_allowed_packet = 1G' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#thread_stack/c\thread_stack = 512K' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#thread_cache_size/c\thread_cache_size = 16' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#max_connections/c\max_connections = 2000' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#slow_query_log_file/c\slow_query_log_file    = /var/log/mysql/mariadb-slow.log' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#long_query_time/c\long_query_time        = 10' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#log_slow_verbosity/c\log_slow_verbosity     = query_plan,explain' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#log-queries-not-using-rndexes/c\log-queries-not-using-rndexes' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#min_examined_row_limit/c\min_examined_row_limit = 1000' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#table_cache/c\table_cache = 128' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#skip-name-resolvlse/c\skip-name-resolve' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#thread_cache_size/c\thread_cache_size = 32' /etc/mysql/mariadb.conf.d/50-server.cnf

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