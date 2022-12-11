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


## Usage
```
root@john-desktop:~/ubuntu# ./ubuntu-autoinstall-generator-tools.sh -h
Usage: ubuntu-autoinstall-generator-tools.sh [-h] [-v] [-a] [-e] [-u user-data-file] [-m meta-data-file] [-k] [-c] [-r] [-s source-iso-file] [-d destination-iso-file]

💁 This script will create fully-automated Ubuntu 20.04 Focal Fossa installation media.

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
-k, --no-verify         Disable GPG verification of the source ISO file. By default SHA256SUMS-2022-12-11 and
                        SHA256SUMS-2022-12-11.gpg in /root/ubuntu20 will be used to verify the authenticity and integrity
                        of the source ISO file. If they are not present the latest daily SHA256SUMS will be
                        downloaded and saved in /root/ubuntu20. The Ubuntu signing key will be downloaded and
                        saved in a new keyring in /root/ubuntu20
-c, --no-md5            Disable MD5 checksum on boot
-r, --use-release-iso   Use the current release ISO instead of the daily ISO. The file will be used if it already
                        exists.
-d, --destination       Destination ISO file. By default /root/ubuntu/ubuntu-autoinstall-2022-12-11.iso will be
                        created, overwriting any existing file.
```
## Example
```
root@john-desktop:~/ubuntu# ./ubuntu-autoinstall-generator-tools.sh  -a -u user-data-template -n  jammy -d ubuntu-autoinstall-jammy.iso
[2022-12-11 03:45:47] 👶 Starting up...
[2022-12-11 03:45:47] 🔎 Checking for current release...
[2022-12-11 03:45:49] 💿 Current release is 22.04.1
[2022-12-11 03:45:49] 📁 Created temporary working directory /tmp/tmp.qmj7TVgsn7
[2022-12-11 03:45:49] 🔎 Checking for required utilities...
[2022-12-11 03:45:49] 👍 All required utilities are installed.
[2022-12-11 03:45:49] ☑️ Using existing /root/ubuntu20/ubuntu-22.04.1-live-server-amd64.iso file.
[2022-12-11 03:45:49] ☑️ Using existing SHA256SUMS-22.04.1 & SHA256SUMS-22.04.1.gpg files.
[2022-12-11 03:45:49] ☑️ Using existing Ubuntu signing key saved in /root/ubuntu20/843938DF228D22F7B3742BC0D94AA3F0EFE21092.keyring
[2022-12-11 03:45:49] 🔐 Verifying /root/ubuntu20/ubuntu-22.04.1-live-server-amd64.iso integrity and authenticity...
[2022-12-11 03:45:59] 👍 Verification succeeded.
[2022-12-11 03:45:59] 🔧 Extracting ISO image...
[2022-12-11 03:46:03] 👍 Extracted to /tmp/tmp.qmj7TVgsn7
[2022-12-11 03:46:03] 🧩 Adding autoinstall parameter to kernel command line...
[2022-12-11 03:46:03] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2022-12-11 03:46:03] 🧩 Adding user-data and meta-data files...
[2022-12-11 03:46:03] 👍 Added data and configured kernel command line.
[2022-12-11 03:46:03] 👷 Updating /tmp/tmp.qmj7TVgsn7/md5sum.txt with hashes of modified files...
[2022-12-11 03:46:03] 👍 Updated hashes.
[2022-12-11 03:46:03] 📦 Repackaging extracted files into an ISO image...
[2022-12-11 03:46:22] 👍 Repackaged into /root/ubuntu20/ubuntu-autoinstall-jammy.iso
[2022-12-11 03:46:22] ✅ Completed.
[2020-12-23 14:08:14] 🚽 Deleted temporary working directory /tmp/tmp.qmj7TVgsn7
```
Now you can boot your target machine using ubuntu-autoinstall-jammy.iso and it will automatically install Ubuntu using the configuration from user-data-example. Also, you can select the version you want to build with the required parameter -n.
## Thanks

The tool was created with reference to a large number of articles, including:[ubuntu-autoinstall-generator](https://github.com/covertsh/ubuntu-autoinstall-generator), [ubuntu-desktop-22.04-autoinstall](https://github.com/michaeltandy/ubuntu-desktop-22.04-autoinstall),[ubuntu 22.04 autoinstall](https://www.pugetsystems.com/labs/hpc/ubuntu-22-04-server-autoinstall-iso/#:~:text=The%20Ubuntu%2022.04%20server%20ISO%20layout%20differs%20from,partitions%20for%20you%21%207z%20-y%20x%20jammy-live-server-amd64.iso%20-osource-files), The script [ubuntu-autoinstall-generator](https://github.com/covertsh/ubuntu-autoinstall-generator) is based on the version control, and some parameters optimization, thanks to the developer's open source contribution.
