package api

import "net/http"
import "log"
//import "time"
import "fmt"

import config "../../../go_app/modules/config"
import users "../../../go_app/modules/users"

//import "github.com/julienschmidt/httprouter"
import (
	"github.com/valyala/fasthttp"
	"os"
	"runtime/pprof"
)

func Log(handler http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s %s", r.RemoteAddr, r.Method, r.URL)
		handler.ServeHTTP(w, r)
	})
}

var i int = 0

func handler(ctx *fasthttp.RequestCtx) {
	log.Printf("%s %s %s", ctx.RemoteAddr(), ctx.Method(), ctx.URI())

	switch string(ctx.Path()) {
	case "/v1/user/login":
		i = i + 1
		f, _ := os.Create(fmt.Sprintf("/project/log/login%v", i))
		pprof.StartCPUProfile(f)
		users.LoginHandler(ctx)
		pprof.StopCPUProfile()

	default:
		ctx.Error("Unsupported path", fasthttp.StatusNotFound)
	}
}

func Start() {
	fasthttp.ListenAndServe(fmt.Sprintf("localhost:%v", config.Config.Port), handler)

	//route := httprouter.New()
	//route.POST("/v1/user/login", users.LoginHandler)
	//
	//srv := &http.Server{
	//	Handler:      Log(route),
	//	Addr:         fmt.Sprintf("localhost:%v", config.Config.Port),
	//	 Good practice: enforce timeouts for servers you create!
		//WriteTimeout: 60 * time.Second,
		//ReadTimeout:  60 * time.Second,
	//}

	//log.Fatal(srv.ListenAndServe())
}
