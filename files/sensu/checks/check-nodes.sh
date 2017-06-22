#!/bin/bash
# Check if that all nodes are in Ready-state.
#
# The node check is done with following command line:
# /usr/bin/kubectl get nodes | grep -iw 'Ready' | wc -l

if [[ $(/usr/bin/kubectl get nodes | grep -iw 'NotReady' ) ]]; then
    echo "Node check: FAILED"
    exit 1
else
    echo "Node check: PASSED"
    exit 0
fi