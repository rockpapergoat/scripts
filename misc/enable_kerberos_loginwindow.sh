#!/bin/bash
# cf. http://support.apple.com/kb/HT4100
# modify /etc/authorization to generate kerberos tickets on login
# 110809, nate@tsp

# date stamp
stamp=`date +%Y%m%d`
# backup the existing /etc/authorization, just in case
/bin/cp -v /etc/authorization{,.$stamp}
# add the line to enable krb tickets at login
/usr/libexec/PlistBuddy /etc/authorization -c "add rights:system.login.console:mechanisms: string "builtin:krb5store,privileged""
