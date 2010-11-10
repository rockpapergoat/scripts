#!/usr/bin/env bash
# 100810, nate@tsp, initial version
# cf. open directory administration documentation
# set some location variables
sacommands="/var/backups/dirserv.txt"
location=/var/backups/dirserv
MKPASSDB=$(which mkpassdb)
pass="<pass here>"

if [ ! -d $location ]; then
	/bin/mkdir $location
fi

# log to syslog
/usr/bin/logger -p local0.notice -i -t Nightly Starting nightly OD backup
# backup open directory
/bin/echo "dirserv:backupArchiveParams:archivePassword = $pass" > $sacommands
/bin/echo "dirserv:backupArchiveParams:archivePath = $location/odbackup-`date "+%Y%m%d"`" >> $sacommands
/bin/echo "dirserv:command = backupArchive" >> $sacommands
/bin/chmod 600 $sacommands
/usr/sbin/serveradmin command < $sacommands
# compress the sparseimage
/usr/bin/tar cfj $location/odbackup-`date "+%Y%m%d"`.tar.bz2 $location/mkpassdb
# backup the password server db
$MKPASSDB -backupdb $location/mkpassdb/
/usr/bin/tar cfj $location/mkpassdb-`date "+%Y%m%d"`.sparseimage.tar.bz2 $location/odbackup-`date "+%Y%m%d"`.sparseimage
# purge backup files older than 14 days
/usr/bin/find $location -mtime +14 -delete
# log end to syslog
/usr/bin/logger -p local0.notice -i -t Nightly Finished nightly OD backup
# clean up a bit
/bin/rm -Rf $location/mkpassdb/
/bin/rm -f $location/odbackup-`date "+%Y%m%d"`.sparseimage
/usr/bin/srm $sacommands
exit 0
