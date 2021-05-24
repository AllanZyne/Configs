# clear windows path
set -x PATH /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/games /usr/local/games /usr/bin/site_perl /usr/bin/vendor_perl /usr/bin/core_perl
set -ax PATH (wslpath -a "C:\Users\allan\AppData\Local\Programs\Microsoft VS Code\bin")

# VcXsrv
set -x DISPLAY (cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0

# Pulse(Audio)
#set -x PULSE_SERVER (cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
