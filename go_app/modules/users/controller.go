package users

import (
	//"net/http"
	"encoding/json"

	"../../../go_app/core"
	"../../../go_app/modules/database"
	"../../../go_app/modules/models"

	"github.com/jinzhu/gorm"
	//"github.com/julienschmidt/httprouter"
	"github.com/asaskevich/govalidator"
	"github.com/satori/go.uuid"
	"github.com/valyala/fasthttp"
	//"github.com/mailru/easyjson"
)

type LoginRequest struct {
	Login 				string `json:"login" valid:"length(3|255),required" trim:"true"`
	Password 			string `json:"password" valid:"length(1|255),required" trim:"true"`
	PlatformType 	string `json:"platform_type" valid:"platform_type,required"`
	DeviceId 			string `json:"device_id" valid:"required"`
}

type LoginResponse struct {
	ErrorCode 			int					`json:"error_code"`
	ErrorMessage 		*string			`json:"error_message"`
	Result 					LoginResult	`json:"result"`
}

type LoginResult struct {
	UserId 			uuid.UUID	`json:"user_id"`
	SessionId 	uuid.UUID	`json:"session_id"`
}


func LoginHandler(ctx *fasthttp.RequestCtx) {
	var data LoginRequest
	var err error
	var dbConnect *gorm.DB
	var user models.User
	var session models.Session

	err = json.Unmarshal(ctx.PostBody(), &data)
	//err = core.DecodeJson(&data, ctx.PostBody())
	if err != nil {panic(err)}

	core.Trimmer(&data)

	_, err = govalidator.ValidateStruct(&data)
	if err != nil {panic(err)}

	dbConnect, err = database.Connect()
	if err != nil {panic(err)}
	//defer dbConnect.Close()

	user, session, err = Login(dbConnect, &data)
	if err != nil {panic(err)}

	response := LoginResponse{0, nil, LoginResult{user.Id, session.Id}}
	result, err := json.Marshal(&response)
	if err != nil {panic(err)}

	ctx.Write(result)
	//return core.WriteError(writer, err, code)
}
