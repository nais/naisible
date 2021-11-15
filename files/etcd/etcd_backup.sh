#!/bin/bash

DATA_DIR=/var/lib/etcd
DATE=$(date +%Y-%m-%d)
BACKUP_DIR=/var/etcd_backup
ETCDCTL_BIN=/opt/bin/etcdctl
PROM_DOMAIN=nais
PROM_CLUSTER=$(sed -nr '/initial-cluster-token/ s/.* (\S+)-etcd.*/\1/p' /etc/systemd/system/etcd.service)

# Push metric for backup running
echo "etcd_backup_running 1" | curl -k --data-binary @- https://prometheus-pushgateway.$(echo $PROM_DOMAIN).$(hostname -d)/metrics/job/etcd/instance/$(hostname -f)/cluster/$PROM_CLUSTER

# Clean up old backups (older than three days)
if [ "$(ls ${BACKUP_DIR} | wc -w)" -gt "7" ]; then
  find ${BACKUP_DIR} -type d -mtime +7 -delete
  find ${BACKUP_DIR} -type f -mtime +7 -delete
fi

# Sleeping for some nodes to avoid downtime
SERVERNAME=$(hostname -s)
LASTNUMBER=$(echo "${SERVERNAME: -1}")
if [ $((LASTNUMBER%2)) -eq 0 ]; then
    sleep 45s
fi

# Stopping etcd service
systemctl stop etcd || exit 1

# Creating backup with v2 and v3 data
mkdir -p ${BACKUP_DIR}/${DATE}
${ETCDCTL_BIN} snapshot save ${BACKUP_DIR}/${DATE}/backupdb >> ${BACKUP_DIR}/etcd_backup.log 2>&1

# Push backup status to prometheus
if [ "$?" == "0" ]; then
  echo "etcd_backup_status 0" | curl -k --data-binary @- https://prometheus-pushgateway.$(echo $PROM_DOMAIN).$(hostname -d)/metrics/job/etcd/instance/$(hostname -f)/cluster/$PROM_CLUSTER
else
  echo "etcd_backup_status 1" | curl -k --data-binary @- https://prometheus-pushgateway.$(echo $PROM_DOMAIN).$(hostname -d)/metrics/job/etcd/instance/$(hostname -f)/cluster/$PROM_CLUSTER
fi

# Starting etcd service
systemctl start etcd || exit 1

# Compress backup
tar -C ${BACKUP_DIR}/${DATE} -czf ${BACKUP_DIR}/${DATE}.tar.gz backupdb && rm -rf ${BACKUP_DIR}/${DATE}

# Push metric for backup done
echo "etcd_backup_running 0" | curl -k --data-binary @- https://prometheus-pushgateway.$(echo $PROM_DOMAIN).$(hostname -d)/metrics/job/etcd/instance/$(hostname -f)/cluster/$PROM_CLUSTER
