package core

import (
	"encoding/json"
	"io"
)

func DecodeJson(data interface{}, body io.ReadCloser) (error) {
	decoder := json.NewDecoder(body)
	defer body.Close()

	err := decoder.Decode(&data)

	if err != nil {
		return err
	}

	return nil
}
