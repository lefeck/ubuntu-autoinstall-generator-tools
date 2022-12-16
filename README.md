# Ubuntu Release Version 20 To 22  Server Autoinstall

A script to generate a fully-automated ISO image for installing Ubuntu onto a machine without human interaction. This uses the new autoinstall method for Ubuntu and newer.

##  Requirements

Tested on a host running Ubuntu machine
- Utilities required:
 ```
xorriso
sed
curl
gpg
isolinux
p7zip-full
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
Usage: ubuntu-autoinstall-generator-tools.sh [-h] [-v] [-a] [-e] [-u user-data-file] [-m meta-data-file] [-p ] [-f file-name][-k] [-c] [-r] [-d destination-iso-file]

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
-p, --packages-name     Bake file-name into the generated ISO. if the package-name is empty，no installation package
                        will be downloaded.
-f, --file-name         Path to file-name file. Required if using -p
-k, --no-verify         Disable GPG verification of the source ISO file. By default SHA256SUMS-2022-12-14 and
                        SHA256SUMS-2022-12-14.gpg in /root/ubuntu20/ubuntu-autoinstall-generator-tools will be used to verify the authenticity and integrity
                        of the source ISO file. If they are not present the latest daily SHA256SUMS will be
                        downloaded and saved in /root/ubuntu20/ubuntu-autoinstall-generator-tools. The Ubuntu signing key will be downloaded and
                        saved in a new keyring in /root/ubuntu20/ubuntu-autoinstall-generator-tools
-c, --no-md5            Disable MD5 checksum on boot
-r, --use-release-iso   Use the current release ISO instead of the daily ISO. The file will be used if it already
                        exists.
-d, --destination       Destination ISO file. By default /root/ubuntu20/ubuntu-autoinstall-generator-tools/ubuntu-autoinstall-2022-12-14.iso will be
                        created, overwriting any existing file.
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

When you just download the installation package from the Internet, you do not have to modify the configuration file of the installation package, just specify -f
###  Example
```
root@john-desktop:~/ubuntu/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n  jammy  -p -f file-name.txt -d ubuntu-autoinstall-jammytest.iso      
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
[2022-12-14 01:16:23] 👍 Downloaded packages and saved to /tmp/tmp.OYliQ5b0VL/install/pkgs
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
When you specify -f in your script to download the dependencies from the Internet, if you need to make changes after the image is installed and the service status is running, then you need to customize the script parameters in the rc.local file.

###  Example
The following is an example of a mysql password change operation
```sh
#!/bin/sh

#This script will be executed *after* all the other init scripts.
#You can put your own initialization stuff in here if you don't
#want to do the full Sys V style init stuff.

file="/etc/rc.local"

function cleanup() {
        trap - SIGINT SIGTERM ERR EXIT
        if [  -s ${file} ]; then
                cat /dev/null > ${file}
                log "🚽 Emptying files $file"
        fi
}

# when quit clean file
trap cleanup SIGINT SIGTERM ERR EXIT

# this is an example of password mysql change
mysql_user="root"
# default password is null
mysql_password=""
new_mysql_password="ubuntu"
while true; do
    processNum=`ps aux | grep mysqld | grep -v grep | wc -l`;
    # change mysql password
    if [ $processNum -ne 0 ]; then
      # select host, user, authentication_string from user where user="root";

      # authentication_string is empty, note： only mysql initable do once it
      mysql -e  "ALTER USER 'root'@'localhost' IDENTIFIED BY ${new_mysql_password};" -u${mysql_user} -p${mysql_password}

      # mysql version is less than 8.0, the execute follow command
      #mysql -e  "grant all privileges on *.* to 'root'@'%' identified by 'lab123' with grant option;" -u${mysql_user} -p${mysql_password}

      # mysql version is greater than 8.0, execute the following command， note： only mysql initable do once it
      mysql -e  "create user 'root'@'%' identified by 'ubuntu';" -u${mysql_user} -p${mysql_password}
      mysql -e  "grant all privileges on *.* to 'root'@'%' with grant option;" -u${mysql_user} -p${mysql_password}

      mysql -e  "flush privileges;" -u${mysql_user} -p${mysql_password}
      mysql -e  "commit;" -u${mysql_user} -p${mysql_password}
      if [[ $? -eq 0 ]]; then
          echo "update mysql password success" > /usr/local/mysql.log
      else
          echo "update mysql password failed" > /usr/local/mysql.log
      fi
      break
    else
       sleep 1
    fi
done
echo "✅ Completed." 0
```

you needed to specify -t parameter of the task file, that the file name can be customized,
```
root@john-desktop:~/ubuntu20/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n jammy -p -f file-name.txt -o -t rc.local  -d ubuntu-autoinstall-jammytest.iso  
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
[2022-12-16 09:51:21] 🚽 Deleted temporary file /tmp/tmp.tRYNYKdmxv/file-name.txt.
[2022-12-16 09:51:21] 👍 Downloaded packages and saved to /tmp/tmp.tRYNYKdmxv/extra/pkgs
[2022-12-16 09:51:21] 📁 Moving rc.local file to temporary working directory /tmp/tmp.tRYNYKdmxv/extra/script.
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
```shell
root@john-desktop:~/ubuntu20/ubuntu-autoinstall-generator-tools# ./ubuntu-autoinstall-generator-tools.sh -a  -u user-data -n  jammy  -p -f file-name.txt -o -t rc.local  -x  -s /root/tmp/  -d ubuntu-autoinstall-jammytest.iso             
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
[2022-12-16 10:45:07] 🚽 Deleted temporary file /tmp/tmp.X12RSWTKVK/file-name.txt.
[2022-12-16 10:45:07] 👍 Downloaded packages and saved to /tmp/tmp.X12RSWTKVK/extra/pkgs
[2022-12-16 10:45:07] 📁 Moving rc.local file to temporary working directory /tmp/tmp.X12RSWTKVK/extra/script.
[2022-12-16 10:45:07] 📁 Moving /root/tmp directory to temporary working directory /tmp/tmp.X12RSWTKVK/extra/ 
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
