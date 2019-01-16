etcd
====

> etcd is a distributed key value store that provides a reliable way to store data across a cluster of machines


## Fremgangsmåte for å legge til en etcd-node

1. Legg til noden under `etcd` i `nais-inventory`
2. Legg noden til clusteret med `etcdctl member add <hostname> http://<ip>:2380` på en av etcd-nodene
3. Kjør Ansible med `skip-tags=fetch_etcd_certs`
4. Sjekk at alt fungerer med `etcdctl cluster-health`


**PS**: Husk å legge til miljøvariabler for å snakke med etcd-clusteret via `etcdctl`.

```
export ETCDCTL_CERT_FILE=/etc/ssl/etcd/etcd-client.pem
export ETCDCTL_KEY_FILE=/etc/ssl/etcd/etcd-client-key.pem
export ETCDCTL_CA_FILE=/etc/ssl/etcd/ca.pem
```

**PS2**: Du kan **kun** legge til **en** node om gangen, så steg 1-4 må gjøres **per** node.


## Oppgradere noder fra HTTP til HTTPS

1. Oppdater service-filen i `templates`-katalogen
2. Kjør følgende kommando på en etcd-node, for å få generert riktig kommandoer
   * `etcdctl member list | awk -F'[: =]' '{print "etcdctl member update "$1" https:"$7":"$8}'`
3. Kjør kommandoene fra forrige punkt på samme etcd-node
4. Kjør Ansible
