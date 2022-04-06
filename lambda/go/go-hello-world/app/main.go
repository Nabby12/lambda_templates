package main

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Key string `json:"key"`
}

func handler(ctx context.Context, event MyEvent) (string, error) {
	now := time.Now()
	fmt.Printf("-- Start job %s --\n", now.Format("2006-01-02 15:04:05"))

	fmt.Printf("%s!\n", event.Key)

	fmt.Println("Time: ", time.Since(now).Milliseconds(), "ms")
	fmt.Printf("-- Finish job %s --\n", now.Format("2006-01-02 15:04:05"))

	return "exit function", nil
}

func main() {
	lambda.Start(handler)
}
