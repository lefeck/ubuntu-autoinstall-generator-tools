# Ubuntu Release Version 20 To 22  Server Autoinstall

A script to generate a fully-automated ISO image for installing Ubuntu onto a machine without human interaction. This uses the new autoinstall method for Ubuntu and newer.

##  Requirements

Tested on a host running Ubuntu System
- Utilities required:
 ```
xorriso
sed
curl
gpg
isolinux
p7zip-full
dpkg-dev
 ```

### Note: 
We all know that each release version number of ubuntu will be mapped to a name, the following table is the correspondence between them。

| Nubmer      | Name    |
|-------------|---------|
| 20.04.5     | focal   |
| 22.04.1     | jammy   |
| 22.10       | kinetic |


## Basic Usage
```
root@john-desktop:~/ubuntu/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -h
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-a] [-e] [-u user-data-file] [-m meta-data-file] [-p package-name] [-c config-data-file] [-t temaplate-config-file] [-s service-dir-name] [-j job-name] [-k] [-o] [-r] [-d destination-iso-file]

💁 This script will create fully-automated Ubuntu release version 20 to 22 installation media.

Available options:

-h, --help              Print this help and exit
-v, --verbose           Print script debug info
-a, --all-in-one        Bake user-data and meta-data into the generated ISO. By default you will
                        need to boot systems with a CIDATA volume attached containing your
                        autoinstall user-data and meta-data files.
                        For more information see: https://ubuntu.com/server/docs/install/autoinstall-quickstart
-e, --use-hwe-kernel    Force the generated ISO to boot using the hardware enablement (HWE) kernel. Not supported
                        by early Ubuntu 20.04 release ISOs.
-u, --user-data         Path to user-data file. Required if using -a
-n, --release-name      Specifies the code name to download the ISO image distribution, You must select any string
                        from the list as an argument. eg: focal, jammy, kinetic.
-m, --meta-data         Path to meta-data file. Will be an empty file if not specified and using -a
-p, --package-name      Bake he package-name downloaded installation into the generated ISO. if the package-name is empty，
                        no installation package will be downloaded. Path to package-name file. Required if using -a
-c, --config-data       Path to config-data file. Required if using -a
-t  --temaplate-config  Path to temaplate-config file. Required if using -a
-k, --no-verify         Disable GPG verification of the source ISO file. By default SHA256SUMS-$today and
                        SHA256SUMS-$today.gpg in ${script_dir} will be used to verify the authenticity and integrity
                        of the source ISO file. If they are not present the latest daily SHA256SUMS will be
                        downloaded and saved in ${script_dir}. The Ubuntu signing key will be downloaded and
                        saved in a new keyring in ${script_dir}
-o, --no-md5            Disable MD5 checksum on boot
-r, --use-release-iso   Use the current release ISO instead of the daily ISO. The file will be used if it already
                        exists.
-d, --destination       Destination ISO file. By default ${script_dir}/ubuntu-autoinstall-$today.iso will be
                        created, overwriting any existing file.
-s  --service-dir-name  Bake service-dir-name into the generated ISO. if service-dir-name is not specified, no local application
                        will be uploaded to complete the ISO build. Path to service-dir-name directory. Required if using -a
-j  --job-name         Bake job-name into the generated ISO. if job-name is not specified, there will be
                       no action to change after the service starts. Path to job-name file. Required if using -a
```
### Example
```
root@john-desktop:~/ubuntu/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n jammy -d ubuntu-autoinstall-jammytest.iso      
[2022-12-14 01:03:12] 👶 Starting up...
[2022-12-14 01:03:12] 🔎 Checking for current release...
[2022-12-14 01:03:13] 💿 Current release is 22.04.1
[2022-12-14 01:03:14] 📁 Created temporary working directory /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:14] 🔎 Checking for required utilities...
[2022-12-14 01:03:14] 👍 All required utilities are installed.
[2022-12-14 01:03:14] ☑️ Using existing /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso file.
[2022-12-14 01:03:14] ☑️ Using existing SHA256SUMS-22.04.1 & SHA256SUMS-22.04.1.gpg files.
[2022-12-14 01:03:14] ☑️ Using existing Ubuntu signing key saved in /root/ubuntu20/ubuntu-autoinstall-generator-tools/843938DF228D22F7B3742BC0D94AA3F0EFE21092.keyring
[2022-12-14 01:03:14] 🔐 Verifying /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso integrity and authenticity...
[2022-12-14 01:03:24] 👍 Verification succeeded.
[2022-12-14 01:03:24] 🔧 Extracting ISO image...
[2022-12-14 01:03:27] 👍 Extracted to /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:16:23] 🧩 Adding autoinstall parameter to kernel command line...
[2022-12-14 01:16:23] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2022-12-14 01:16:23] 🧩 Adding user-data and meta-data files...
[2022-12-14 01:16:23] 👍 Added data and configured kernel command line.
[2022-12-14 01:16:23] 👷 Updating /tmp/tmp.OYliQ5b0VL/md5sum.txt with hashes of modified files...
[2022-12-14 01:16:23] 👍 Updated hashes.
[2022-12-14 01:16:23] 📦 Repackaging extracted files into an ISO image...
[2022-12-14 01:16:38] 👍 Repackaged into /root/ubuntu/ubuntu-autoinstall-generator-tools/ubuntu-autoinstall-jammy.iso
[2022-12-14 01:16:38] ✅ Completed.
[2022-12-14 01:16:38] 🚽 Deleted temporary working directory /tmp/tmp.OYliQ5b0VL
```
Now you can boot your target machine using ubuntu-autoinstall-jammy.iso and it will automatically install Ubuntu using the configuration from user-data-example. Also, you can select the version you want to build with the required parameter -n.

