#!/bin/bash
# 101112, nate@tsp
# set 802.1x login profile for 10.5 machines

#set some variables for commands
buddy=/usr/libexec/PlistBuddy

# prefs
prefs=/Library/Preferences/SystemConfiguration/preferences
uuid=`uuidgen`
profilename="LoginProfile"

# get the UUID of the current network or location set
currentuuid=`defaults read $prefs CurrentSet | awk -F"/" '/Sets/ {print $NF}'
`
# let's begin
# verify we're running as root; quit if not
if [[ "$(id -u)" != "0" ]]; then
	cat <<EOF
	you must run this as root.
	quitting now...	
EOF
exit 1
else
echo "writing the prefs"
# write the prefs
$buddy -c "Add :Sets:$currentuuid:Network:Interface:en0:EAPOL.LoginWindow dict" $prefs.plist
$buddy -c "Add :Sets:$currentuuid:Network:Interface:en0:EAPOL.LoginWindow:$uuid dict" $prefs.plist
$buddy -c "Add :Sets:$currentuuid:Network:Interface:en0:EAPOL.LoginWindow:$uuid:EAPClientConfiguration dict" $prefs.plist
$buddy -c "Add :Sets:$currentuuid:Network:Interface:en0:EAPOL.LoginWindow:$uuid:EAPClientConfiguration:AcceptEAPTypes array" $prefs.plist
$buddy -c "Add :Sets:$currentuuid:Network:Interface:en0:EAPOL.LoginWindow:$uuid:EAPClientConfiguration:AcceptEAPTypes:0 integer 25" $prefs.plist
$buddy -c "Add :Sets:$currentuuid:Network:Interface:en0:EAPOL.LoginWindow:$uuid:UniqueIdentifier string $uuid" $prefs.plist
$buddy -c "Add :Sets:$currentuuid:Network:Interface:en0:EAPOL.LoginWindow:$uuid:UserDefinedName string $profilename" $prefs.plist

# check the set
defaults read $prefs
fi