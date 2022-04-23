package application

import (
	"encoding/json"
	"fmt"

	"go-send-sqs-lambda/domain"

	"github.com/pkg/errors"
)

func HandleEvent(payload []byte) (*domain.MessageBody, error) {
	var payloadMap map[string]interface{}
	if err := json.Unmarshal(payload, &payloadMap); err != nil {
		err = errors.Wrap(err, "Failed unmarshal payload.")
		fmt.Printf("%+v\n", err)
		return nil, err
	}

	record := payloadMap["Records"].([]interface{})[0].(map[string]interface{})
	s3 := record["s3"].(map[string]interface{})

	bucket := s3["bucket"].(map[string]interface{})["name"].(string)
	key := s3["object"].(map[string]interface{})["key"].(string)

	messageBody := domain.MessageBody{
		Bucket: bucket,
		Key:    key,
	}
	return &messageBody, nil
}
