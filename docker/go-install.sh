#!/usr/bin/env bash
source "`dirname $0`/../env.sh"

#go get "github.com/asaskevich/govalidator"
go get "github.com/gorilla/mux"
go get -u "github.com/jinzhu/gorm"
go get "github.com/jinzhu/gorm/dialects/postgres"
go get "github.com/robfig/cron"