## Advanced Usage

### Only download the installation package

When you just download the installation package from the Internet, you do not have to modify the configuration file of the installation package, just specify -p
###  Example
first，you shoule be configure the package-name.txt of the installation packages names, for example:
```text
# Define the name of the package to be downloaded from the Internet
 net-tools
mariadb-server
gcc
keepalived
samba samba-common
```
Then you also need to add the following parameter to the late-command configuration field in user-data, for example:

Note: that the parameters are fixed and are not allowed to be modified
```yaml
  late-commands:
    - cp -rp /cdrom/mnt /target/
    - chmod +x /target/mnt/script/install-pkgs.sh
    - curtin in-target --target=/target -- /mnt/script/install-pkgs.sh
```
Finally, you need to specify on the command line the package-name.txt that you want to download the installer from, with the -p parameter.
```
root@john-desktop:~/ubuntu/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n jammy -p package-name.txt -d ubuntu-autoinstall-jammytest.iso      
[2022-12-14 01:03:12] 👶 Starting up...
[2022-12-14 01:03:12] 🔎 Checking for current release...
[2022-12-14 01:03:13] 💿 Current release is 22.04.1
[2022-12-14 01:03:14] 📁 Created temporary working directory /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:14] 🔎 Checking for required utilities...
[2022-12-14 01:03:14] 👍 All required utilities are installed.
[2022-12-14 01:03:14] ☑️ Using existing /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso file.
[2022-12-14 01:03:14] ☑️ Using existing SHA256SUMS-22.04.1 & SHA256SUMS-22.04.1.gpg files.
[2022-12-14 01:03:14] ☑️ Using existing Ubuntu signing key saved in /root/ubuntu20/ubuntu-autoinstall-generator-tools/843938DF228D22F7B3742BC0D94AA3F0EFE21092.keyring
[2022-12-14 01:03:14] 🔐 Verifying /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso integrity and authenticity...
[2022-12-14 01:03:24] 👍 Verification succeeded.
[2022-12-14 01:03:24] 🔧 Extracting ISO image...
[2022-12-14 01:03:27] 👍 Extracted to /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:27] 🌎 Downloading and saving packages tcpdump
[2022-12-14 01:04:48] 🌎 Downloading and saving packages net-tools
[2022-12-14 01:04:51] 🌎 Downloading and saving packages gcc
[2022-12-14 01:10:52] 🌎 Downloading and saving packages mysql-server
[2022-12-14 01:16:23] 👍 Downloaded packages and saved to /tmp/tmp.OYliQ5b0VL/mnt/pkgs
[2022-12-14 01:16:23] 🧩 Adding autoinstall parameter to kernel command line...
[2022-12-14 01:16:23] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2022-12-14 01:16:23] 🧩 Adding user-data and meta-data files...
[2022-12-14 01:16:23] 👍 Added data and configured kernel command line.
[2022-12-14 01:16:23] 👷 Updating /tmp/tmp.OYliQ5b0VL/md5sum.txt with hashes of modified files...
[2022-12-14 01:16:23] 👍 Updated hashes.
[2022-12-14 01:16:23] 📦 Repackaging extracted files into an ISO image...
[2022-12-14 01:16:38] 👍 Repackaged into /root/ubuntu/ubuntu-autoinstall-generator-tools/ubuntu-autoinstall-jammy.iso
[2022-12-14 01:16:38] ✅ Completed.
[2022-12-14 01:16:38] 🚽 Deleted temporary working directory /tmp/tmp.OYliQ5b0VL
```

