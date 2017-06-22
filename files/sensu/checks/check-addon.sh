#!/bin/bash
# Check if addon are deployed and available.
#
# The addon check is done with following command line:
# /usr/bin/kubectl -n kube-system get deploy ${ADDON} -o json | grep '\"availableReplicas\": 1' | wc -l

ADDON=$1

if [[ $(/usr/bin/kubectl -n kube-system get deploy ${ADDON} -o json | grep '\"availableReplicas\": 1' | wc -l) == 1 ]]; then
    echo "Addon deployment check for ${ADDON}: PASSED"
    exit 0
else
    echo "Addon deployment for ${ADDON}: FAILED"
    exit 1
fi