#!/bin/bash
set -Eeuo pipefail

function cleanup() {
        trap - SIGINT SIGTERM ERR EXIT
        if [ -n "${tmpdir+x}" ]; then
                rm -rf "$tmpdir" "$bootdir"
                log "🚽 Deleted temporary working directory $tmpdir"
        fi
}

#trap cleanup SIGINT SIGTERM ERR EXIT

bootdir="/tmp/BOOT"
# Gets the current location of the script
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
# check whether the date command-line tools exists
[[ ! -x "$(command -v date)" ]] && echo "💥 date command not found." && exit 1
today=$(date +"%Y-%m-%d")

function log() {
        echo >&2 -e "[$(date +"%Y-%m-%d %H:%M:%S")] ${1-}"
}

function die() {
        local msg=$1
        local code=${2-1} # Bash parameter expansion - default exit status 1. See https://wiki.bash-hackers.org/syntax/pe#use_a_default_value
        log "$msg"
        exit "$code"
}

# usage of the command line tool
usage() {
        cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-a] [-e] [-u user-data-file] [-m meta-data-file] [-p ] [-f file-name] [-c config-data] [-t temaplate-config] [-k] [-o] [-r] [-d destination-iso-file] [-x] [-s service-dir-name] [-i] [-j job-name]

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
-c, --config-data       Path to config-data file. Required if using -p
-t  --temaplate-config  Path to temaplate-config file. Required if using -p
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
-x  --service-dir       Bake service-dir-name into the generated ISO. if service-dir is not specified, no local application
                        will be uploaded to complete the ISO build.
-s  --service-dir-name  Path to service-dir-name file. Required if using -x
-i  --all-in-one-job   Bake job-name into the generated ISO. if job-name is not specified, there will be
                        no action to change after the service starts.
-j  --job-name         Path to job-name file. Required if using -i
EOF
        exit
}


function parse_params() {
        # default values of variables set from params
        release_name=''
        user_data_file=''
        meta_data_file=''
        destination_iso="${script_dir}/ubuntu-autoinstall-$today.iso"
        sha_suffix="${today}"
        gpg_verify=1
        all_in_one=0
        use_hwe_kernel=0
        md5_checksum=1
        use_release_iso=1
        packages_name=0
        file_name=''
        service_dir=0
        service_dir_name=''
        all_in_one_job=0
        job_name=''
        config_data_file=''
        temaplate_config_file=''
        while :; do
                case "${1-}" in
                -h | --help) usage ;;
                -v | --verbose) set -x ;;
                -a | --all-in-one) all_in_one=1 ;;
                -e | --use-hwe-kernel) use_hwe_kernel=1 ;;
                -o | --no-md5) md5_checksum=0 ;;
                -k | --no-verify) gpg_verify=0 ;;
                -r | --use-release-iso) use_release_iso=0 ;;
                -p | --packages-name) packages_name=1 ;;
                -i | --all-in-one-job) all_in_one_job=1 ;;
                -x | --service-dir) service_dir=1 ;;
                -j | --job-name)
                        job_name="${2-}"
                        shift
                        ;;
                -s | --service-dir-name)
                        service_dir_name="${2-}"
                        shift
                        ;;
                -n | --release-name)
                        release_name="${2-}"
                        shift
                        ;;
                -f | --file-name)
                        file_name="${2-}"
                        shift
                        ;;
                -c | --config-data)
                        config_data_file="${2-}"
                        shift
                        ;;
                -t | --temaplate-config)
                        temaplate_config_file="${2-}"
                        shift
                        ;;
                -u | --user-data)
                        user_data_file="${2-}"
                        shift
                        ;;
                -d | --destination)
                        destination_iso="${2-}"
                        shift
                        ;;
                -m | --meta-data)
                        meta_data_file="${2-}"
                        shift
                        ;;
                -?*) die "Unknown option: $1" ;;
                *) break ;;
                esac
                shift
        done

        log "👶 Starting up..."

        # check required params and arguments
        if [ ${all_in_one} -ne 0 ]; then
                [[ -z "${user_data_file}" ]] && die "💥 user-data file was not specified."
                [[ ! -f "$user_data_file" ]] && die "💥 user-data file could not be found."
                [[ -n "${meta_data_file}" ]] && [[ ! -f "$meta_data_file" ]] && die "💥 meta-data file could not be found."
        fi

        [[ -z "${release_name}" ]] && die "💥 release_name was not specified. eg: focal, jammy, kinetic."


        if [ "${use_release_iso}" -eq 1 ]; then
                download_url="https://releases.ubuntu.com/${release_name}"
                log "🔎 Checking for current release..."
                if [ ${release_name} == "kinetic" ]; then
                     download_iso=$(curl -sSL "${download_url}" | grep -oP "ubuntu-[0-9][0-9]\.[0-9][0-9]-live-server-amd64\.iso" | head -n 1)
                else
                     download_iso=$(curl -sSL "${download_url}" | grep -oP "ubuntu-[0-9][0-9]\.[0-9][0-9]\.[0-9]-live-server-amd64\.iso" | head -n 1)
                fi
                source_iso="${script_dir}/${download_iso}"
                current_release=$(echo "${download_iso}" | cut -f2 -d-)
                sha_suffix="${current_release}"
                log "💿 Current release is ${current_release}"
        fi

        destination_iso=$(realpath "${destination_iso}")

        return 0
}

