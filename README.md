# Description

This setup gives you a very basic router on OpenBSD, Debian or RHEL based distros.

It's based on [Unbound](https://man.openbsd.org/unbound), [DHCPD](https://www.isc.org/dhcp/) and [Hostapd](http://w1.fi/hostapd/).

It uses [PF](https://www.openbsd.org/faq/pf/) on OpenBSD and [Nftables](https://www.nftables.org/) on Linux.

You don't need any third party packages on OpenBSD.

In addition to this setup you can use pretty cool tools like [dnsblockbister](https://github.com/ahmedalazazy/dnsblockbuster) or [unbound-adblock](https://www.geoghegan.ca/unbound-adblock.html). 

Config files templates are in conf directory, you can customize it there before running install script.

Setup is aimed for home usage, like on Raspberry Pi or something like that.

## Usage

- Clone this repo

- Edit ./bin/vars.sh for your needs

- Run ./bin/install.sh

- Check installation by running ./bin/test_installation.sh

- Check firewall rules cause it's buggy part of install script due to variables interpolation inside firewalls configs

## Links 

Really comprehensive guide for setting up router on OpenBSD:

https://openbsdrouterguide.net/

## Disclaimer

This software is not a software. It's just a backup of my configs :-)

Hostapd config is for Linux only. OpenBSD implementation has different syntax.
