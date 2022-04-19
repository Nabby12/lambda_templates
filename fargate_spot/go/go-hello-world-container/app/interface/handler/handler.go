package handler

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"app/infrastructure"
	"app/infrastructure/config"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
)

type RequestParam struct {
	ParamA string `json:"param_a"`
	ParamB string `json:"param_b"`
}

func Handler(ctx context.Context) {
	sess := config.NewSession()
	sqsSvc := sqs.New(sess, aws.NewConfig().WithEndpoint(os.Getenv("END_POINT")))

	for {
		select {
		case <-ctx.Done():
			fmt.Println("!!! Task Canceled !!!")
			return
		default:
			var req RequestParam

			message, err := infrastructure.ReceiveMessage(sqsSvc)
			if err != nil {
				fmt.Println(err)
			}
			if len(message) == 0 {
				fmt.Println("--- Empty Receive ---")
				continue
			}

			for _, msg := range message {
				err := json.Unmarshal([]byte(*msg.Body), &req)
				if err != nil {
					fmt.Println(err)
					continue
				}
			}

			result, err := Execute(req)
			if err != nil {
				fmt.Printf("execute failed: %v\n", err)
			}
			fmt.Printf("%v\n", result)

			infrastructure.DeleteMessage(sqsSvc, message...)
			time.Sleep(2 * time.Second)
		}
	}
}
