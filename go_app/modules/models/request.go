package models

import (
	"github.com/satori/go.uuid"
	"github.com/jinzhu/gorm"
	"time"
)

type Request struct {
	Id 						uuid.UUID 		`from:"id" sql:"type:uuid;primary_key;default:uuid_generate_v4()"`
	Date 					time.Time 		`from:"date" sql:"default:now()"`
	User					User 					`gorm:"ForeignKey:UserId"`
	UserId 				uuid.UUID			`from:"user_id"`
	Session				Session				`gorm:"ForeignKey:SessionId"`
	SessionId 		uuid.NullUUID `form:"name" json:"name"`
}

func (request *Request) BeforeCreate(scope *gorm.Scope) error {
	scope.SetColumn("Id", uuid.NewV4())
	scope.SetColumn("Date", time.Now())
	return nil
}