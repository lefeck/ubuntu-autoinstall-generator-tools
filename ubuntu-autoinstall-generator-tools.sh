#!/bin/bash
set -Eeuo pipefail

function cleanup() {
        trap - SIGINT SIGTERM ERR EXIT
        if [ -n "${tmpdir+x}" ]; then
                rm -rf "$tmpdir" "$bootdir"
                log "🚽 Deleted temporary working directory $tmpdir"
        fi
}

trap cleanup SIGINT SIGTERM ERR EXIT

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
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-a] [-e] [-u user-data-file] [-m meta-data-file] [-k] [-c] [-r] [-s source-iso-file] [-d destination-iso-file]

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
-k, --no-verify         Disable GPG verification of the source ISO file. By default SHA256SUMS-$today and
                        SHA256SUMS-$today.gpg in ${script_dir} will be used to verify the authenticity and integrity
                        of the source ISO file. If they are not present the latest daily SHA256SUMS will be
                        downloaded and saved in ${script_dir}. The Ubuntu signing key will be downloaded and
                        saved in a new keyring in ${script_dir}
-c, --no-md5            Disable MD5 checksum on boot
-r, --use-release-iso   Use the current release ISO instead of the daily ISO. The file will be used if it already
                        exists.
-d, --destination       Destination ISO file. By default ${script_dir}/ubuntu-autoinstall-$today.iso will be
                        created, overwriting any existing file.
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

        while :; do
                case "${1-}" in
                -h | --help) usage ;;
                -v | --verbose) set -x ;;
                -a | --all-in-one) all_in_one=1 ;;
                -e | --use-hwe-kernel) use_hwe_kernel=1 ;;
                -c | --no-md5) md5_checksum=0 ;;
                -k | --no-verify) gpg_verify=0 ;;
                -r | --use-release-iso) use_release_iso=0 ;;
                -n | --release-name)
                        release_name="${2-}"
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

# create user-data and meta-data, then change grub.cfg file
if [ ${all_in_one} -eq 1 ]; then
        log "🧩 Adding user-data and meta-data files..."
        mkdir "$tmpdir/nocloud"
        cp "$user_data_file" "$tmpdir/nocloud/user-data"
        if [ -n "${meta_data_file}" ]; then
                cp "$meta_data_file" "$tmpdir/nocloud/meta-data"
        else
                touch "$tmpdir/nocloud/meta-data"
        fi
        grep 'cdrom' "$tmpdir/boot/grub/grub.cfg" &>/dev/null || sed -i -e 's,---, ds=nocloud\\\;s=/cdrom/nocloud/  ---,g' "$tmpdir/boot/grub/grub.cfg"
        if [ ${release_name} == "focal" ]; then
                grep 'cdrom' "$tmpdir/isolinux/txt.cfg"  &>/dev/null || sed -i -e 's,---, ds=nocloud;s=/cdrom/nocloud/  ---,g' "$tmpdir/isolinux/txt.cfg"
                grep 'cdrom' "$tmpdir/boot/grub/loopback.cfg" &>/dev/null || sed -i -e 's,---, ds=nocloud\\\;s=/cdrom/nocloud/  ---,g' "$tmpdir/boot/grub/loopback.cfg"
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
cd "$OLDPWD"
log "👍 Repackaged into ${destination_iso}"

die "✅ Completed." 0