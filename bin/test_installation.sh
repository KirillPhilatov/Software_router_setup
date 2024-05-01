#!/bin/sh

VERBOSE=1

export e="`echo x | tr x '\033'`"
export red="${e}[31m"
export green="${e}[32m"
export yellow="${e}[33m"
export blue="${e}[34m"
export magenta="${e}[35m"
export cyan="${e}[36m"
export white="${e}[37m"
export end="${e}[0m"

test_failed() {
    echo -e ${red} Test failed: "${end}" "$@"
}


test_passed() {
    echo -e ${green} Test passed: "${end}" "$@"
}


cd $(dirname $0)

. ./funcs.sh

check_os

# check forwarding is allowed
if check_packet_forwarding; then
    test_passed "Packet forwarding is allowed"
else
    test_failed "Packet forwarding not allowed"    
fi

# check configs are installed
# check processes are running

for service in "dhcpd" "hostapd" "unbound"; do
    config_path=$(find_config_path "$service")
    debug $config_path
    [[ -f $config_path ]] && test_passed "Config for $service is installed" || test_failed "Config for $service is not installed"
    [[ $(ps axu | grep -i "$service" | grep -v grep) ]] && test_passed "$service is running" || test_failed "$service is not running"
done

# check firewall rules
