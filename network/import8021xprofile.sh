#!/bin/bash
# 101109, nate@tsp
# imports 802.1x profile for primary ethernet interface
# this should work for 10.6 clients though may need to be modified for 10.5
# it will NOT work for 10.4 clients
#
# some helpful networksetup options:
# networksetup -enableloginprofile <service name> <profile name> <on off>
# networksetup -listalluserprofiles
# networksetup -getnetworkserviceenabled Ethernet
# networksetup -listallnetworkservices
# networksetup -getinfo Ethernet
# networksetup -export8021xLoginProfiles <service name> <file path> <include keychain items: yes no>

# test whether the profile was dropped in /etc first

# get the primary ethernet interface. this will most likely be called one of the following: Built-In Ethernet, Ethernet, or Ethernet 1
service=`/usr/sbin/networksetup -listallnetworkservices | /usr/bin/awk '/^.?[Ee]thernet?.1?$/'`
eth_enabled=`/usr/sbin/networksetup -getnetworkserviceenabled $service`
profile="/etc/802.1x.networkConnect"

# verify ethernet port is enabled; if not, enable it
if [[ eth_enabled = "Enabled" ]]; then
	/usr/bin/logger -t "802.1x importer" "primary ethernet is enabled. proceeding."
	else if
	[[ eth_enabled = "Disabled" ]]; then
		/usr/bin/logger -t "802.1x importer" "primary ethernet is disabled. enabling."
		/usr/sbin/networksetup -setnetworkserviceenabled $service on
	fi
fi

# verify the payload is under /etc
/usr/bin/logger -t "802.1x importer" "checking for export file"
if [[ -e $profile ]]; then
	/usr/bin/logger -t "802.1x importer" "found export file. importing now."
	/usr/sbin/networksetup -import8021xProfiles $service $profile
	/usr/bin/logger -t "802.1x importer" "enabling profile"
	/usr/sbin/networksetup -enableloginprofile $service $profile on
	/usr/bin/logger -t "802.1x importer" "verifying installed profiles"
	/usr/sbin/networksetup -listloginprofiles $service
	/usr/bin/logger -t "802.1x importer" "assuming the profile imported, we're done."
	else
		/usr/bin/logger -t "802.1x importer" "there's no export file to import. quitting now."
		exit 1
	fi
exit 0
