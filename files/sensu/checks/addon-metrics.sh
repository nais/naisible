#!/bin/bash
# Check if addon are deployed and available.
#
# The addon check is done with following command line:
# /usr/bin/kubectl -n kube-system get deploy ${ADDON} -o json | grep '\"availableReplicas\": 1' | wc -l

ADDON=$1
TIMESTAMP=$(date '+%s')

if [[ $(/usr/bin/kubectl -n kube-system get deploy ${ADDON} -o json | grep availableReplicas | grep -v 0 | wc -l) == 1 ]]; then
    echo "nais.addon.eventtags.addon.${ADDON} 0 ${TIMESTAMP}"
    exit 0
else
    echo "nais.addon.eventtags.addon.${ADDON} 1 ${TIMESTAMP}"
    exit 1
fi