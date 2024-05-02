die() {
    echo "$1" >&2
    exit
}

debug() {
    if [[ "$VERBOSE" -ne 0 ]]; then
	echo "$@" >&2
    fi
}

log() {
    echo "$@" >> "$LOGFILE"
}

check_os() {
    if [ $(uname) == "Linux" ]; then
	os=linux
    elif [ $(uname) == "OpenBSD" ]; then
	os=obsd
    else die "OS should be Linux or OpenBSD"
    fi
}

define_distro() {
# store result in variable '$distro'
    if [ -f /etc/redhat-release ] ; then
	distro=rh
    elif [ -f /etc/debian_version ] ; then
	distro=debian
    elif [ -f /etc/alpine-release ] ; then
	distro=alpine
    else die "Distro should be RedHat or Debian based or Alpine"
    fi
}

install_packages() {
    pkgs="unbound dhcpd hostapd"
    case "$distro" in
	debian*)
	    apt upgrade
	    apt update
	    apt install isc-dhcp-server unbound hostapd
	    ;;
	rh*)
	    yum update -y
	    yum install -y dhcp-server hostapd unbound
	    ;;
	alpine*)
	    apk upgrade
	    apk update
	    apk add ${pkgs}
	    ;;
    esac
}

check_packet_forwarding() {
    case "$os" in
	obsd*)
	    if [[ $(sysctl net.inet.ip.forwarding) != "net.inet.ip.forwarding=1" ]]; then
		# echo $(sysctl net.inet.ip.forwarding)
		return 1
	    else
		return 0
	    fi
	    ;;
	linux*)
	    if [[ $(cat /proc/sys/net/ipv4/ip_forward) -ne 1 ]]; then
		# cat /proc/sys/net/ipv4/ip_forward
		return 1
	    else
		return 0
	    fi
	    ;;
    esac
}

allow_packet_forwarding() {
    case "$os" in
	obsd*)
	    echo "net.inet.ip.forwarding=1" > /etc/sysctl.conf
	    sysctl net.inet.ip.forwarding=1
	    echo $(sysctl net.inet.ip.forwarding)
	    ;;
	linux*)
	    echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/10-net.conf
	    sysctl -p /etc/sysctl.d/10-net.conf
	    cat /proc/sys/net/ipv4/ip_forward
	    ;;
    esac
}

#  $1 = service
find_config_path() {
    case "$os" in
	linux*)
	    path=$(head -1 ../conf/$1.conf | cut -d ' ' -f2)
	    debug "$1 path is: $path"
	    echo "$path"
	    ;;
	obsd*)
	    path=$(head -2 ../conf/$1.conf | tail -1 |  cut -d ' ' -f2)
	    debug "$1 path is: $path"
	    echo "$path"
	    ;;
    esac
}

# $1 = service
install_config() {
    config_path=$(find_config_path "$1")
    cat ../conf/$1.conf | envsubst > "$config_path"
}

# $1 = service
backup_config() {
    config_path=$(find_config_path "$1")
    mkdir -p "$BACKUP_DIR"
    tar czvf "$BACKUP_DIR/$1_conf.tgz" "$config_path"
}

apply_fw_rules() {
        case "$os" in
	linux*)
		case "$distro" in
		    rh*)
			fw_config=/etc/sysconfig/nftables.conf;;
		    debian*)
			fw_config=/etc/nftables.conf;;
		    *)
			fw_config=/etc/nftables.conf;;
		esac

		cat ../conf/nftables.conf | envsubst > "$fw_config"
		nft -cf "$fw_config"
	    ;;
	obsd*)
		cat ../conf/pf.conf | envsubst > /etc/pf.conf
		pfctl -nf /etc/pf.conf
	    ;;
	esac
}

start_services() {
        case "$os" in
	linux*)
		case "$distro" in
		    rh*)
			systemctl start dhcpd hostapd nftables unbound;;
			#systemctl enable --now dhcpd hostapd nftables unbound;;
		    debian*)
			systemctl unmask hostapd
			systemctl start hostapd isc-dhcp-server nftables unbound;;
			#systemctl enable --now hostapd isc-dhcp-server nftables unbound;;
		    *)
			service dhcpd start
			service hostapd start
			service nftables start
			service unbound start;;
		esac
		;;
	obsd*)
		rcctl enable dhcpd unbound
		rcctl start dhcpd unbound
		pfctl -f /etc/pf.conf
		;;
	esac
}

#prepare_dhcpd_conf() {
#    # get .0 and .255 addresses from given $LOCAL_NET
#}
