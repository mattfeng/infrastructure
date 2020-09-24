# format and mount disk
mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
mkdir -p /srv/gitlab
mount -o discard,defaults /dev/sdb /srv/gitlab
chmod a+w /srv/gitlab

# start GitLab server
docker-compose -f /root/docker-compose.yml up -d