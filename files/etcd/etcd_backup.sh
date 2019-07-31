#!/bin/bash

DATA_DIR=/var/lib/etcd
DATE=$(date +%Y-%m-%d)
BACKUP_DIR=/tmp/etcd_backup
ETCDCTL_BIN=/usr/bin/etcdctl

# Clean up old backups (older than three days)
find ${BACKUP_DIR} -type d -mtime +3 -delete
find ${BACKUP_DIR} -type f -mtime +3 -delete

# Stopping etcd service
systemctl stop etcd || exit 1

# Creating backup with v2 and v3 data
mkdir -p ${BACKUP_DIR}/${DATE}
${ETCDCTL_BIN} backup --data-dir ${DATA_DIR} --backup-dir ${BACKUP_DIR}/${DATE} --with-v3 >> ${BACKUP_DIR}/etcd_backup.log 2>&1

# Starting etcd service
systemctl start etcd || exit 1

# Compress backup
tar -C ${BACKUP_DIR}/${DATE} -czf ${BACKUP_DIR}/${DATE}.tar.gz member

