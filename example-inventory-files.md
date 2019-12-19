Example inventory files
=======================

## 3 node cluster

```ini
[masters]
master.domain.com

[workers]
worker1.domain.com
worker2.domain.com

[all:vars]
cluster_name=nais
service_cidr=10.254.0.0/16
kubernetes_default_ip=10.254.0.1
cluster_dns_ip=10.254.0.53
pod_network_cidr=192.168.0.0/16
domain=domain.com
cluster_domain=nais.local
cluster_lb_suffix=nais.domain.com
```


## 3 node cluster with HTTP proxy

3 node cluster with a HTTP proxy to internet. Uses a remote user named `deployuser` to access `[master]` and `[worker]` hosts.

```ini
[masters]
master.domain.com

[workers]
worker1.domain.com
worker2.domain.com

[all:vars]
cluster_name=nais
service_cidr=10.254.0.0/16
kubernetes_default_ip=10.254.0.1
cluster_dns_ip=10.254.0.53
pod_network_cidr=192.168.0.0/16
domain=domain.com
cluster_domain=nais.local
cluster_lb_suffix=nais.domain.com
nais_http_proxy=http://webproxy.domain.com:8088
nais_https_proxy=http://webproxy.domain.com:8088
nais_no_proxy="localhost,127.0.0.1,.local,.domain.com,{{ansible_default_ipv4.address}}"
nais_remote_user=deployuser
```


## Node taints and labels

Example of labeling and tainting two nodes: worker2.domain.com, and worker3.domain.com.

### file: inventory

```ini
[masters]
master.domain.com

[workers]
worker1.domain.com
worker2.domain.com
worker3.domain.com
worker4.domain.com
worker5.domain.com

[ceph_nodes]
worker4.domain.com
worker5.domain.com
```

### file: group_vars/ceph_nodes

```yaml
node_taints:
  - nais.io/ceph-node=true:NoSchedule

node_labels:
  - nais.io/ceph-node=true
```

## Simple complete inventory

```ini
[masters]
<K8S-master-hostname>

[workers]
<K8S-worker-hostname-1>
<K8S-worker-hostname-n>

[etcd]
<etcd-node-hostname-1>
<etcd-node-hostname-n>

[ceph_nodes]
<ceph-node-hostname-1>
<ceph-node-hostname-n>

[all:vars]
cluster_name=nais-dev
service_cidr=10.254.0.0/16
kubernetes_default_ip=10.254.0.1
cluster_dns_ip=10.254.0.53
pod_network_cidr=192.168.0.0/16
domain=nais.io
cluster_domain=nais.local
cluster_lb_suffix=nais.domain.com

# If you need a proxy to access internet, configure the following variables.
nais_http_proxy=http://webproxy.domain.com:8088
nais_https_proxy=http://webproxy.domain.com:8088
nais_no_proxy="localhost,127.0.0.1,.local,.domain.no,{{ansible_default_ipv4.address}}"

# Remote username. Defaults to deployer if not set
nais_remote_user=deployer

# OpenId Connect
oidc_issuer_url=https://sts.windows.net/62366534-1ec3-4962-8869/
oidc_client_id=spn:a0e7d619-2cf2-4631-a6f0
oidc_username_claim=upn
oidc_groups_claim=groups
```
