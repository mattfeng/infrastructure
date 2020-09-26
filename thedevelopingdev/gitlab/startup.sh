#!/bin/sh

mkdir -p /backup

# mount backup disk
if lsblk -f -o FSTYPE /dev/sdb | grep -q ext4; then
  mount -o discard,defaults /dev/sdb /backup
else
  mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
  mount -o discard,defaults /dev/sdb /backup
fi

mkdir -p /backup/gitlab-data
chmod a+w /backup
chmod a+w /backup/gitlab-data

# setup gitlab folders
mkdir -p /srv/gitlab
chmod a+w /srv/gitlab

# start GitLab server
docker-compose -f /root/docker-compose.yml up -d

if test -f /backup/gitlab-data/dump_gitlab_backup.tar; then
  # wait for 7 minutes
  sleep 420

  # attempt to restore
  docker exec root_web_1 gitlab-ctl stop unicorn
  docker exec root_web_1 gitlab-ctl stop puma
  docker exec root_web_1 gitlab-ctl stop sidekiq

  # restore the database
  docker exec root_web_1 gitlab-backup restore BACKUP=dump force=yes

  if test -e /backup/gitlab-config; then
    # restore the secrets
    cp -a /backup/gitlab-config /srv/gitlab
  fi

  # restart the GitLab container
  docker-compose -f /root/docker-compose.yml restart

  # check GitLab
  docker exec root_web_1 gitlab-rake gitlab:check SANITIZE=true
fi

# enable cronjobs
crontab /backups.cron