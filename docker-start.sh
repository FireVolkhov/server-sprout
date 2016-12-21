#!/usr/bin/env bash
mkdir -p /srv/server
pm2 start /project/process-test.json
pm2 logs
