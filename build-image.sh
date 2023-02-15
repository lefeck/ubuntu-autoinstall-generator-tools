#!/bin/bash
#

bash -x  ubuntu-autoinstall-generator-tools.sh  -a  -u user-data-kvm-esxi.yml -n jammy -p package-name.txt -c example/config-kvm.sh \
  -j rc-kvm.local -t sliver-peak-template.xml  -s /root/service -d ubuntu-autoinstall-jammytest.iso