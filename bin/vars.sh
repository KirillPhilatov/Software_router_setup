VERBOSE=1
BACKUP_DIR=/usr/local/backup/

export LOCAL_NET="192.168.1.0/24"
export NETWORK_ADDR="${LOCAL_NET%/*}"
export NETMASK="255.255.255.0"
export GW_IP="192.168.1.1"
export BROADCAST="192.168.1.255"
export DHCP_RANGE="192.168.1.21 192.168.1.51"

export EXT_IF="eth0"
export SSH_ALLOWED="192.168.1.2"

export ESSID_NAME="Why Fi?"
export WPA_PASS="swordfishtrombone"
export WIFI_IF="wlan0"
