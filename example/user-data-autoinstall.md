
#  user-data file 

Only for Ubuntu Server 22.04

Here's an example template for user-data, detailing the meaning of the parameters.

```yaml
#cloud-config
autoinstall:
  # see below
  apt:
    disable_components: []
    fallback: abort
    geoip: true
    mirror-selection:
      primary:
      - country-mirror
      - arches:
        - amd64
        - i386
        uri: http://archive.ubuntu.com/ubuntu
      - arches:
        - s390x
        - arm64
        - armhf
        - powerpc
        - ppc64el
        - riscv64
        uri: http://ports.ubuntu.com/ubuntu-ports
    preserve_sources_list: false
  # Configure whether common restricted packages (including codecs) from [multiverse] should be installed.
  codecs:
    # Whether to install the ubuntu-restricted-addons package. default: false
    install: false
  drivers:
    # Whether to install the available third-party drivers. default: false
    install: false
  # Configure the initial user for the system. This is the only config key that must be present  
  identity:
    # The hostname for the system.
    hostname: ubuntu
    # The password for the new user, encrypted. This is required for use with sudo, even if SSH access is configured.
    # Several tools can generate the crypted password, such as mkpasswd from the whois package, or openssl passwd.
    password: $6$UaYkPo9lJVLZkPV/$SHAjurdVTP24Ftw2Y07KaXiwpQKgSTfws9bsyZ7UjaB5mafATxh0WqGEg1iki9/s0u0ob2coeJRQ8MYM72tCr1
    realname: ubuntu
    # The user name to create.
    username: ubuntu
  # Which kernel gets installed. Either the name of the package or the name of the flavor must be specified.  
  kernel:
    # The name of the package, e.g., linux-image-5.13.0-40-generic
    package: linux-generic
  # Controls whether the installer updates to a new version available in the given channel before continuing.
  refresh-installer:
    # Whether to update or not. default: no
    update: no
    # The channel to check for updates.
    channel: "stable/ubuntu-$REL"
  keyboard:
    layout: us
    toggle: null
    variant: ''
  # The locale to configure for the installed system. default: en_US.UTF-8
  locale: en_US.UTF-8
  # see below
  network:
    ethernets:
      ens160:
        addresses:
          - 192.168.10.103/24
        nameservers:
          addresses:
            - 114.114.114.114
            - 8.8.8.8
          search: []
        routes:
          - to: default
            via: 192.168.10.1
    version: 2
  source:
    # default: identifier of the first available source.
    # Identifier of the source to install (e.g., "ubuntu-server-minimized").
    id: ubuntu-server
    # Whether the installer should search for available third-party drivers. When set to false, it disables the drivers screen and section. default: true
    search_drivers: false
  # Configure SSH for the installed system. A mapping that can contain keys: 
  ssh:
    # Whether to allow password login host. if authorized_keys is empty, allow-pw is true, otherwise false. default: true 
    allow-pw: true
    # A list of SSH public keys to install in the initial user’s account. default: []
    authorized-keys: []
    # Whether to install OpenSSH server in the target system. default: false 
    install-server: true
  storage:
    config:
      # Partition table
      - { ptable: gpt, path: /dev/sda, wipe: superblock-recursive, preserve: false, name: '', grub_device: true,type: disk, id: disk-sda }
      - { device: disk-sda, size: 1048576, flag: bios_grub, number: 1, preserve: false, grub_device: false, offset: 1048576, type: partition, id: partition-0 }
      # Linux boot partition size 2G
      - { device: disk-sda, size: 2147483648, wipe: superblock, number: 2, preserve: false, grub_device: false, offset: 2097152, type: partition, id: partition-1 }
      - { fstype: ext4, volume: partition-1, preserve: false, type: format, id: format-0 }
      # Partition for LVM, VG
      - { device: disk-sda, size: -1, wipe: superblock, number: 3, preserve: false, grub_device: false, offset: 2149580800, type: partition, id: partition-2 }
      - { name: ubuntu-vg, devices: [ partition-2 ], preserve: false, type: lvm_volgroup, id: lvm_volgroup-0 }
      # Swap size 1G
      - { name: swap, volgroup: lvm_volgroup-0, size: 1073741824B, wipe: superblock, preserve: false, type: lvm_partition, id: lvm_partition-1 }
      - { fstype: swap, volume: lvm_partition-1, preserve: false, type: format, id: format-1 }
      # Remaining capacity size LV for the root partition
      - { name: ubuntu-lv, volgroup: lvm_volgroup-0, size: -1, wipe: superblock, preserve: false, type: lvm_partition, id: lvm_partition-0 }
      - { fstype: ext4, volume: lvm_partition-0, preserve: false, type: format, id: format-2 }
      # Mount points
      - { path: /, device: format-2, type: mount, id: mount-2 }
      - { path: '', device: format-1, type: mount, id: mount-1 }
      - { path: /boot, device: format-0, type: mount, id: mount-0 }
    swap:
      swap: 0
  # The type of updates that will be downloaded and installed after the system install. default: security, Supported values are:
  #   security -> download and install updates from the -security pocket
  #   all -> also download and install updates from the -updates pocket
  updates: security
  # Request the system to power off or reboot automatically after the installation has finished. default: reboot
  # Supported values are:
  # - reboot
  # - poweroff
  shutdown: reboot
  # A future-proofing config file version field. Currently this must be “1”.
  version: 1
  packages:
      - bash-completion
      - wget
      - net-tools
```

