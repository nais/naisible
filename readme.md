# Naisible &middot;  [nais](http://nais.io) &middot; [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)]()
Naisable is a collection of ansible playbooks used to build, test and tear down NAIS kubernetes cluster. 

<a href="http://nais.io"><img src=https://github.com/nais/nais.github.io/blob/master/img/nais.png" width="170"></a>

## Prerequisites
* [Ansible binaries](http://docs.ansible.com/ansible/intro_installation.html)
* [An inventory file](example-inventory-file) 
* [SSH access to the hosts using keys](https://www.ssh.com/ssh/copy-id)
* A user with passwordless sudo privileges on the hosts


## Building and testing an environment
```sh
ansible-playbook -i inventory-file setup-playbook.yaml &&\
ansible-playbook -i inventory-file test-playbook.yaml
```

## Removing NAIS from hosts
```sh
ansible-playbook -i inventory-file teardown-playbook.yaml
```

## Playbook details
### Setup Playbook
1. All nodes
   1. Install Webproxy certificate and update truststore
   1. Add Kubernetes RPM repository
   1. Add Docker RPM repository 
1. Master Node
   1. Fetch existing cluster certificates, if they exist
1. Ansible master node
   1. Create cluster certificates, if not fetched from NAIS master
1. Master Node
   1. Install and configure ETCD
   1. Copy cluster certificates
   1. Add flannel configuration to ETCD
1. All nodes
   1. Install and enable Flannel
   1. Install and enable Docker
   1. Install and enable kube-proxy
   1. Configure iptables
1. Master Node
   1. Install and enable Kubelet
   1. Install and enable kubernets controle plane:
      1. kube-apiserver
      1. kube-scheduler
      1. kube-controller-manager
1. Worker Nodes
   1. Copy cluster certificates
   1. Install and enable Kubelet
   1. Enable monitoring
1. Master Node
   1. Install and enable Kubelet
   1. Install and enable Helm
   1. Install and enable addons:
      1. kubernetes-dashboard
      1. core-dns
      1. traefik
      1. heapster
   1. Enable monitoring   

### Teardown Playbook
### Test Playbook

## NAIS inventory file
Template for creating a NAIS cluster inventory file.

Each inventory file consist of a hosts section, where the master and worker nodes are defined, and a variables section, where both versions and cluster specific information

Hosts
---
```
[masters]
<K8S-master-hostname>
```
```
[workers]
<K8S-worker-hostname-1>
<K8S-worker-hostname-n>
```

Variables
---
#### Version specific variables
|Variable name|Version|Version information location|
|---|---|---|
|docker_version|17.03.1.ce|https://download.docker.com/linux/centos/7/x86_64/stable/Packages/|
|cni_version|0.5.1|https://github.com/containernetworking/cni/releases|
|etcd_version|3.1.8|https://github.com/coreos/etcd/releases/|
|flannel_version|0.7.1|https://github.com/coreos/flannel/releases|
|k8s_version|1.6.3|https://github.com/kubernetes/kubernetes/releases|
|dashboard_version|1.6.1|https://github.com/kubernetes/dashboard/releases|
|coredns_version|latest|https://github.com/coredns/coredns/releases|
|traefik_version|1.3-alpine|https://hub.docker.com/r/library/traefik/tags/|
|helm_version|2.4.2|https://github.com/kubernetes/helm/releases|

#### Cluster specific variables
|Variable name|Value|Information|
|---|---|---|
|master_ip|10.181.160.89|Host IP of the master node|
|cluster_name|nais-dev|The default domain name in the cluster|
|service_cidr|10.254.0.0/16|CIDR where all k8s services will recide. Addresses in this CIDR will only exist in iptables on the cluster nodes, but should not overlap with existing network CIDRs, as there might be existing services operating in the same range |
|kubernetes_default_ip|10.254.0.1|Normally the first address in the service CIDR. This address will be allocated for the "kubernetes.default" service|
|cluster_dns_ip|10.254.0.53||
|pod_network_cidr|192.168.0.0/16|CIDR in which all pods will run. This CIDR is not accessible from the outside, but should not overlap with existing networks, as pods might need to communicate with external services operating in the same IP range|
|domain|devillo.no|Domain name of your k8s nodes, required to issue certificates|
|cluster_domain|nais.local|Domain name inside your cluster|
|cluster_lb_suffix|nais.devillo.no|Domain your external services will be exposed|


Example inventory file
---
```
[masters]
master.domain.com

[workers]
worker1.domain.com
worker2.domain.com

[all:vars]
docker_version=17.03.1.ce
cni_version=0.5.1
etcd_version=3.1.8
flannel_version=0.7.1
k8s_version=1.6.3
dashboard_version=1.6.1
coredns_version=latest
traefik_version=1.3-alpine
helm_version=2.4.2
heapster_version=1.3.0
heapster_influxdb_version=1.1.1
master_ip=10.181.160.89
cluster_name=nais
service_cidr=10.254.0.0/16
kubernetes_default_ip=10.254.0.1
cluster_dns_ip=10.254.0.53
pod_network_cidr=192.168.0.0/16
domain=domain.com
cluster_domain=nais.local
cluster_lb_suffix=nais.domain.com
```