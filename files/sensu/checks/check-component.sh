#!/bin/bash
# Check if all kubernetes components are healthy
#
# The health check is done with following command line:
# /usr/bin/kubectl get componentstatus ${COMPONENT}

COMPONENT=$1

if [[ $(/usr/bin/kubectl get componentstatus ${COMPONENT}) ]]; then
    echo "Health check for ${COMPONENT}: PASSED"
    exit 0
else
    echo "Health check for ${COMPONENT}: FAILED"
    exit 1
fi