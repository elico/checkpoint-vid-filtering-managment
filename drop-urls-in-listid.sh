#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname $(readlink -f $0))

echo "dirname/readlink: ${SCRIPT_ROOT}"

## Debug
DB_PATH="${SCRIPT_ROOT}/system.db"
if [ -f "/flash/system.db" ];then
  DB_PATH="/flash/system.db"
fi

LIST_NAME="$1"

if [ -z "${LIST_NAME}" ];then
	echo "Missing list name, try: YouTube-BlackList"
	exit 1
fi

CUSTOM_APP_ID=$(echo "SELECT id,name FROM customApp;" |sqlite3 ${DB_PATH}|egrep "${LIST_NAME}$"  |sed -e "s@|@\t@g"|awk '{print $1}')

echo "Emptying APP_ID: ${CUSTOM_APP_ID}"

echo "DELETE FROM appUrl WHERE customApp_appUrls = ${CUSTOM_APP_ID};" |sqlite3 ${DB_PATH}
