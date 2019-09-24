Naisible
========

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)]()

Naisable is a collection of ansible playbooks used to build, test and tear down NAIS kubernetes cluster.


## Prerequisites

* [Ansible binaries](http://docs.ansible.com/ansible/intro_installation.html)
* [An inventory file](example-inventory-files.md)
* [SSH access to the hosts using keys](https://www.ssh.com/ssh/copy-id)
* A user with passwordless sudo privileges on the hosts


## Building and testing an environment

```sh
ansible-playbook -i inventory-file setup-playbook.yaml && \
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
1. All etcd Nodes
   1. Configure cluster
   1. Configure etcd backup
1. First etcd Node
   1. Add flannel configuration to etcd
1. Master Node
   1. Copy cluster certificates
1. All nodes
   1. Install and enable Flannel
   1. Install and enable Docker
   1. Install and enable kube-proxy
   1. Configure iptables
1. Master Node
   1. Install and enable Kubelet
   1. Install and enable kubernets controle plane
      1. kube-apiserver
      1. kube-scheduler
      1. kube-controller-manager
1. Worker Nodes
   1. Copy cluster certificates
   1. Install and enable Kubelet
   1. Enable monitoring
1. All nodes
   1. Setup kubeconfig for API server access
   1. Taint nodes 
   1. Label nodes
1. Master Node
   1. Install and enable Kubelet
   1. Install and enable Helm
   1. Install and enable addons:
      1. core-dns
      1. traefik
   1. Enable monitoring


### Teardown Playbook

### Test Playbook


## NAIS inventory file

Template for creating a NAIS cluster inventory file.

Each inventory file consist of a hosts section, where the master and worker nodes are defined, and a variables section, where both versions and cluster specific information.


Hosts
---
```
[masters]
<K8S-master-hostname>

[workers]
<K8S-worker-hostname-1>
<K8S-worker-hostname-n>

[etcd]
<etcd-node-hostname-1>
<etcd-node-hostname-n>

[storage_nodes]
<storage-node-hostname-1>
<storage-node-hostname-n>

[ceph_nodes]
<ceph-node-hostname-1>
<ceph-node-hostname-n>
```


Variables
---

#### Version specific variables. Configured in group_vars/all

|Variable name|Version|Version information location|
|---|---|---|
|etcd_version|3.2.9|https://github.com/coreos/etcd/releases/|
|flannel_version|0.9.0|https://github.com/coreos/flannel/releases|
|k8s_version|1.14.4|https://github.com/kubernetes/kubernetes/releases|
|coredns_version|011|https://github.com/coredns/coredns/releases|
|traefik_version|1.4-alpine|https://hub.docker.com/r/library/traefik/tags/|
|helm_version|2.7.0|https://github.com/kubernetes/helm/releases|


#### Cluster specific variables

|Variable name|Value|Information|
|---|---|---|
|cluster_name|nais-dev|The default domain name in the cluster|
|service_cidr|10.254.0.0/16|CIDR where all k8s services will recide. Addresses in this CIDR will only exist in iptables on the cluster nodes, but should not overlap with existing network CIDRs, as there might be existing services operating in the same range |
|kubernetes_default_ip|10.254.0.1|Normally the first address in the service CIDR. This address will be allocated for the "kubernetes.default" service|
|cluster_dns_ip|10.254.0.53||
|pod_network_cidr|192.168.0.0/16|CIDR in which all pods will run. This CIDR is not accessible from the outside, but should not overlap with existing networks, as pods might need to communicate with external services operating in the same IP range|
|domain|devillo.no|Domain name of your k8s nodes, required to issue certificates|
|cluster_domain|nais.local|Domain name inside your cluster|
|cluster_lb_suffix|nais.devillo.no|Domain your external services will be exposed|
|nais_http_proxy|http://webproxy.domain.com:8088|Address to proxy for http traffic|
|nais_https_proxy|http://webproxy.domain.com:8088|Address to proxy for https traffic|
|nais_no_proxy|"localhost,127.0.0.1,.local,.devillo.no,{{ansible_default_ipv4.address}}"|This variable should contain a comma-separated list of domain extensions proxy should _not_ be used for.|
|nais_remote_user|deployer|User for remote access to the hosts configured under [masters] and [workers] section. Defaults to deployer|
|oidc_issuer_url|https://sts.windows.net/62366534-1ec3-4962-8869/ |URL of the provider which allows the API server to discover public signing keys. https://kubernetes.io/docs/admin/authentication/#openid-connect-tokens|
|oidc_client_id|spn:a0e7d619-2cf2-4631-a6f0|A client id that all tokens must be issued for.|
|oidc_username_claim|upn|JWT claim to use as the user name|
|oidc_groups_claim|groups|JWT claim to use as the user’s group. If the claim is present it must be an array of strings.|
|log_leve|0|Log level for controll plane compents|
|docker_repo_url|""|If defined will be used to create a docker config.json credential files used by the kubelet. Typically used to access a private Docker registry.
|docker_repo_auth|""|Auth string used to create docker config.json credential file. Used together with docker_repo_url to accesis a private Docker registry.


#### Host group specific variables

| Variable name | Value | Information |
| ------------- | ----- | ----------- |
| node_taints | key=value:NoSchedule | List of taints to set on a a node (Optional) |
| node_labels | key=value | List of labels to set on a node (Optional) |
