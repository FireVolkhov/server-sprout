package models

import (
	"github.com/satori/go.uuid"
	"github.com/jinzhu/gorm"
)

type User struct {
	Id 						uuid.UUID `from:"id" sql:"type:uuid;primary_key;default:uuid_generate_v4()"`
	Login 				string 		`gorm:"unique_index" form:"login" json:"login"`
	PasswordHash 	string 		`form:"password_hash"`
	Name 					string 		`form:"name" json:"name"`
}

func (request *User) BeforeCreate(scope *gorm.Scope) error {
	scope.SetColumn("Id", uuid.NewV4())
	return nil
}