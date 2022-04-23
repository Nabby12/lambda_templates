package main

import (
	"context"
	"fmt"

	"go-send-sqs-lambda/interface/handler"

	"github.com/aws/aws-lambda-go/lambda"
)

type RawHandler struct {
}

func (rh *RawHandler) Invoke(ctx context.Context, payload []byte) ([]byte, error) {
	result, err := handler.Execute(ctx, payload)
	if err != nil {
		fmt.Printf("%+v\n", err)
		return []byte(""), err
	}

	return []byte(result), nil
}

func main() {
	// lambda.Start(lambdaHandler)
	lambda.StartHandler(&RawHandler{})
}
