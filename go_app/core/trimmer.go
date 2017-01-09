package core

import (
	"reflect"
	"strings"
)

func Trimmer(s interface{}) {
	val := reflect.ValueOf(s)
	if val.Kind() == reflect.Interface || val.Kind() == reflect.Ptr {
		val = val.Elem()
	}
	// we only accept structs
	if val.Kind() != reflect.Struct {
		return
	}
	for i := 0; i < val.NumField(); i++ {
		valueField := val.Field(i)
		typeField := val.Type().Field(i)
		if typeField.PkgPath != "" {
			continue // Private field
		}
		tag := typeField.Tag.Get("trim")

		if len(tag) > 0 {
			valueField.SetString(strings.Trim(valueField.String(), " "))
		}
	}
}
