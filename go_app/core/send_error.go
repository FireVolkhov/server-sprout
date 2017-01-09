package core

import (
	"net/http"

	"../../go_app/modules/error_codes"
)

func WriteError(writer http.ResponseWriter, err error, code error_codes.ErrorCode) {

}
