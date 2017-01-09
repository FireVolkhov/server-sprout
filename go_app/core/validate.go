package core

import "github.com/asaskevich/govalidator"

func Validate(data struct{}) error {
	_, err := govalidator.ValidateStruct(&data)
	return err
}
