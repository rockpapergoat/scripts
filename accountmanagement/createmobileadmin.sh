#!/bin/bash
# 5/23/10, create a mobile account (phd) that is also hidden and a local admin
# 7/20/10, added casper user to hidden array; changed account and server URL
#
createmobile=/System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount
# set variables (note the presense of a password in plain text again)
account=joe_mamma
password="you should know this"
homedirserver=afp://od.server.company.com/homes/$account
# create the account
eval $createmobile -n $account -v -h /var/$account -S # omitted -p $password
# set a couple of other variables
uid=`/usr/bin/dscl . -read /users/$account UniqueID | awk '{print $2}'`
home=`/usr/bin/dscl . -read /users/$account NFSHomeDirectory | awk '{print $2}'`
# hide and add to admin
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool TRUE
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array "${account}" casper
/usr/bin/dscl . append /groups/admin GroupMembership "${account}"
if [ $uid -gt 500 ]; then
        /usr/bin/dscl . -change /users/$account UniqueID $uid 499
        /usr/sbin/chown -Rf $account:staff $home
        /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool true
        /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array $account casper
        else if [ $uid -lt 500 ]; then
                echo "nothing to do. user already has a <500 uid."
        fi
fi