### Download the installation package, and modify it before the APP Service is started.
When you specify -p in your script to download the dependencies from the Internet, If you want to change the default values of the configuration file through a template or command before starting the service.

###  Example
The following is an example of a mysql config file change operation, Three flexible methods are provided here, choose any one of them.

#### 1. You can modify the configuration file by using the linux command, for example:

You can modify the parameters of the configuration file directly with the linux command in the late-command configuration section of user-dat, for example:
Note: Except for the sed command line, which can be changed, other commands are not allowed.
```yaml
  late-commands:
    - cp -rp /cdrom/mnt /target/
    - chmod +x /target/mnt/script/install-pkgs.sh
    - curtin in-target --target=/target -- /mnt/script/install-pkgs.sh
    # modfiy mydql parameters of the configruation， as the following:
    - sed -i '/^bind-address/c\port = 13306' /target/etc/mysql/mariadb.conf.d/50-server.cnf
    - sed -i '/^#key_buffer_size/c\key_buffer_size = 128M' /target/etc/mysql/mariadb.conf.d/50-server.cnf
```
Finally, you need to specify on the command line the package-name.txt that you want to download the installer from, with the -p parameter.
```
root@john-desktop:~/ubuntu/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n jammy -p package-name.txt -d ubuntu-autoinstall-jammytest.iso      
[2022-12-14 01:03:12] 👶 Starting up...
[2022-12-14 01:03:12] 🔎 Checking for current release...
[2022-12-14 01:03:13] 💿 Current release is 22.04.1
[2022-12-14 01:03:14] 📁 Created temporary working directory /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:14] 🔎 Checking for required utilities...
[2022-12-14 01:03:14] 👍 All required utilities are installed.
[2022-12-14 01:03:14] ☑️ Using existing /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso file.
[2022-12-14 01:03:14] ☑️ Using existing SHA256SUMS-22.04.1 & SHA256SUMS-22.04.1.gpg files.
[2022-12-14 01:03:14] ☑️ Using existing Ubuntu signing key saved in /root/ubuntu20/ubuntu-autoinstall-generator-tools/843938DF228D22F7B3742BC0D94AA3F0EFE21092.keyring
[2022-12-14 01:03:14] 🔐 Verifying /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso integrity and authenticity...
[2022-12-14 01:03:24] 👍 Verification succeeded.
[2022-12-14 01:03:24] 🔧 Extracting ISO image...
[2022-12-14 01:03:27] 👍 Extracted to /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:27] 🌎 Downloading and saving packages tcpdump
[2022-12-14 01:04:48] 🌎 Downloading and saving packages net-tools
[2022-12-14 01:04:51] 🌎 Downloading and saving packages gcc
[2022-12-14 01:10:52] 🌎 Downloading and saving packages mysql-server
[2022-12-14 01:16:23] 👍 Downloaded packages and saved to /tmp/tmp.OYliQ5b0VL/mnt/pkgs
[2022-12-14 01:16:23] 🧩 Adding autoinstall parameter to kernel command line...
[2022-12-14 01:16:23] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2022-12-14 01:16:23] 🧩 Adding user-data and meta-data files...
[2022-12-14 01:16:23] 👍 Added data and configured kernel command line.
[2022-12-14 01:16:23] 👷 Updating /tmp/tmp.OYliQ5b0VL/md5sum.txt with hashes of modified files...
[2022-12-14 01:16:23] 👍 Updated hashes.
[2022-12-14 01:16:23] 📦 Repackaging extracted files into an ISO image...
[2022-12-14 01:16:38] 👍 Repackaged into /root/ubuntu/ubuntu-autoinstall-generator-tools/ubuntu-autoinstall-jammy.iso
[2022-12-14 01:16:38] ✅ Completed.
[2022-12-14 01:16:38] 🚽 Deleted temporary working directory /tmp/tmp.OYliQ5b0VL
```


