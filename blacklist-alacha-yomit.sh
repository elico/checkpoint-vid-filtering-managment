#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname $(readlink -f $0))

echo "dirname/readlink: ${SCRIPT_ROOT}"

case $1 in
	xargs)
		cat alacha_yomit.txt.in|xargs -l1 -n1 -I{} bash add-single-vid.sh {}
	;;
	*)
		bash add-vids.sh alacha_yomit.txt.in
	;;
esac
