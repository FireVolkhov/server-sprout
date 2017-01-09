package main

import "log"
import "os"
import config "../go_app/modules/config"
import api "../go_app/modules/api"
import worker "../go_app/core/worker"

func main() {
	log.SetOutput(os.Stdout)

	log.Println("	░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░")
	log.Println("	░░░░░░░▄▄▀▀▀▀▀▀▀▀▀▀▄▄█▄░░░░▄░░░░█░░░░░░░")
	log.Println("	░░░░░░█▀░░░░░░░░░░░░░▀▀█▄░░░▀░░░░░░░░░▄░")
	log.Println("	░░░░▄▀░░░░░░░░░░░░░░░░░▀██░░░▄▀▀▀▄▄░░▀░░")
	log.Println("	░░▄█▀▄█▀▀▀▀▄░░░░░░▄▀▀█▄░▀█▄░░█▄░░░▀█░░░░")
	log.Println("	░▄█░▄▀░░▄▄▄░█░░░▄▀▄█▄░▀█░░█▄░░▀█░░░░█░░░")
	log.Println("	▄█░░█░░░▀▀▀░█░░▄█░▀▀▀░░█░░░█▄░░█░░░░█░░░")
	log.Println("	██░░░▀▄░░░▄█▀░░░▀▄▄▄▄▄█▀░░░▀█░░█▄░░░█░░░")
	log.Println("	██░░░░░▀▀▀░░░░░░░░░░░░░░░░░░█░▄█░░░░█░░░")
	log.Println("	██░░░░░░░░░░░░░░░░░░░░░█░░░░██▀░░░░█▄░░░")
	log.Println("	██░░░░░░░░░░░░░░░░░░░░░█░░░░█░░░░░░░▀▀█▄")
	log.Println("	██░░░░░░░░░░░░░░░░░░░░█░░░░░█░░░░░░░▄▄██")
	log.Println("	░██░░░░░░░░░░░░░░░░░░▄▀░░░░░█░░░░░░░▀▀█▄")
	log.Println("	░▀█░░░░░░█░░░░░░░░░▄█▀░░░░░░█░░░░░░░▄▄██")
	log.Println("	░▄██▄░░░░░▀▀▀▄▄▄▄▀▀░░░░░░░░░█░░░░░░░▀▀█▄")
	log.Println("	░░▀▀▀▀░░░░░░░░░░░░░░░░░░░░░░█▄▄▄▄▄▄▄▄▄██")
	log.Println("	░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░")
	log.Println("### Start App ###")

	conf := config.Get()

	log.Println("### Lister port:", conf.Port, "###")

	if conf.Run == "" {
		worker.Start()
		api.Start()
	} else {
		worker.Run(conf.Run)
	}
}
