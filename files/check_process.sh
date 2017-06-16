#!/bin/bash

TIMESTAMP=$(date '+%s')
BINARY=$1

if [[ $(pgrep $BINARY | wc -l) == 1 ]]; then
  EXITCODE=0
else
  EXITCODE=1
fi

echo "process.$BINARY $EXITCODE $TIMESTAMP"
exit $EXITCODE
