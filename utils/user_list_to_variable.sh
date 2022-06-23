#!/usr/bin/env bash

# this script exports a variable
# source it with `source` or `.`

USERLIST=$1

export BATCH_USER_CREATION=`tail -n +2 "$USERLIST" | cut -f 3,4 | tr '\t' ':' | tr '\n' ';'`
