#!/usr/bin/env bash
pm2 start "`dirname $0`/process.json"
pm2 logs
