#!/bin/bash -e

NODE_NAMES=$1
BACKUP_DIR=$2
BACKUP_DATE=$3
SSH_USER=$4
DATA_DIR=/var/lib/etcd
ETCDCTL_VARS="export ETCDCTL_CERT_FILE=/etc/ssl/etcd/etcd-client.pem;export ETCDCTL_KEY_FILE=/etc/ssl/etcd/etcd-client-key.pem;export ETCDCTL_CA_FILE=/etc/ssl/etcd/ca.pem;"

function with_retries {
  local retries=3
  set -o pipefail
  for try in $(seq 1 $retries); do
    ${@}
    [ $? -eq 0 ] && break
    if [[ "$try" == "$retries" ]]; then
      exit 1
    fi
    sleep 3
  done
  set +o pipefail
}

function usage {
  echo "Requires: "
  echo "  - comma-separated list of nodes to recover with the first node selected as leader"
  echo "  - directory with the backup file to restore"
  echo "  - backup date to restore from in YYYY-MM-DD format"
  echo "  - user with access to servers with ssh key"
  echo ""
  echo "  sh $0 <node1,node2,node3> <directory> <backup date> <loginuser>"
}

if [ $# -lt 4 ]; then
  usage
  exit 1
fi

node_names=($(echo $NODE_NAMES | awk -F',' '{for (i=1;i<=NF;i+=1) { print $i }}'))
num_nodes=${#node_names[@]}

for node_name in "${node_names[@]}"; do
  if [ "$(dig +short $node_name)" == "" ]; then
      echo "No IP address found for node $node_name"
      exit 1
  fi
done

node_name_1="${node_names[0]}"
node_short_name_1=$(echo $node_name_1 | cut -d"." -f1)
node_ep_1="https://$(dig +short $node_name_1):2380"
node_name_2="${node_names[1]}"
node_short_name_2=$(echo $node_name_2 | cut -d"." -f1)
node_ep_2="https://$(dig +short $node_name_2):2380"
node_name_3="${node_names[2]}"
node_short_name_3=$(echo $node_name_3 | cut -d"." -f1)
node_ep_3="https://$(dig +short $node_name_3):2380"
backup_file=${node_name_1}_${BACKUP_DATE}.tar.gz

if [ ! -f "${BACKUP_DIR}/$backup_file" ]; then
  echo "No backup file found"
  exit 1
fi

for i in $(seq 0 $((num_nodes - 1))); do
  echo "Stopping etcd services and deleting data dir"
  ssh ${SSH_USER}@${node_names[$i]} "sudo systemctl stop etcd"
  ssh ${SSH_USER}@${node_names[$i]} "sudo rm -rf ${DATA_DIR}/member"
done

echo "Restoring on first node: $node_name_1"
rsync -vaz -e "ssh" --rsync-path="sudo rsync" "${BACKUP_DIR}/$backup_file" ${SSH_USER}@$node_name_1:${DATA_DIR}/

ssh ${SSH_USER}@$node_name_1 "sudo tar -C ${DATA_DIR} -xzf ${DATA_DIR}/$backup_file && sudo rm -rf ${DATA_DIR}/$backup_file"
ssh ${SSH_USER}@$node_name_1 "sudo grep -q 'force-new-cluster' /etc/systemd/system/etcd.service || sudo sed -i '/--peer-key-file/a\ \ --force-new-cluster\ \\\\' /etc/systemd/system/etcd.service"
ssh ${SSH_USER}@$node_name_1 "sudo systemctl daemon-reload && sudo systemctl start etcd"
sleep 10

echo "Fix member endpoint on first node"
member_id=$(ssh ${SSH_USER}@$node_name_1 "${ETCDCTL_VARS} etcdctl member list | cut -d':' -f1")
ssh ${SSH_USER}@$node_name_1 "${ETCDCTL_VARS} etcdctl member update $member_id $node_ep_1"
sleep 3

initial_cluster="$node_short_name_1=$node_ep_1,$node_short_name_2=$node_ep_2"
echo "Adding $node_name_2 to cluster"
with_retries ssh ${SSH_USER}@$node_name_1 "${ETCDCTL_VARS} etcdctl member add $node_short_name_2 $node_ep_2"
ssh ${SSH_USER}@$node_name_2 "sudo sed -i 's#--initial-cluster\ .*#--initial-cluster\ '"$initial_cluster"'\ \\\\#g' /etc/systemd/system/etcd.service && sudo sed -i 's/--initial-cluster-state.*/--initial-cluster-state\ existing\ \\\\/g' /etc/systemd/system/etcd.service"
ssh ${SSH_USER}@$node_name_2 "sudo systemctl daemon-reload && sudo systemctl start etcd"
sleep 5

initial_cluster="$initial_cluster,$node_short_name_3=$node_ep_3"
echo "Adding $node_name_3 to cluster"
with_retries ssh ${SSH_USER}@$node_name_1 "${ETCDCTL_VARS} etcdctl member add $node_short_name_3 $node_ep_3"
ssh ${SSH_USER}@$node_name_3 "sudo sed -i 's#--initial-cluster\ .*#--initial-cluster\ '"$initial_cluster"'\ \\\\#g' /etc/systemd/system/etcd.service && sudo sed -i 's/--initial-cluster-state.*/--initial-cluster-state\ existing\ \\\\/g' /etc/systemd/system/etcd.service"
ssh ${SSH_USER}@$node_name_3 "sudo systemctl daemon-reload && sudo systemctl start etcd"
sleep 5

echo "Fix initial cluster on second node"
ssh ${SSH_USER}@$node_name_2 "sudo sed -i 's#--initial-cluster\ .*#--initial-cluster\ '"$initial_cluster"'\ \\\\#g' /etc/systemd/system/etcd.service"

echo "Resetting initial-cluster-state to new and restarting etcd services"
for i in $(seq 0 $((num_nodes - 1))); do
  ssh ${SSH_USER}@${node_names[$i]} "sudo sed -i '/--force-new-cluster/d' /etc/systemd/system/etcd.service && sudo sed -i 's/--initial-cluster-state.*/--initial-cluster-state\ new\ \\\\/g' /etc/systemd/system/etcd.service"
  ssh ${SSH_USER}@${node_names[$i]} "sudo systemctl daemon-reload && sudo systemctl start etcd"
done

echo "Verifying cluster health"
with_retries ssh ${SSH_USER}@$node_name_1 "${ETCDCTL_VARS} etcdctl cluster-health"
if [ $? -ne 0 ]; then
  exit 1
fi
