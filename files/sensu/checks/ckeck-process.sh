#!/bin/bash
# Check if specific process is running.
#
# The process check is done with following command line:
# /bin/pgrep {{ item }} | wc -l

PROCESS=$1

if [[ $(pgrep ${PROCESS} | wc -l) == 1 ]]; then
    echo "Process check for ${PROCESS}: PASSED"
    exit 0
else
    echo "Process check for ${PROCESS}: FAILED"
    exit 1
fi