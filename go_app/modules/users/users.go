package users

import (
	"github.com/jinzhu/gorm"
	"golang.org/x/crypto/bcrypt"
	"github.com/satori/go.uuid"

	"../../../go_app/modules/models"
	"errors"
)

func Login(db *gorm.DB, data *LoginRequest) (user models.User, session models.Session, err error) {
	err = db.Where("login = ?", data.Login).First(&user).Error
	if err != nil {panic(err)}

	if !CheckPassword(data.Password, user.PasswordHash) {
		err = errors.New("Incorrect Pass")
		return
	}

	var device models.Device
	err = db.Where("device_id = ?", data.DeviceId).First(&device).Error

	if err == nil {
		device.UserId = user.Id
		err = db.Save(&device).Error
		if err != nil {return}

		err = db.Where("device_id = ?", device.Id).Delete(models.Session{}).Error
		if err != nil {return}

	} else {
		if err.Error() == "record not found" {
			device.UserId = user.Id
			device.DeviceId = data.DeviceId
			device.Platform = data.PlatformType
			err = db.Create(&device).Error
			if err != nil {return}

		} else {
			return
		}
	}

	session = models.Session{UserId: user.Id, DeviceId: device.Id}
	err = db.Create(&session).Error
	if err != nil {return}

	request := models.Request{
		UserId: user.Id,
		SessionId: uuid.NullUUID{session.Id, true}}

	err = db.Create(&request).Error
	if err != nil {return}

	return
}

func GeneratePassword(pass string) string {
	password := []byte(pass)

	// Hashing the password with the default cost of 10
	hashedPassword, err := bcrypt.GenerateFromPassword(password, bcrypt.DefaultCost)

	if err != nil {
		panic(err)
	}

	return string(hashedPassword)
}

func CheckPassword(pass string, hash string) bool {
	password := []byte(pass)
	hashPass := []byte(hash)

	err := bcrypt.CompareHashAndPassword(hashPass, password)
	return err == nil
}
