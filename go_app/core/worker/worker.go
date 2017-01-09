package worker

import "fmt"
import "github.com/robfig/cron"

type Task struct {
	name string
	period string
	action func()
}

var cronRaw *cron.Cron
var tasks = make(map[string]Task)

func init() {
	cronRaw = cron.New()
}

func Add(name, period string, action func()) {
	tasks[name] = Task{name, period, action}
	cronRaw.AddFunc(period, action)
}

func Run(name string) {
	if task, ok := tasks[name]; ok {
		task.action()
	} else {
		panic(fmt.Errorf("Not found task `%v`", name))
	}
}

func Start() {
	cronRaw.Start()
}
