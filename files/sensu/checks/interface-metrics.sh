#!/bin/bash
# Check if docker interfaces is present.
#
# The interface check is done with following command line:
# ip link show ${INTERFACE}

INTERFACE=$1
TIMESTAMP=$(date '+%s')

if [[ $(ip link show ${INTERFACE}) ]]; then
    echo "nais.interface.eventtags.interface.${INTERFACE} 0 ${TIMESTAMP}"
else
    echo "nais.interface.eventtags.interface.${INTERFACE} 1 ${TIMESTAMP}"
fi