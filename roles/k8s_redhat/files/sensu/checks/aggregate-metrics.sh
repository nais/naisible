#!/bin/bash
# A collection of all the nais specific tests run on a cluster node
# Returns one line for each metric and a final result with
# aggregate result of all tests.
# Inputs are either "master" for checks run on master nodes
# or "worker" for worker nodes.

CATEGORY=$1
AGGREGATERESULT=0
TIMESTAMP=$(date '+%s')

if [[ ${CATEGORY} == master ]]; then

    /etc/sensu/plugins/metrics/nais/process-metrics.sh dockerd || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/process-metrics.sh kubelet || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/interface-metrics.sh docker0 || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/interface-metrics.sh flannel.1 || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/component-metrics.sh controller-manager || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/component-metrics.sh scheduler || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/component-metrics.sh etcd-0 || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/component-metrics.sh etcd-1 || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/component-metrics.sh etcd-2 || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/nodes-metrics.sh || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/addon-metrics.sh coredns || AGGREGATERESULT=1
    /etc/sensu/plugins/metrics/nais/addon-metrics.sh tiller-deploy || AGGREGATERESULT=1

    if [[ ${AGGREGATERESULT} == 0 ]]; then
        echo "nais.aggregate.eventtags.aggregate 0 ${TIMESTAMP}"
    else
        echo "nais.aggregate.eventtags.aggregate 1 ${TIMESTAMP}"
    fi

elif [[ ${CATEGORY} == worker ]]; then

    /etc/sensu/plugins/metrics/nais/process-metrics.sh dockerd || AGGREGATERESULT=1
	/etc/sensu/plugins/metrics/nais/process-metrics.sh kubelet || AGGREGATERESULT=1
	/etc/sensu/plugins/metrics/nais/process-metrics.sh flanneld || AGGREGATERESULT=1
	/etc/sensu/plugins/metrics/nais/process-metrics.sh kube-proxy || AGGREGATERESULT=1
	/etc/sensu/plugins/metrics/nais/interface-metrics.sh docker0 || AGGREGATERESULT=1
	/etc/sensu/plugins/metrics/nais/interface-metrics.sh flannel.1 || AGGREGATERESULT=1

    if [[ ${AGGREGATERESULT} == 0 ]]; then
        echo "nais.aggregate.eventtags.aggregate 0 ${TIMESTAMP}"
    else
        echo "nais.aggregate.eventtags.aggregate 1 ${TIMESTAMP}"
    fi

fi
