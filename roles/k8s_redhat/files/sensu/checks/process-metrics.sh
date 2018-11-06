#!/bin/bash
# Check if specific process is running.
#
# The process check is done with following command line:
# /bin/pgrep {{ item }} | wc -l

PROCESS=$1
TIMESTAMP=$(date '+%s')

if [[ $(pgrep ${PROCESS} | wc -l) == 1 ]]; then
    echo "nais.process.eventtags.process.${PROCESS} 0 ${TIMESTAMP}"
    exit 0
else
    echo "nais.process.eventtags.process.${PROCESS} 1 ${TIMESTAMP}"
    exit 1
fi