#!/bin/bash

# install https://wiki.ubuntuusers.de/mount.cifs/
# install cpulimit
# cpulimit -l 50



# tested version
#NAME="Raspbian GNU/Linux"
#VERSION="11 (bullseye)"



DD_BACKUP_SOURCE="/dev/mmcblk0"
FS_BACKUP_SOURCE="/root /boot"
BACKUP_DESTINATION="/mnt/data/Backup/one.home.lab/"
# retention in days +24h
BACKUP_RETENTION_TIME="30"
DATETIME=`date '+%d%m%Y_%H%M%S'`
DD_FILE_NAME="raspi_dd_image_"$DATETIME".img"
FS_FILE_NAME="raspi_fs_backup_"$DATETIME".tar.gz"



DD_WRITE_BACKUP() {

	/usr/bin/dd if=$DD_BACKUP_SOURCE of=$BACKUP_DESTINATION$DD_FILE_NAME bs=1M

	if [ $? -eq 0 ]
	then
		/usr/bin/logger -s "backupapi: DD backup created."
	else
 		/usr/bin/logger -s "backupapi: DD backup failed."
  		exit 1
	fi
}

FS_WRITE_BACKUP() {

	/usr/bin/tar -czf $BACKUP_DESTINATION$FS_FILE_NAME $FS_BACKUP_SOURCE

        if [ $? -eq 0 ]
	then
		/usr/bin/logger -s "backupapi: FS backup created."

	elif [ $? -eq 1 ]
	then
		/usr/bin/logger -s "backupapi: FS backup created, but some files differ."

	else
                /usr/bin/logger -s "backupapi: FS backup failed."
                exit 1
        fi
}

DELETE_OLD_BACKUPS() {
        # einbauen dass letzte Sicherung immer stehen bleibt, dann muss zwischen DD und FS unterschieden werden
	FILES_TO_DELETE=$(/usr/bin/find $BACKUP_DESTINATION -mtime +$BACKUP_RETENTION_TIME)
	/usr/bin/logger -s "$FILES_TO_DELETE"
	/usr/bin/find $BACKUP_DESTINATION -mtime +$BACKUP_RETENTION_TIME -delete

}

if [ $1 = "-h" ]
then
  echo "backupAPi.sh dd|fs"
fi

if [ $1 = "dd" ]
then
  DD_WRITE_BACKUP
  DELETE_OLD_BACKUPS
fi

if [ $1 = "fs" ]
then
  FS_WRITE_BACKUP
  DELETE_OLD_BACKUPS
fi
