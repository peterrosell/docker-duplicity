#!/bin/bash

if [ "$1" == "backup" ]; then
	/usr/local/bin/duplicity --full-if-older-than $2 /data $DEST_URL
elif [ "$1" == "backup-inc" ]; then
	/usr/local/bin/duplicity incremental /data $DEST_URL
elif [ "$1" == "backup-full" ]; then
	/usr/local/bin/duplicity full /data $DEST_URL
elif [ "$1" == "backup-cronjob" ]; then
	touch /tmp/log
	sed -i "s/__CRON_EXPR__/$CRON_EXPR/g" /config/duplicity_cronjob
	echo "export DEST_URL=$DEST_URL" > /config/env
	echo "export GOOGLE_AUTH_MODE=$GOOGLE_AUTH_MODE" >> /config/env
	echo "export GOOGLE_SECRETS_FILE=$GOOGLE_SECRETS_FILE" >> /config/env
	echo "export GOOGLE_CREDENTIALS_FILE=$GOOGLE_CREDENTIALS_FILE" >> /config/env
	echo "export ENCRYPTION_ALGORITHM=$ENCRYPTION_ALGORITHM" >> /config/env
	echo "export PASSPHRASE=$PASSPHRASE" >> /config/env
	echo "export FULL_BACKUP_INTERVAL=$FULL_BACKUP_INTERVAL" >> /config/env

	crontab /config/duplicity_cronjob
	cron
	echo "Cronjob registred with expression $CRON_EXPR and will backup to $DEST_URL" >> /tmp/log
	tail -F /tmp/log
	while [ true ]; do 
		sleep 1d
	done
elif [ "$1" == "cleanup" ]; then
	/usr/local/bin/duplicity cleanup $2 /data $DEST_URL
elif [ "$1" == "remove-all-but-n-latest" ]; then
	/usr/local/bin/duplicity remove-all-inc-of-but-n-full $2 $3 /data $DEST_URL
elif [ "$1" == "remove-older-than" ]; then
	/usr/local/bin/duplicity remove-older-than $2 $3 /data $DEST_URL
elif [ "$1" == "restore" ]; then
	/usr/local/bin/duplicity restore $DEST_URL /data
elif [ "$1" == "help" ]; then
	echo "Usage: docker run --rm --hostname=duplicity --env PASSPHRASE=the_secret_long_passphrase \\"
	echo "       --env DEST_URL=pydrive://user@gmail.com/backup \\"
	echo "       -v /directory/to/backup:/data \\"
	echo "       -v /persistent/storage/for/keys:/keys \\"
	echo "       -v /optional/cache/storage:/cache \\"
	echo "       -v /etc/localtime:/etc/localhost:ro \\"
	echo "       duplicity <action> <options>"
	echo ""
	echo "backup <age>      - Backup incremental or full if previous full backup is older than <age>"
	echo "                    Example: backup 7D"
	echo "backup-inc        - Backup incremental"
	echo "                    Example: backup-inc"
	echo "backup-full       - Backup full"
	echo "                    Example: backup-full"
	echo "backup-cronjob    - Schedules backup with cron expression (set by env variable CRON_EXPR)"
	echo "                    and full backup with an interval (set by env variable FULL_BACKUP_INTERVAL)"
	echo "                    Don't use --rm, but --daemon instead to keep it running in the background."
	echo "                    Example: backup-cronjob"
	echo "cleanup [--force] - Cleanup failed backups and extraneous duplicity files on the given backend."
	echo "                    Example: cleanup"
	echo "remove-all-but-n-latest <n> [--force]" 
	echo "                  - Remove backups, but keep one backup. Notice that an full backup is always needed."
	echo "                    Example: remove-all-but-latest 1"
	echo "remove-older-than <age> [--force]"
	echo "                  - Remove backups, but keep one backup. Notice that an full backup is always needed."
	echo "                    Example: remove-older-than 8D"
	echo "restore           - Restore latest backup"
	echo "                    Example: restore"
	echo "collection-status - Show the status of the backup collection."
	echo "                    Example: collection-status"
	echo "help              - Show this help text"
	echo "<commands>        - Run customer commands."
	echo "                    Example: bash  (To get a console inside the docker container)"
	echo "                    Example: duplicity verify"
	echo "NOTE! First time you run the backup must use the flags \"-i -t\" You will be presented an URL"
	echo "      that you should open in your web browser and accept the access. A secret key will be shown in"
	echo "      the web browser. Paste that key to the console. The key will be stored in the \"/keys\" directory."
	echo "      Now the application will have access to your Google drive cloud storage."
else
	$@
fi

