etcd
====

> etcd is a distributed key value store that provides a reliable way to store data across a cluster of machines


## Adding etcd nodes

1. Add the node name in `etcd` section of `nais-inventory`
2. Add the node to the cluster `etcdctl member add <hostname> https://<ip>:2380` on one of the existing etcd nodes
3. Run Ansible playbook with parameter `skip-tags=fetch_etcd_certs`
4. Verify that the cluster is healthy `etcdctl cluster-health`

**Note**: Remember to separate between http og https!

**Note**: Remember to add the environment variables to be able to use `etcdctl`.

```
export ETCDCTL_CERT_FILE=/etc/ssl/etcd/etcd-client.pem
export ETCDCTL_KEY_FILE=/etc/ssl/etcd/etcd-client-key.pem
export ETCDCTL_CA_FILE=/etc/ssl/etcd/ca.pem
```

**Note**: Only **one** node can be added at a time, repeat steps 1-4 for several nodes.


## Migrate nodes from HTTP to HTTPS

1. Update service file in the `templates` directory
2. Run the following command on one of the etcd nodes, to generate the necessary commands:
   * `etcdctl member list | awk -F'[: =]' '{print "etcdctl member update "$1" https:"$7":"$8}'`
3. Run the generated commands on the same etcd node
4. Run Ansible playbook

## Description of etcd backup configuration

1. etcd backup service and script files are located in files/etcd
2. etcd backup timer in the same directory specifies when to do the backup
3. The files are copied to the etcd nodes during initial setup with the timer defaulting to 10 pm every night
4. The shell script creates backup og compresses it for easy extraction
5. Automate the recovery process from server with access to the extracted backups
