package database

import (

	"../../../go_app/modules/config"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
	//"log"
	"time"
)

//func connect(ch chan *gorm.DB) {
//	db, err := gorm.Open("postgres", config.Config.DataBase.ConnectString)
//
//	if err == nil {
//		ch <- db
//	} else {
//
//	}
//}

var DB *gorm.DB

func connect() {
	var err error
	DB, err = gorm.Open("postgres", config.Config.DataBase.ConnectString)

	if err == nil {
		return
	} else {
		time.Sleep(250 * time.Millisecond)
		connect()
	}
}

func init() {
	connect()

	DB.SingularTable(true)
	//DB.LogMode(true)
	DB.DB().SetMaxIdleConns(10)
	DB.DB().SetMaxOpenConns(90)
}

func Connect() (db *gorm.DB, err error) {
	//db, err = gorm.Open("postgres", config.Config.DataBase.ConnectString)

	//if err == nil {
	//	db.SingularTable(true)
	//	//db.LogMode(true)
	//	db.DB().SetMaxIdleConns(10)
	//	db.DB().SetMaxOpenConns(100)
	//
	//
	//} else {
	//	//ch := make(chan *gorm.DB)
	//	//go func() {
	//	//	db, err = gorm.Open("postgres", config.Config.DataBase.ConnectString)
	//	//	ch <- true
	//	//}()
	//	//<-ch
	//
	//
	//	log.Printf("Db sleep ...")
	//	time.Sleep(1000 * time.Millisecond)
	//	return Connect()
	//}
	//
	//log.Printf("Db connect: %v", db.DB().Stats().OpenConnections)

	return DB, nil
}
