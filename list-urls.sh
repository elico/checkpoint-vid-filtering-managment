#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname $(readlink -f $0))

echo "dirname/readlink: ${SCRIPT_ROOT}"

## Debug
DB_PATH="${SCRIPT_ROOT}/system.db"
if [ -f "/flash/system.db" ];then
  DB_PATH="/flash/system.db"
fi

echo "SELECT * FROM appUrl;" |sqlite3 ${DB_PATH}
