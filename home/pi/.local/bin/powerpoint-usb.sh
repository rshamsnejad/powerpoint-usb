#!/bin/bash

trap "exit 1" TERM

mount_disk()
{
	DEV="$1"

	udisksctl mount -o ro -b "$DEV" >/dev/null
	
	MOUNT_PATH=$(udisksctl info -b "$DEV" | grep MountPoints | tr -d ' ' | cut -d ':' -f 2)

	if [ -z $MOUNT_PATH ] ; then
		echo >2 "Unable to mount $DEV"
		exit 1
	elif [ ! -r "$MOUNT_PATH" ] ; then
		echo >2 "Unable to read $MOUNT_PATH."
		exit 1
	fi

	echo "$MOUNT_PATH"
}

unmount_disk()
{
	DEV="$1"

	udisksctl unmount -b "$DEV" 
	return $?
}


PARTITION="$1"
DEVICE="/dev/$PARTITION"
FILENAME="$2"
TARGET="/home/$USER/Documents"

MOUNT_PATH=$(mount_disk "$DEVICE")
echo "Mounted $MOUNT_PATH"

FILE_PATH="$MOUNT_PATH/$FILENAME"

cp -v "$FILE_PATH" "$TARGET"
COPY_STATUS=$?

unmount_disk "$DEVICE" 

if [ $COPY_STATUS -ne 0 ] ; then
	exit 1
fi

libreoffice "$TARGET/$FILENAME"
