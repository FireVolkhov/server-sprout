#!/usr/bin/env bash
mkdir -p /srv/server
pm2 start "`dirname $0`/process.json"
pm2 logs
