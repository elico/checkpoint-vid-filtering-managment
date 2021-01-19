#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname $(readlink -f $0))

echo "dirname/readlink: ${SCRIPT_ROOT}"

## Debug
DB_PATH="${SCRIPT_ROOT}/system.db"
if [ -f "/flash/system.db" ];then
  DB_PATH="/flash/system.db"
fi

if [ ! -z "$1" ];then
	Y="$1"
fi

for X in $(sqlite3 ${DB_PATH} .tables) ;
do
	sqlite3 ${DB_PATH} "SELECT * FROM $X;" | grep >/dev/null "${Y}"&& echo $X;
done