#### 2. You can modify the configration file by useing the shell script, use the following methods

You should custom configure the config.sh script, and then reference it in the late-command, for example:
```sh
#!/bin/bash
#
sed -i '/^bind-address/c\port = 13306' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#key_buffer_size/c\key_buffer_size = 128M' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#max_allowed_packet/c\max_allowed_packet = 1G' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#thread_stack/c\thread_stack = 512K' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#thread_cache_size/c\thread_cache_size = 16' /etc/mysql/mariadb.conf.d/50-server.cnf
```
Note: that the parameters are fixed and are not allowed to be modified
```yaml
  late-commands:
    - cp -rp /cdrom/mnt /target/
    - chmod +x /target/mnt/script/install-pkgs.sh
    - curtin in-target --target=/target -- /mnt/script/install-pkgs.sh
    - chmod +x /target/mnt/script/config.sh
    - curtin in-target --target=/target -- /mnt/script/config.sh
```
Finally, you need to specify on the command line the package-name.txt that you want to download the installer from, with the -p parameter, And you also have to specify the configuration file with -c
```
root@john-desktop:~/ubuntu/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n jammy -p package-name.txt -c config.sh -d ubuntu-autoinstall-jammytest.iso      
[2022-12-14 01:03:12] 👶 Starting up...
[2022-12-14 01:03:12] 🔎 Checking for current release...
[2022-12-14 01:03:13] 💿 Current release is 22.04.1
[2022-12-14 01:03:14] 📁 Created temporary working directory /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:14] 🔎 Checking for required utilities...
[2022-12-14 01:03:14] 👍 All required utilities are installed.
[2022-12-14 01:03:14] ☑️ Using existing /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso file.
[2022-12-14 01:03:14] ☑️ Using existing SHA256SUMS-22.04.1 & SHA256SUMS-22.04.1.gpg files.
[2022-12-14 01:03:14] ☑️ Using existing Ubuntu signing key saved in /root/ubuntu20/ubuntu-autoinstall-generator-tools/843938DF228D22F7B3742BC0D94AA3F0EFE21092.keyring
[2022-12-14 01:03:14] 🔐 Verifying /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso integrity and authenticity...
[2022-12-14 01:03:24] 👍 Verification succeeded.
[2022-12-14 01:03:24] 🔧 Extracting ISO image...
[2022-12-14 01:03:27] 👍 Extracted to /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:27] 🌎 Downloading and saving packages tcpdump
[2022-12-14 01:04:48] 🌎 Downloading and saving packages net-tools
[2022-12-14 01:04:51] 🌎 Downloading and saving packages gcc
[2022-12-14 01:10:52] 🌎 Downloading and saving packages mysql-server
[2022-12-14 01:16:23] 👍 Downloaded packages and saved to /tmp/tmp.OYliQ5b0VL/mnt/pkgs
[2022-12-14 01:16:23] 🧩 Adding autoinstall parameter to kernel command line...
[2022-12-14 01:16:23] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2022-12-14 01:16:23] 🧩 Adding user-data and meta-data files...
[2022-12-14 01:16:23] 👍 Added data and configured kernel command line.
[2022-12-14 01:16:23] 👷 Updating /tmp/tmp.OYliQ5b0VL/md5sum.txt with hashes of modified files...
[2022-12-14 01:16:23] 👍 Updated hashes.
[2022-12-14 01:16:23] 📦 Repackaging extracted files into an ISO image...
[2022-12-14 01:16:38] 👍 Repackaged into /root/ubuntu/ubuntu-autoinstall-generator-tools/ubuntu-autoinstall-jammy.iso
[2022-12-14 01:16:38] ✅ Completed.
[2022-12-14 01:16:38] 🚽 Deleted temporary working directory /tmp/tmp.OYliQ5b0VL
```


