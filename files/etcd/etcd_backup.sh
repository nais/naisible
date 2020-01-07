#!/bin/bash

DATA_DIR=/var/lib/etcd
DATE=$(date +%Y-%m-%d)
BACKUP_DIR=/var/etcd_backup
ETCDCTL_BIN=/usr/bin/etcdctl
if [[ $(grep initial-cluster-token /etc/systemd/system/etcd.service | cut -d" " -f4) == "nais-ci-etcd" ]]; then
  PROM_DOMAIN=nais-ci
else
  PROM_DOMAIN=nais
fi

# Clean up old backups (older than three days)
if [ "$(ls ${BACKUP_DIR} | wc -w)" -gt "3" ]; then
  find ${BACKUP_DIR} -type d -mtime +3 -delete
  find ${BACKUP_DIR} -type f -mtime +3 -delete
fi

# Sleeping for some nodes to avoid downtime
SERVERNAME=$(hostname -s)
LASTNUMBER=$(echo "${SERVERNAME: -1}")
if [ $((LASTNUMBER%2)) -eq 0 ]; then
    sleep 30s
fi

# Stopping etcd service
systemctl stop etcd || exit 1

# Creating backup with v2 and v3 data
mkdir -p ${BACKUP_DIR}/${DATE}
${ETCDCTL_BIN} backup --data-dir ${DATA_DIR} --backup-dir ${BACKUP_DIR}/${DATE} --with-v3 >> ${BACKUP_DIR}/etcd_backup.log 2>&1

# Push backup status to prometheus
if [ "$?" == "0" ]; then
  echo "etcd_backup_status 0" | curl -k --data-binary @- https://prometheus-pushgateway.$(echo $PROM_DOMAIN).$(hostname -d)/metrics/job/etcd/instance/$(hostname -f)
else
  echo "etcd_backup_status 1" | curl -k --data-binary @- https://prometheus-pushgateway.$(echo $PROM_DOMAIN).$(hostname -d)/metrics/job/etcd/instance/$(hostname -f)
fi

# Starting etcd service
systemctl start etcd || exit 1

# Compress backup
tar -C ${BACKUP_DIR}/${DATE} -czf ${BACKUP_DIR}/${DATE}.tar.gz member && rm -rf ${BACKUP_DIR}/${DATE}