## apt section

Apt configuration, used both during the install and once booted into the target system.

This section historically used the same format as curtin, which is documented here. Nonetheless, some key differences with the format supported by curtin have been introduced:

* Subiquity supports an alternative format for the primary section, allowing to configure a list of candidate primary mirrors. During installation, subiquity will automatically test the specified mirrors and select the first one that seems usable. This new behavior is only activated when the primary section is wrapped in the mirror-selection section.
* The fallback key controls what subiquity should do if no primary mirror is usable.
* The geoip key controls whether a geoip lookup is done to determine the correct country mirror.

The default is as follows, which can be ignored
```yaml
apt:
    preserve_sources_list: false
    mirror-selection:
      primary:
      - country-mirror
      - arches: [i386, amd64]
        uri: "http://archive.ubuntu.com/ubuntu"
      - arches: [s390x, arm64, armhf, powerpc, ppc64el, riscv64]
        uri: "http://ports.ubuntu.com/ubuntu-ports"
    fallback: abort
    geoip: true
```

### mirror-selection
if the primary section is contained within the mirror-selection section, the automatic mirror selection is enabled. This is the default in new installations.



#### primary (when placed inside the mirror-selection section):

In the new format, the primary section expects a list of mirrors, which can be expressed in two different ways:

* the special value country-mirror
* a mapping with the following keys:
  - uri: the URI of the mirror to use, e.g., “http://fr.archive.ubuntu.com/ubuntu”
  - arches: an optional list of architectures supported by the mirror. By default, this list contains the current CPU architecture.

### fallback
default: abort

Controls what subiquity should do if no primary mirror is usable. Supported values are:

- abort -> abort the installation
- offline-install -> revert to an offline installation
- continue-anyway -> attempt to install the system anyway (not recommended, the installation will certainly fail)


## network section

[Netplan-formatted](https://netplan.readthedocs.io/en/stable/netplan-yaml/) network configuration.
A typical example would look like the following:
 ```yaml
 network:
   version: 2
   ethernets:
     ens160:
       addresses: # or [10.0.0.15/24, "2001:1::1/64"]
         - "10.0.0.15/24"
         - "2001:1::1/64"
       nameservers:
         search: # or [lab, home]
           - lab
           - home
         addresses: # or [8.8.8.8, "FEDC::1"]
           - 8.8.8.8
           - 114.114.114.114
       # Deprecated, gateway4: 10.0.0.1
       routes:
         - to: default
           via: 10.0.0.1

 ```

- version (number)

Defines what version of the configuration format is used. The only value supported is 2. Defaults to 2 if not defined.

- ⚠️ gateway4, gateway6 (scalar)

Deprecated, see Default routes. Set default gateway for IPv4/6, for manual address configuration. This requires setting addresses too. Gateway IPs must be in a form recognized by inet_pton(3). There should only be a single gateway per IP address family set in your global config, to make it unambiguous. If you need multiple default routes, please define them via routing-policy.