package users

import (
	"github.com/jinzhu/gorm"
	"../../../go_app/modules/models"
)

func Logout(db *gorm.DB, session *models.Session) (err error) {
	err = db.Delete(session).Error
	if err != nil {panic(err)}

	return
}

