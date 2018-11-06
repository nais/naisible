#!/bin/bash
# Check if all kubernetes components are healthy
#
# The health check is done with following command line:
# /usr/bin/kubectl get componentstatus ${COMPONENT}

COMPONENT=$1
TIMESTAMP=$(date '+%s')

if [[ $(/usr/bin/kubectl get componentstatus ${COMPONENT} | grep Healthy)  ]]; then
    echo "nais.component.eventtags.component.${COMPONENT} 0 ${TIMESTAMP}"
    exit 0
else
    echo "nais.component.eventtags.component.${COMPONENT} 1 ${TIMESTAMP}"
    exit 1
fi