ubuntu_gpg_key_id="843938DF228D22F7B3742BC0D94AA3F0EFE21092"

parse_params "$@"

# The default create a a random directory in /tmp
tmpdir=$(mktemp -d)

if [[ ! "$tmpdir" || ! -d "$tmpdir" ]]; then
        die "💥 Could not create temporary working directory."
else
        log "📁 Created temporary working directory $tmpdir"
fi

log "🔎 Checking for required utilities..."
if [[ ! -x "$(command -v xorriso)" ]];then
        apt-get install xorriso -y
        log "👍 xorriso has been installed on ubuntu"
fi
if [[ ! -x "$(command -v 7z)" ]];then
        apt-get install p7zip-full -y
        log "👍 7z has been installed on ubuntu"
fi

if [ ${release_name} == "focal" ]; then
     [[ ! -f "/usr/lib/ISOLINUX/isohdpfx.bin" ]] && die "💥 isolinux is not installed. On Ubuntu, install the 'isolinux' package."
fi
[[ ! -x "$(command -v xorriso)" ]] && die "💥 xorriso is not installed. On Ubuntu, install  the 'xorriso' package."
[[ ! -x "$(command -v sed)" ]] && die "💥 sed is not installed. On Ubuntu, install the 'sed' package."
[[ ! -x "$(command -v curl)" ]] && die "💥 curl is not installed. On Ubuntu, install the 'curl' package."
[[ ! -x "$(command -v gpg)" ]] && die "💥 gpg is not installed. On Ubuntu, install the 'gpg' package."
[[ ! -x "$(command -v 7z)" ]] && die "💥 7z is not installed. On Ubuntu, install the '7z' package."

log "👍 All required utilities are installed."


# download ISO image
if [ ! -f "${source_iso}" ]; then
        log "🌎 Downloading ISO image for Ubuntu ${sha_suffix} Focal Fossa..."
        if [ ! -f ${source_iso} ]; then
                curl -NsSLO "${download_url}/${download_iso}"
                log "👍 Downloaded and saved to ${source_iso}"
        else
                log "👍 ${source_iso} is exists"
        fi
else
        log "☑️ Using existing ${source_iso} file."
        if [ ${gpg_verify} -eq 1 ]; then
                if [ "${source_iso}" != "${script_dir}/${download_iso}" ]; then
                        log "⚠️ Automatic GPG verification is enabled. If the source ISO file is not the latest daily or release image, verification will fail!"
                fi
        fi
fi

