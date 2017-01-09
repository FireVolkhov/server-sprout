package core

import (
	"os"
	"strings"
	"flag"
	"strconv"
)

func consoleNameToShortName(name string) string {
	result := []string{}
	consoleNameWords := strings.Split(name, "-")

	for _, v := range consoleNameWords {
		result = append(result, v[:1])
	}

	return strings.Join(result, "")
}

type flagValue struct {
	value *string
	shortValue *string
	envName string
	defValue string
}

var flags = make(map[string]flagValue)

var callFlagParse bool = false

func SetFlag(name, envName, defValue, description string) {
	shortFlagName := consoleNameToShortName(name)

	flags[name] = flagValue{
		flag.String(name, defValue, description),
		flag.String(shortFlagName, defValue, description),
		envName,
		defValue}
}

func GetFlag(name string) string {
	if !callFlagParse {
		flag.Parse()
		callFlagParse = true
	}

	value := *flags[name].value
	shortValue := *flags[name].shortValue
	defValue := flags[name].defValue
	envValue := os.Getenv(flags[name].envName)

	if value != "" && value != defValue {
		return value
	}

	if shortValue != "" && shortValue != defValue {
		return shortValue
	}

	if envValue != "" && envValue != defValue {
		return envValue
	}

	return defValue
}

func GetIntFlag(name string) int {
	value := GetFlag(name)
	result, err := strconv.Atoi(value)

	if err != nil {
		panic(err)
	}

	return result
}

func GetBoolFlag(name string) bool {
	value := GetFlag(name)
	result, err := strconv.ParseBool(value)

	if err != nil {
		panic(err)
	}

	return result
}
