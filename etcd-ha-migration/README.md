# how to perform etcd-ha migration

1. add new nodes to etcd-group in inventory (only three-node cluster is supported directly, if using more nodes, adjust prepare-playbook accordingly with more indexes for etcd-hosts list
2. run prepare ansible playbook 
3. verify apiserver config is correct and that kubelet restarted correctly
4. export flannel config from etcd ```/usr/bin/etcdctl ls /nais/network/subnets --recursive -p | xargs -i@ sh -c "echo -n '@ '; etcdctl get @"``` (you have to add single quotes around the json value). This is done from master.
5. import flannel config from step 4 into etcd (pick one of the etcd nodes) and run etcdctl mk <key> <value>
5. run finish script 



