#!/bin/bash
# Check if docker interfaces is present.
#
# The interface check is done with following command line:
# ip link show ${INTERFACE}

INTERFACE=$1

if [[ $(ip link show ${INTERFACE}) ]]; then
    echo "Interface check for ${INTERFACE}: PASSED"
    exit 0
else
    echo "Interface check for ${INTERFACE}: FAILED"
    exit 1
fi