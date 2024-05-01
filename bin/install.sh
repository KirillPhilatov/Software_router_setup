#!/bin/sh

# cd to this script dir
cd $(dirname $0)
. ./funcs.sh
. ./vars.sh

debug $(pwd)

[ $(id -u) -eq 0 ] || die "Must be root"

check_os
debug "OS is $os"

if [ ${os} == "linux" ]; then
    define_distro
    debug "Distro is $distro"
    install_packages
fi

if check_packet_forwarding; then
    debug "Packet forwarding allowed, going futher"
else
    debug "Packet forwarding is not allowed, allowing..."
    allow_packet_forwarding
fi

for service in "dhcpd" "hostapd" "unbound"; do
    backup_config "$service"
    install_config "$service"
done

apply_fw_rules

start_services
