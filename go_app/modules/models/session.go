package models

import (
	"github.com/satori/go.uuid"
	"github.com/jinzhu/gorm"
)

type Session struct {
	Id 						uuid.UUID `from:"id" sql:"type:uuid;primary_key;default:uuid_generate_v4()"`
	User					User 			`gorm:"ForeignKey:UserId"`
	UserId 				uuid.UUID	`from:"user_id"`
	Device				Device		`gorm:"ForeignKey:DeviceId"`
	DeviceId			uuid.UUID	`from:"device_id"`
}

func (request *Session) BeforeCreate(scope *gorm.Scope) error {
	scope.SetColumn("Id", uuid.NewV4())
	return nil
}