# cheak ISO md5
if [ ${gpg_verify} -eq 1 ]; then
        if [ ! -f "${script_dir}/SHA256SUMS-${sha_suffix}" ]; then
                log "🌎 Downloading SHA256SUMS & SHA256SUMS.gpg files..."
                curl -NsSL "${download_url}/SHA256SUMS" -o "${script_dir}/SHA256SUMS-${sha_suffix}"
                curl -NsSL "${download_url}/SHA256SUMS.gpg" -o "${script_dir}/SHA256SUMS-${sha_suffix}.gpg"
        else
                log "☑️ Using existing SHA256SUMS-${sha_suffix} & SHA256SUMS-${sha_suffix}.gpg files."
        fi

        if [ ! -f "${script_dir}/${ubuntu_gpg_key_id}.keyring" ]; then
                log "🌎 Downloading and saving Ubuntu signing key..."
                gpg -q --no-default-keyring --keyring "${script_dir}/${ubuntu_gpg_key_id}.keyring" --keyserver "hkp://keyserver.ubuntu.com" --recv-keys "${ubuntu_gpg_key_id}"
                log "👍 Downloaded and saved to ${script_dir}/${ubuntu_gpg_key_id}.keyring"
        else
                log "☑️ Using existing Ubuntu signing key saved in ${script_dir}/${ubuntu_gpg_key_id}.keyring"
        fi

        log "🔐 Verifying ${source_iso} integrity and authenticity..."
        gpg -q --keyring "${script_dir}/${ubuntu_gpg_key_id}.keyring" --verify "${script_dir}/SHA256SUMS-${sha_suffix}.gpg" "${script_dir}/SHA256SUMS-${sha_suffix}" 2>/dev/null
        if [ $? -ne 0 ]; then
                rm -f "${script_dir}/${ubuntu_gpg_key_id}.keyring~"
                die "👿 Verification of SHA256SUMS signature failed."
        fi

        rm -f "${script_dir}/${ubuntu_gpg_key_id}.keyring~"
        digest=$(sha256sum "${source_iso}" | cut -f1 -d ' ')
        set +e
        grep -Fq "$digest" "${script_dir}/SHA256SUMS-${sha_suffix}"
        if [ $? -eq 0 ]; then
                log "👍 Verification succeeded."
                set -e
        else
                die "👿 Verification of ISO digest failed."
        fi
else
        log "🤞 Skipping verification of source ISO."
fi


log "🔧 Extracting ISO image..."
if [ ${release_name} == "focal" ]; then
     xorriso -osirrox on -indev "${source_iso}" -extract / "$tmpdir" &>/dev/null
     rm -rf "$tmpdir/"'[BOOT]'
else
     7z -y x ${source_iso} -o"$tmpdir" &>/dev/null
     [[ -d "$bootdir" ]] &&  rm -rf "$bootdir"
     mv $tmpdir/'[BOOT]' "${bootdir}"
fi
chmod -R u+w "$tmpdir"
log "👍 Extracted to $tmpdir"

