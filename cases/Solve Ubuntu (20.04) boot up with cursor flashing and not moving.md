
# problem

When switching on and off, or rebooting, the waiting time is very long, about 1 minute 30 seconds, and there is a cursor flashing.


## Cause1
A flashing cursor is a simplification of a series of activities in the background. It indicates that there is a series of activities going on in the background that we just can't see.

## Solutions2
we should be chang grub file and save it,  and rebooting, we will see the action in the background. when switching on and off
```shell
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=""/g' /etc/default/grub
update-grub
```
## Cause2
Switching on and off to wait for a long time, may be the background to open or close some programs, these programs spend time is the default time set by the system, about 90 seconds, only to 90 seconds the system can open or close.

## Solutions2
we should be change system.conf file and reload configuration
```shell
# change system.conf file to reduce the time spent switching on and off
sed -i 's/^#\?DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=30s/g' /etc/systemd/system.conf
sed -i 's/^#\?DefaultTimeoutStartSec=.*/DefaultTimeoutStartSec=30s/g' /etc/systemd/system.conf
# reload configuration
systemctl daemon-reload 
```
* note: DefaultTimeoutStopSec and DefaultTimeoutStartSec must be set to a reasonable value to ensure that the operating system's default process is up，otherwise, the following error will be reported.
```shell
[Aug 2 04:18] audit: type=1400 audit(1659413905.466:2103): apparmor="STATUS" operation="profile_load" profile="unconfined" name="demo" pid=3068586 comm="apparmor_parser"
```