#### 3. You can modify the configration file by useing the template file
You need to make a copy of the template configuration file beforehand, and modify it to your desired state, and then reference it in the late-command, for example:

Here I am using the database template file is template.conf， Not in the specific display content

Note: Except for the source and destination configuration files of the template file, which can be changed, nothing else is allowed
```yaml
  late-commands:    
    - cp -rp /cdrom/mnt /target/
    - chmod +x /target/mnt/script/install-pkgs.sh
    - curtin in-target --target=/target -- /mnt/script/install-pkgs.sh
    - curtin in-target --target=/target -- cp /mnt/template.conf /etc/mysql/mariadb.conf.d/50-server.cnf
   #- curtin in-target --target=/target -- cp /mnt/template.conf /etc/nginx/config.d/app.conf
```
Finally, you need to specify on the command line the package-name.txt that you want to download the installer from, with the -p parameter, And you also have to specify the template file with -t
```sh
root@john-desktop:~/ubuntu/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n jammy -p package-name.txt -t template.conf -d ubuntu-autoinstall-jammytest.iso      
[2022-12-14 01:03:12] 👶 Starting up...
[2022-12-14 01:03:12] 🔎 Checking for current release...
[2022-12-14 01:03:13] 💿 Current release is 22.04.1
[2022-12-14 01:03:14] 📁 Created temporary working directory /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:14] 🔎 Checking for required utilities...
[2022-12-14 01:03:14] 👍 All required utilities are installed.
[2022-12-14 01:03:14] ☑️ Using existing /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso file.
[2022-12-14 01:03:14] ☑️ Using existing SHA256SUMS-22.04.1 & SHA256SUMS-22.04.1.gpg files.
[2022-12-14 01:03:14] ☑️ Using existing Ubuntu signing key saved in /root/ubuntu20/ubuntu-autoinstall-generator-tools/843938DF228D22F7B3742BC0D94AA3F0EFE21092.keyring
[2022-12-14 01:03:14] 🔐 Verifying /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso integrity and authenticity...
[2022-12-14 01:03:24] 👍 Verification succeeded.
[2022-12-14 01:03:24] 🔧 Extracting ISO image...
[2022-12-14 01:03:27] 👍 Extracted to /tmp/tmp.OYliQ5b0VL
[2022-12-14 01:03:27] 🌎 Downloading and saving packages tcpdump
[2022-12-14 01:04:48] 🌎 Downloading and saving packages net-tools
[2022-12-14 01:04:51] 🌎 Downloading and saving packages gcc
[2022-12-14 01:10:52] 🌎 Downloading and saving packages mysql-server
[2022-12-14 01:16:23] 👍 Downloaded packages and saved to /tmp/tmp.OYliQ5b0VL/mnt/pkgs
[2022-12-14 01:16:23] 🧩 Adding autoinstall parameter to kernel command line...
[2022-12-14 01:16:23] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2022-12-14 01:16:23] 🧩 Adding user-data and meta-data files...
[2022-12-14 01:16:23] 👍 Added data and configured kernel command line.
[2022-12-14 01:16:23] 👷 Updating /tmp/tmp.OYliQ5b0VL/md5sum.txt with hashes of modified files...
[2022-12-14 01:16:23] 👍 Updated hashes.
[2022-12-14 01:16:23] 📦 Repackaging extracted files into an ISO image...
[2022-12-14 01:16:38] 👍 Repackaged into /root/ubuntu/ubuntu-autoinstall-generator-tools/ubuntu-autoinstall-jammy.iso
[2022-12-14 01:16:38] ✅ Completed.
[2022-12-14 01:16:38] 🚽 Deleted temporary working directory /tmp/tmp.OYliQ5b0VL
```

