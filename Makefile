DEST_URL=pydrive://user@gmail.com/backup-example
PASSPHRASE=hello
DATA_DIR=`pwd`/assets

build: check-repository
	docker build --tag ${REPOSITORY}duplicity .

push: check-repository
	docker push ${REPOSITORY}duplicity

backup-command: check-repository
	docker run ${ARGUMENTS} --hostname=duplicity --env PASSPHRASE=${PASSPHRASE} \
	--env DEST_URL=${DEST_URL} \
	-v ${DATA_DIR}:/data -v /tmp/keys:/keys -v /tmp/cache:/cache \
	-v /etc/localtime:/etc/localtime:ro \
	${REPOSITORY}duplicity ${COMMAND}

backup: 
	COMMAND=backup ARGUMENTS="--rm -it" make backup-command

backup-inc: 
	COMMAND=backup-inc ARGUMENTS="--rm -it" make backup-command

backup-full: 
	COMMAND=backup-full ARGUMENTS="--rm -it" make backup-command

backup-cronjob:
	COMMAND=backup-cronjob ARGUMENTS="-d --name duplicity --env CRON_EXPR='* * * * *'" make backup-command

enter-container:
	COMMAND=/bin/bash ARGUMENTS="--rm -it" make backup-command

cleanup:
	COMMAND="duplicity cleanup ${DEST_URL}" ARGUMENTS="--rm -it" make backup-command

cleanup-force:
	COMMAND="duplicity cleanup --force ${DEST_URL}" ARGUMENTS="--rm -it" make backup-command

remove-all-but-latest:
	COMMAND="duplicity remove-all-inc-of-but-n-full 1 ${DEST_URL}" ARGUMENTS="--rm -it" make backup-command

remove-all-but-latest-force:
	COMMAND="duplicity remove-all-inc-of-but-n-full 1 --force ${DEST_URL}" ARGUMENTS="--rm -it" make backup-command

remove-older:
	COMMAND="duplicity remove-older-than 1h ${DEST_URL}" ARGUMENTS="--rm -it" make backup-command

remove-older-force:
	COMMAND="duplicity remove-older-than 1h --force ${DEST_URL}" ARGUMENTS="--rm -it" make backup-command

collection-status:
	COMMAND="duplicity collection-status ${DEST_URL}" ARGUMENTS="--rm -it" make backup-command

check-repository:
	@if [ -z "$$REPOSITORY" ]; then \
	  echo "Environment variable REPOSITORY must be set. Example: export REPOSITORY='my_repo/'"; \
	exit 1; \
	fi
