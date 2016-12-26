#!/usr/bin/env bash
mkdir -p /srv/server
sh "`dirname $0`/../utils/migration/up.sh"
pm2 start "`dirname $0`/process.json"
pm2 logs