### Download the installation package, and modify it after the APP Service is started.
When you specify -p in your script to download the dependencies from the Internet, if you need to make changes after the image is installed and the service status is running, then you need to customize the script parameters in the rc.local file.

###  Example
The following is an example of a mysql password change operation
```sh
#!/bin/bash

#This script will be executed *after* all the other init scripts.
#You can put your own initialization stuff in here if you don't
#want to do the full Sys V style init stuff.

file="/etc/rc.local"

# the following functions are used for logging purposes and are not recommended to be modified
# set extraiable value
DATE=`date "+%Y-%m-%d %H:%M:%S"`
USER=`whoami`
HOST_NAME=`hostname`
LOG_FILE="/var/log/rc-local.log"

# Execution successful log printing path
function log_info () {
    echo "${DATE} ${HOST_NAME} ${USER} execute $0 [INFO] $@" >> ${LOG_FILE}
}

# Execution successful ⚠️ warning log print path
function log_warn () {
    echo "${DATE} ${HOST_NAME} ${USER} execute $0 [WARN] $@" >> ${LOG_FILE}
}

# Execution failure log print path
function log_error () {
    echo -e "\033[41;37m ${DATE} ${HOST_NAME} ${USER} execute $0 [ERROR] $@ \033[0m"  >> ${LOG_FILE}
}

function fn_log ()  {
    if [  $? -eq 0  ]
    then
            log_info "👍 $@ sucessed."
            echo -e "\033[32m $@ sucessed. \033[0m"
    else
            log_error "👿 $@ failed."
            echo -e "\033[41;37m $@ failed. \033[0m"
            exit 1
    fi
}

# this is an example of password mysql change
mysql_user="root"
# default password is null
mysql_password="123456"
new_mysql_password="MsTac@2001"
while true; do
    processNum=`ps aux | grep mysql | grep -v grep | wc -l`;
    # change mysql password
    if [ $processNum -ne 0 ]; then
      log_info "waiting for 2s"
      sleep 2
      sudo mysql -u${mysql_user} -p${mysql_password}  << EOF
      GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY "${new_mysql_password}" WITH GRANT OPTION;
      GRANT ALL ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY "${new_mysql_password}" WITH GRANT OPTION;
      GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY "${new_mysql_password}" WITH GRANT OPTION;
      FLUSH PRIVILEGES;
      COMMIT;
EOF
      fn_log "Update mysql password"
      break
    else
      sleep 2
      log_info "waiting for 2s"
    fi
done
rm  -f ${file}
fn_log "Clean files ${file}"
exit 0
```
Then you also need to add the following parameter to the late-command configuration field in user-data, for example:

Note: that the parameters are fixed and are not allowed to be modified.
```yaml
  late-commands:
    - cp -rp /cdrom/mnt /target/
    - chmod +x /target/mnt/script/install-pkgs.sh
    - chmod +x /target/mnt/script/config.sh
    - curtin in-target --target=/target -- /mnt/script/install-pkgs.sh
    - cp /cdrom/rc-local.service /target/lib/systemd/system/rc-local.service
    - curtin in-target --target=/target -- ln -s /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service
    - cp -p /cdrom/rc.local /target/etc/rc.local
    - chmod +x /target/etc/rc.local
    - systemctl daemon-reload
```

