#!/bin/bash
# Check if that all nodes are in Ready-state.
#
# The node check is done with following command line:
# /usr/bin/kubectl get nodes | grep -iw 'Ready' | wc -l

TIMESTAMP=$(date '+%s')

if [[ $(/usr/bin/kubectl get nodes | grep -iw 'NotReady' ) ]]; then
    echo "nais.nodes.eventtags.nodes 1 ${TIMESTAMP}"
else
    echo "nais.nodes.eventtags.nodes 0 ${TIMESTAMP}"
fi