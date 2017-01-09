package users

import (
	"github.com/asaskevich/govalidator"
)

const(
	PLATFORM_TYPE_ANDROID string = "android"
	PLATFORM_TYPE_IOS string = "ios"
	PLATFORM_TYPE_WEB string = "web"
)

var PLATFORM_TYPE map[string]string = map[string]string{
	"ANDROID": "android",
	"IOS": "ios",
	"WEB": "web",
}

func init() {
	types := make(map[string]bool)

	for _, val := range PLATFORM_TYPE {
		types[val] = true
	}

	govalidator.TagMap["platform_type"] = govalidator.Validator(func(str string) bool {
		return types[str]
	})
}