Finally, you need to specfiy the file name of the one-time task rc.lcoal on the command line, via the -j parameter
```shell
root@john-desktop:~/ubuntu20/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n jammy -p package-name.txt -j rc.local -d ubuntu-autoinstall-jammytest.iso  
[2022-12-16 09:46:19] 👶 Starting up...
[2022-12-16 09:46:19] 🔎 Checking for current release...
[2022-12-16 09:46:21] 💿 Current release is 22.04.1
[2022-12-16 09:46:21] 📁 Created temporary working directory /tmp/tmp.tRYNYKdmxv
[2022-12-16 09:46:21] 🔎 Checking for required utilities...
[2022-12-16 09:46:21] 👍 All required utilities are installed.
[2022-12-16 09:46:21] ☑️ Using existing /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso file.
[2022-12-16 09:46:21] ☑️ Using existing SHA256SUMS-22.04.1 & SHA256SUMS-22.04.1.gpg files.
[2022-12-16 09:46:21] ☑️ Using existing Ubuntu signing key saved in /root/ubuntu20/ubuntu-autoinstall-generator-tools/843938DF228D22F7B3742BC0D94AA3F0EFE21092.keyring
[2022-12-16 09:46:21] 🔐 Verifying /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso integrity and authenticity...
[2022-12-16 09:46:31] 👍 Verification succeeded.
[2022-12-16 09:46:31] 🔧 Extracting ISO image...
[2022-12-16 09:46:38] 👍 Extracted to /tmp/tmp.tRYNYKdmxv
[2022-12-16 09:46:38] 🌎 Downloading and saving packages net-tools
[2022-12-16 09:46:53] 🌎 Downloading and saving packages keepalived
[2022-12-16 09:48:03] 🌎 Downloading and saving packages nginx
[2022-12-16 09:50:13] 🌎 Downloading and saving packages mariadb-server
[2022-12-16 09:51:19] 🌎 Downloading and saving packages mariadb-client
[2022-12-16 09:51:21] 🚽 Deleted temporary file /tmp/tmp.tRYNYKdmxv/package-name.txt.
[2022-12-16 09:51:21] 👍 Downloaded packages and saved to /tmp/tmp.tRYNYKdmxv/mnt/pkgs
[2022-12-16 09:51:21] 📁 Moving rc.local file to temporary working directory /tmp/tmp.tRYNYKdmxv/mnt/script.
[2022-12-16 09:51:21] 🧩 Adding autoinstall parameter to kernel command line...
[2022-12-16 09:51:21] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2022-12-16 09:51:21] 🧩 Adding user-data and meta-data files...
[2022-12-16 09:51:21] 👍 Added data and configured kernel command line.
[2022-12-16 09:51:21] 👷 Updating /tmp/tmp.tRYNYKdmxv/md5sum.txt with hashes of modified files...
[2022-12-16 09:51:21] 👍 Updated hashes.
[2022-12-16 09:51:21] 📦 Repackaging extracted files into an ISO image...
[2022-12-16 09:51:38] 👍 Repackaged into /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-autoinstall-jammytest.iso
[2022-12-16 09:51:38] ✅ Completed.
[2022-12-16 09:51:38] 🚽 Deleted temporary working directory /tmp/tmp.OYliQ5b0VL
```

### Define your own local installer upload build ISO.
If you need to build a local application into the ISO image, you need to specify the -s parameter to provide the directory.

###  Example
The following is an example of local application

First, let's look at the service directory structure
```text
root@john-desktop:~# tree service/
service/
├── app      # binary file
├── app.service
└── config
      └── config.ini

1 directory, 3 files
root@john-desktop:~#
```
Customize the app.service file as follows:
```text
[Unit]
Description=Application Service Programs
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/service/
ExecStart=/opt/service/app
Restart=always

[Install]
WantedBy=multi-user.target
```
Then you also need to add the following parameter to the late-command configuration field in user-data, for example:

Note: In the late-command, I will copy the service directory to /cdrom/mnt, this path is not allowed to be modified, other can be modified, must be the name of the service, etc.
```yaml
  late-commands:
    - cp -rp /cdrom/mnt/service /target/opt
    - cp /cdrom/mnt/service/app.service /target/lib/systemd/system/app.service
    - curtin in-target --target=/target -- ln -sn /lib/systemd/system/app.service /etc/systemd/system/multi-user.target.wants/app.service
```