if [ ${packages_name} -eq 1 ]; then
  # Create an mnt directory in the $tmpdir directory for other files
  mkdir -p $tmpdir/mnt/{packages,script}
  pkgs_destination_dir="$tmpdir/mnt/packages"
  exec_script_dir="$tmpdir/mnt/script/"
  script_file="install-pkgs.sh"

  # customer script is used to install dependency packages
  grep -Ev '^#|^$' $file_name > $tmpdir/$file_name
  read_file=$(cat $tmpdir/$file_name)
       [ -d "${pkgs_destination_dir}" ] || mkdir -p "${pkgs_destination_dir}"
       for line in $read_file; do
         log "🌎 Downloading and saving packages ${line}"
         apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances \
         --no-pre-depends ${line} | grep -v i386 | grep "^\w") &>/dev/null
         mv ${script_dir}/*.deb ${pkgs_destination_dir}
         log "👍 Downloaded and saved the ${line} packages to ${pkgs_destination_dir}/${line}"
       done
        #创建本地软件源的index文件:
        cd ${pkgs_destination_dir}
        dpkg-scanpackages ./  &>/dev/null  | gzip -9c > Packages.gz
        apt-ftparchive packages ./ > Packages
        apt-ftparchive release ./ > Release

        echo '#!/bin/bash' > ${script_file}
        echo "# The default installation package will be downloaded to /cdrom/mnt/packages/ directory" >> ${script_file}
        echo "cp /etc/apt/sources.list /etc/apt/sources.list.bak" >> ${script_file}
        echo 'echo 'deb [trusted=yes] file:///mnt/packages/   ./' > /etc/apt/sources.list' >> ${script_file}
        echo 'apt-get update' >> ${script_file}
        for name in $read_file; do
          echo "apt-get install -y ${name}" >> ${script_file}
        done

        if [ "${script_file##*.}"x = "sh"x ];then
             chmod +x "$script_file"
             mv "$script_file"  "$exec_script_dir"
        else
             die "👿 Verification of script file failed."
        fi
        cd  ${script_dir}

        log "🧩 Adding config-data files..."
        if [ -n "$config_data_file" ]; then
            chmod +x "$config_data_file"
            cp -rp  "$config_data_file" "$exec_script_dir"
        else
            echo "No $meta_data_file config profile available."
        fi

        log "🧩 Adding template-config files..."
        if [ -n "$temaplate_config_file" ]; then
            cp -rp  "$temaplate_config_file" "$tmpdir/mnt"
        else
            echo "No $meta_data_file template profile available."
        fi

        rm $tmpdir/$file_name
        log "🚽 Deleted temporary file $tmpdir/$file_name."
fi

if [ ${all_in_one_job} -eq 1  ];then
  cp -p ${job_name}  $tmpdir
  cp rc-local.service $tmpdir
  log "📁 Moving ${job_name} file to temporary working directory $tmpdir/mnt/script."
fi

if [ ${service_dir} -eq 1  ];then
  [[ ! -d ${service_dir_name} ]] && die "👿 ${service_dir_name} is not a legal directory."
  varible=${service_dir_name}
  cp -rp ${varible%%/}  $tmpdir/mnt/
  log "📁 Moving ${varible%%/} directory to temporary working directory $tmpdir/mnt/ "
fi

if [ ${use_hwe_kernel} -eq 1 ]; then
        if grep -q "hwe-vmlinuz" "$tmpdir/boot/grub/grub.cfg"; then
                log "☑️ Destination ISO will use HWE kernel."
                sed -i -e 's|/casper/vmlinuz|/casper/hwe-vmlinuz|g' "$tmpdir/boot/grub/grub.cfg"
                sed -i -e 's|/casper/initrd|/casper/hwe-initrd|g' "$tmpdir/boot/grub/grub.cfg"

                if [ ${release_name} == "focal" ]; then
                        sed -i -e 's|/casper/vmlinuz|/casper/hwe-vmlinuz|g' "$tmpdir/isolinux/txt.cfg"
                        sed -i -e 's|/casper/initrd|/casper/hwe-initrd|g' "$tmpdir/isolinux/txt.cfg"
                        sed -i -e 's|/casper/vmlinuz|/casper/hwe-vmlinuz|g' "$tmpdir/boot/grub/loopback.cfg"
                        sed -i -e 's|/casper/initrd|/casper/hwe-initrd|g' "$tmpdir/boot/grub/loopback.cfg"
                fi
        else
                log "⚠️ This source ISO does not support the HWE kernel. Proceeding with the regular kernel."
        fi
fi

log "🧩 Adding autoinstall parameter to kernel command line..."
grep 'autoinstall' "$tmpdir/boot/grub/grub.cfg" &>/dev/null || sed -i -e 's/---/quiet autoinstall  ---/g' "$tmpdir/boot/grub/grub.cfg"
if [ ${release_name} == "focal" ]; then
        grep 'autoinstall' "$tmpdir/boot/grub/loopback.cfg" &>/dev/null || sed -i -e 's/---/quiet autoinstall  ---/g' "$tmpdir/boot/grub/loopback.cfg"
        grep 'autoinstall' "$tmpdir/isolinux/txt.cfg" &>/dev/null || sed -i -e 's/---/quiet autoinstall  ---/g' "$tmpdir/isolinux/txt.cfg"
fi

log "👍 Added parameter to UEFI and BIOS kernel command lines."

# create user-data.yml and meta-data, then change grub.cfg file
if [ ${all_in_one} -eq 1 ]; then
        log "🧩 Adding user-data and meta-data files..."
        #mkdir "$tmpdir/nocloud"
        cp "$user_data_file" "$tmpdir/user-data"
        if [ -n "${meta_data_file}" ]; then
                cp "$meta_data_file" "$tmpdir/meta-data"
        else
                touch "$tmpdir/meta-data"
        fi
        grep 'cdrom' "$tmpdir/boot/grub/grub.cfg" &>/dev/null || sed -i -e 's,---, ds=nocloud\\\;s=/cdrom/  ---,g' "$tmpdir/boot/grub/grub.cfg"
        if [ ${release_name} == "focal" ]; then
                grep 'cdrom' "$tmpdir/isolinux/txt.cfg"  &>/dev/null || sed -i -e 's,---, ds=nocloud;s=/cdrom/  ---,g' "$tmpdir/isolinux/txt.cfg"
                grep 'cdrom' "$tmpdir/boot/grub/loopback.cfg" &>/dev/null || sed -i -e 's,---, ds=nocloud\\\;s=/cdrom/  ---,g' "$tmpdir/boot/grub/loopback.cfg"
        fi
        log "👍 Added data and configured kernel command line."
fi

# Update the md5 value of the grub.cfg file
if [ ${md5_checksum} -eq 1 ]; then
        log "👷 Updating $tmpdir/md5sum.txt with hashes of modified files..."
        md5=$(md5sum "$tmpdir/boot/grub/grub.cfg" | cut -f1 -d ' ')
        sed -i -e 's,^.*[[:space:]] ./boot/grub/grub.cfg,'"$md5"'  ./boot/grub/grub.cfg,' "$tmpdir/md5sum.txt"
        if [ ${release_name} == "focal" ]; then
                md5=$(md5sum "$tmpdir/boot/grub/loopback.cfg" | cut -f1 -d ' ')
                sed -i -e 's,^.*[[:space:]] ./boot/grub/loopback.cfg,'"$md5"'  ./boot/grub/loopback.cfg,' "$tmpdir/md5sum.txt"
        fi
        log "👍 Updated hashes."
else
        log "🗑️ Clearing MD5 hashes..."
        echo > "$tmpdir/md5sum.txt"
        log "👍 Cleared hashes."
fi

log "📦 Repackaging extracted files into an ISO image..."
cd "$tmpdir"
# Check if the iso image format is correct
if [ "${destination_iso##*.}"x = "iso"x ];then
	if [ ${release_name} == "focal" ]; then
  xorriso -as mkisofs -r \
       -V "ubuntu-autoinstall-${release_name}" \
       -J -b isolinux/isolinux.bin \
       -c isolinux/boot.cat \
       -no-emul-boot \
       -boot-load-size 4 \
       -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
       -boot-info-table \
       -input-charset utf-8 \
       -eltorito-alt-boot \
       -e boot/grub/efi.img \
       -no-emul-boot \
       -isohybrid-gpt-basdat \
       -o "${destination_iso}" \
       . &>/dev/null
  else
  xorriso -as mkisofs -r \
       -V "ubuntu-autoinstall-${release_name}" \
       -o "${destination_iso}" \
       --grub2-mbr ../BOOT/1-Boot-NoEmul.img \
       -partition_offset 16 \
       --mbr-force-bootable \
       -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b ../BOOT/2-Boot-NoEmul.img \
       -appended_part_as_gpt \
       -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
       -c '/boot.catalog' \
       -b '/boot/grub/i386-pc/eltorito.img' \
         -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
       -eltorito-alt-boot \
       -e '--interval:appended_partition_2:::' \
       -no-emul-boot \
       . &>/dev/null
  fi
else
	die "👿 Verification of iso image format is failed."
fi

cd "$OLDPWD"
log "👍 Repackaged into ${destination_iso}"
die "✅ Completed." 0