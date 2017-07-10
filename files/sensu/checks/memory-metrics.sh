#!/bin/bash
# Basic memory check
# Returns metric with percentage free memory including allocated swap/buffer

TIMESTAMP=$(date '+%s')
FREEMEM=$(free | grep Mem | awk '{print $4/$2 * 100}')

echo "nais.free-memory.eventtags.free-memory ${FREEMEM} ${TIMESTAMP}"
