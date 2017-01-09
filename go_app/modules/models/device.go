package models

import (
	"github.com/satori/go.uuid"
	"github.com/jinzhu/gorm"
)

type Device struct {
	Id 						uuid.UUID `from:"id" sql:"type:uuid;primary_key;default:uuid_generate_v4()"`
	User					User 			`gorm:"ForeignKey:UserId"`
	UserId 				uuid.UUID	`from:"user_id"`
	DeviceId 			string 		`from:"device_id" gorm:"size:2048"`
	Platform			string		`from:"platform"`
	Token 				string 		`from:"token" gorm:"size:2048"`
}

func (request *Device) BeforeCreate(scope *gorm.Scope) error {
	scope.SetColumn("Id", uuid.NewV4())
	return nil
}
