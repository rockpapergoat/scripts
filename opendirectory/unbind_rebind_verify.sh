#!/usr/bin/env bash
# 101102, nate@tsp, unbind, rebind, remove mcx, remove managed prefs, verify, etc.

# set a few variables
PATH="/usr/sbin:/usr/bin:/usr/local/bin:/bin"
OD="name.of.odmaster.com"
prefs="/Library/Managed Preferences"

# unbind from old OD servers, if any, and remove
echo "unbinding from any old OD server, if any..."
for ds in $(dscl localhost -list /LDAPv3| egrep "10.10.10.10|old.odmaster.com")
	do
		dsconfigldap -f -r "${ds}"
		dscl /Search -delete / CSPSearchPath /LDAPv3/"${ds}"
		dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/"${ds}"
		killall -HUP DirectoryService
	done

# verify output
echo "verifying removal..."
verify=`dscl localhost -list /LDAPv3`
echo $verify

# bind to new od master
# note: $4 is passed via casper, so running the script manually will need the password 
# in the script or passed in some other way
echo "binding to the new OD server..."
dsconfigldap -v -f -a name.of.odmaster.com -n name.of.odmaster.com -c $HOSTNAME -u diradmin -p $4
dscl -q localhost -create /Search SearchPolicy dsAttrTypeStandard:CSPSearchPath
dscl -q localhost -merge /Search CSPSearchPath /LDAPv3/name.of.odmaster.com
dscl -q localhost -create /Contact SearchPolicy dsAttrTypeStandard:CSPSearchPath
dscl -q localhost -merge /Contact CSPSearchPath /LDAPv3/name.of.odmaster.com
killall -HUP DirectoryService

# cleanup anything in /Libraty/Managed Preferences and homesync prefs in users' homes
if [[ -d $prefs ]]; then
	echo "removing anything under $prefs"
	rm -Rfv $prefs/*
	else
	echo "no prefs directory to purge"
fi

# remove the homesync prefs, if any
echo "removing any homesync prefs for existing users..."
for homedir in `ls /Users/ | egrep -v ".localized|Shared"`; do
	homesync="/Users/$homedir/Library/Preferences/com.apple.homeSync.plist"
	if [[ -e $homesync ]]; then
		rm -fv $homesync
		else
		echo "no homesync pref to remove for $homedir. proceeding..."
	fi
	# remove any local mcx prefs for the user record, just in case
	echo "removing any mcx for locally cached accounts..."
	echo "first, here are the existing homesync prefs, if any:"
	dscl . -mcxread /users/$homedir com.apple.homeSync
	echo "then we'll delete anything there."
	dscl . -mcxdelete /users/$homedir com.apple.homeSync
	echo "verifying mcx change.."
	dscl . -mcxread /users/$homedir
done



# verify lookups by checking an account that only exists in OD if this returns false, you'll have to rebind
if [[ `dscl /Search -read /Users/bindtest UniqueID | awk '{print $2}'` == 1025 ]]; then
		echo "you're bound to: $verify"
	else echo "lookup failed. try binding again."
fi