Finally, You need to specify the app directory of the local application, specified by the -s parameter, The commands are as follows:
```shell
root@john-desktop:~/ubuntu/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n jammy  -p  package-name.txt -j rc.local  -s /root/service -d ubuntu-autoinstall-jammytest.iso             
[2022-12-16 10:43:27] 👶 Starting up...
[2022-12-16 10:43:27] 🔎 Checking for current release...
[2022-12-16 10:43:29] 💿 Current release is 22.04.1
[2022-12-16 10:43:29] 📁 Created temporary working directory /tmp/tmp.X12RSWTKVK
[2022-12-16 10:43:29] 🔎 Checking for required utilities...
[2022-12-16 10:43:29] 👍 All required utilities are installed.
[2022-12-16 10:43:29] ☑️ Using existing /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso file.
[2022-12-16 10:43:29] ☑️ Using existing SHA256SUMS-22.04.1 & SHA256SUMS-22.04.1.gpg files.
[2022-12-16 10:43:29] ☑️ Using existing Ubuntu signing key saved in /root/ubuntu20/ubuntu-autoinstall-generator-tools/843938DF228D22F7B3742BC0D94AA3F0EFE21092.keyring
[2022-12-16 10:43:29] 🔐 Verifying /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-22.04.1-live-server-amd64.iso integrity and authenticity...
[2022-12-16 10:43:39] 👍 Verification succeeded.
[2022-12-16 10:43:39] 🔧 Extracting ISO image...
[2022-12-16 10:43:49] 👍 Extracted to /tmp/tmp.X12RSWTKVK
[2022-12-16 10:43:49] 🌎 Downloading and saving packages net-tools
[2022-12-16 10:43:55] 🌎 Downloading and saving packages keepalived
[2022-12-16 10:44:15] 🌎 Downloading and saving packages nginx
[2022-12-16 10:44:48] 🌎 Downloading and saving packages mariadb-server
[2022-12-16 10:45:05] 🌎 Downloading and saving packages mariadb-client
[2022-12-16 10:45:07] 🚽 Deleted temporary file /tmp/tmp.X12RSWTKVK/package-name.txt.
[2022-12-16 10:45:07] 👍 Downloaded packages and saved to /tmp/tmp.X12RSWTKVK/extra/pkgs
[2022-12-16 10:45:07] 📁 Moving rc.local file to temporary working directory /tmp/tmp.X12RSWTKVK/mnt/script.
[2022-12-16 10:45:07] 📁 Moving /root/tmp directory to temporary working directory /tmp/tmp.X12RSWTKVK/mnt/ 
[2022-12-16 10:45:07] 🧩 Adding autoinstall parameter to kernel command line...
[2022-12-16 10:45:07] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2022-12-16 10:45:07] 🧩 Adding user-data and meta-data files...
[2022-12-16 10:45:07] 👍 Added data and configured kernel command line.
[2022-12-16 10:45:07] 👷 Updating /tmp/tmp.X12RSWTKVK/md5sum.txt with hashes of modified files...
[2022-12-16 10:45:07] 👍 Updated hashes.
[2022-12-16 10:45:07] 📦 Repackaging extracted files into an ISO image...
[2022-12-16 10:45:23] 👍 Repackaged into /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-autoinstall-jammytest.iso
[2022-12-16 10:45:23] ✅ Completed.
[2022-12-16 10:45:23] 🚽 Deleted temporary working directory /tmp/tmp.OYliQ5b0VL
```

## Thanks

The tool was created with reference to a large number of articles, including: [ubuntu-jammy-netinstall-pxe](https://www.molnar-peter.hu/en/ubuntu-jammy-netinstall-pxe.html),[ubuntu-autoinstall-generator](https://github.com/covertsh/ubuntu-autoinstall-generator), [ubuntu-desktop-22.04-autoinstall](https://github.com/michaeltandy/ubuntu-desktop-22.04-autoinstall),[ubuntu 22.04 autoinstall](https://www.pugetsystems.com/labs/hpc/ubuntu-22-04-server-autoinstall-iso/#:~:text=The%20Ubuntu%2022.04%20server%20ISO%20layout%20differs%20from,partitions%20for%20you%21%207z%20-y%20x%20jammy-live-server-amd64.iso%20-osource-files), The script [ubuntu-autoinstall-generator](https://github.com/covertsh/ubuntu-autoinstall-generator) is based on the version control, and some parameters optimization, thanks to the developer's open source contribution.
