package error_codes

type ErrorCode struct {
	Code int
	Message string
	GetMessage func(string) string
}

var(
	ERROR_CODE_OLD_VERSION ErrorCode = ErrorCode{1, "This application version is too old. Please download the latest version.", nil}
	ERROR_CODE_NOT_FOUND_USER ErrorCode = ErrorCode{2, "User not found.", nil}
	ERROR_CODE_BAD_LOGIN_PASS ErrorCode = ErrorCode{3, "User name or password is incorrect.", nil}
	ERROR_CODE_MANY_REQUESTS ErrorCode = ErrorCode{4, "Too many requests.", nil}
	ERROR_CODE_USER_NOT_FOUND ErrorCode = ErrorCode{6, "", func(s string) string {return "Invalid user ID. " + s}}
	ERROR_CODE_INVALID_REQUEST ErrorCode = ErrorCode{101, "", func(s string) string {return "Invalid request: " + s}}
	ERROR_CODE_NOT_FOUND_MODEL ErrorCode = ErrorCode{101, "", func(s string) string {return "Model not found: " + s}}
	ERROR_CODE_INTERNAL_SERVER ErrorCode = ErrorCode{500, "Internal server error", nil}
)
