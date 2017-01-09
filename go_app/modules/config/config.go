package config

import core "../../../go_app/core"

type Configuration struct {
	Env string
	Port int
	Version int
	CoreMode bool
	RedisHost string
	RedisPort int
	Run string
	Testing bool
	Express	ExpressConfig
	DataBase DataBaseConfig
	PushNotification PushNotificationConfig
	Mail MailConfig
}

type ExpressConfig struct {
	RequestLimit string
}

type DataBaseConfig struct {
	ConnectString string
}

type PushNotificationConfig struct {
	GcmId string
	ApnKey string
	ApnCert string
}

type MailConfig struct {
	SmtpsConnectString string
	From string
}

var Config Configuration

func init() {
	core.SetFlag("env", "ENV", "dev", "Env mode")
	core.SetFlag("port", "API_PORT", "3002", "Http port for api")
	core.SetFlag("version", "VERSION", "-1", "Version api")
	core.SetFlag("core-mode", "CORE_MODE", "false", "Core mode")
	core.SetFlag("redis-host", "REDIS_HOST", "redis", "Redis host name")
	core.SetFlag("redis-port", "REDIS_PORT", "6379", "Redis port")
	core.SetFlag("run", "RUN", "", "Run task")
	core.SetFlag("testing", "TESTING", "false", "Test mode")


	Config = Configuration{}
	Config.Env = core.GetFlag("env")
	Config.Port = core.GetIntFlag("port")
	Config.Version = core.GetIntFlag("version")
	Config.CoreMode = core.GetBoolFlag("core-mode")
	Config.RedisHost = core.GetFlag("redis-host")
	Config.RedisPort = core.GetIntFlag("redis-port")
	Config.Run = core.GetFlag("run")
	Config.Testing = core.GetBoolFlag("testing")

	Config.Express = ExpressConfig{"10mb"}
	Config.DataBase = DataBaseConfig{"host=db user=docker dbname=docker sslmode=disable password=docker"}
	//Config.DataBase = DataBaseConfig{"docker:docker@db:5432/docker?charset=utf8&parseTime=True&loc=Local"}

	// Чтоб отправлял пуши
	// production: true
	Config.PushNotification = PushNotificationConfig{
		"AIzaSyC_mqb7kPUeds9VJ0MP-DaSuKxT6WlSlKE",
		"./push_key.pem",
		"./push_cert.pem"}

	Config.Mail = MailConfig{
		"smtps://security-chat-dev:security-chat-dev*@smtp.yandex.ru",
		"\"Security chats\" <security-chat-dev@yandex.ru>"}
}

func Get() Configuration {
	return Config
}