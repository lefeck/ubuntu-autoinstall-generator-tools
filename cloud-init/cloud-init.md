# cloud-init

cloud-init is an open-source tool for customizing cloud instances, allowing users to automatically configure them at boot time. cloud-init provides a predictable and reproducible method for the initial creation and startup process using pre-defined configuration files (user-data). This ensures that operations such as setting hostnames, adding users, groups, security keys, installing packages, and running custom scripts can be performed automatically when starting a new instance.

The main functions of cloud-init include:

1. **System Configuration**: Automatically configure the operating system based on the provided user-data file. This includes setting hostnames, timezones, SSH keys, network settings, etc.
2. **User Management**: Add, modify, or remove users and assign relevant permissions based on the instructions in the user-data file.
3. **Software Installation and Updates**: Install specified packages, run operating system updates, or perform other software-related configurations during instance startup.
4. **Execution of Custom Commands**: The user-data file can contain commands that are to be executed only once during the initial startup of the system. This allows you to customize the instance to meet specific needs.
5. **Integration with Other Tools**: cloud-init can work in conjunction with other tools, such as tools for configuring system storage (eg. LVM or RAID), tools for deploying applications, etc. Thanks to its modular architecture, cloud-init can be easily extended.

cloud-init is widely used for virtual machine instances and bare metal servers on platforms such as Amazon Web Services (AWS), Microsoft Azure, Google Cloud Platform, OpenStack, VMware, and others. It is generally included by default in most Linux distributions such as Ubuntu, CentOS, Debian, Fedora, and Red Hat.

When using Ubuntu's autoinstall feature, autoinstall and cloud-init can be used in conjunction. autoinstall primarily handles the automatic installation process of the operating system, while cloud-init provides configuration and customization commands to be run after the installation is complete and when the instance is first started.

## runcmd example

```yaml
#cloud-config
autoinstall:
  version: 1
  apt:
    primary:
      - arches: [default]
        uri: http://archive.ubuntu.com/ubuntu
  identity:
    hostname: ubuntu
    realname: ubuntu-server
    username: ubuntu
    password: your-password-hash
  keyboard:
    layout: 'us'
    variant: ''
  locale: 'en_US.UTF-8'
  network:
    network:
      version: 2
      ethernets:
        ens160:
          dhcp4: true
  user-data:
    runcmd:
      - [apt-get, update]
      - [apt-get, install, --yes, nginx]
      - [ ls, -l, / ]
      - [ sh, -xc, "echo $(date) ': hello world!'" ]
      - [ sh, -c, echo "=========hello world=========" ]
      - ls -l /root
      # Note: Don't write files to /tmp from cloud-init use /run/somedir instead.
      # Early boot environments can race systemd-tmpfiles-clean LP: #1707222.
      - mkdir /opt/mydir
      # execute test.sh script file
      - /root/test.sh
```

In this example, we define the users and runmd sections in user-data under the autoinstall section. This allows autoinstall to handle these sections correctly during the instance boot process. Note that for cloud-init configurations that are bootstrapping the instance for the first time, they should be placed within the user-data of the autoinstall section, not in the root-level user-data.