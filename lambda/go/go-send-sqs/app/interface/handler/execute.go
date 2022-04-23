package handler

import (
	"context"
	"fmt"
	"time"

	"go-send-sqs-lambda/application"
	"go-send-sqs-lambda/infrastructure/secret"

	"github.com/pkg/errors"
)

func Execute(ctx context.Context, payload []byte) (string, error) {
	now := time.Now()
	fmt.Printf("-- Start Function: %s --\n", now.Format("2006-01-02 15:04:05"))

	fmt.Println("Starting handling event...")

	messageBody, err := application.HandleEvent(payload)
	if err != nil {
		fmt.Printf("%+v\n", err)
		return "", err
	}

	fmt.Println("Finishing handling event.")

	fmt.Println("Starting send queue...")

	secret, err := secret.NewSecretRepository()
	if err != nil {
		err = errors.Wrap(err, "Failed init secret repository.")
		fmt.Printf("%+v\n", err)
		return "", err
	}

	triggerQueueUrl, get_secret_err := secret.GetSecret("TRIGGER_QUEUE_URL")
	if get_secret_err != nil {
		fmt.Printf("%+v\n", get_secret_err)
		return "", get_secret_err
	}

	send_queue_err := application.SendQueue(ctx, messageBody, triggerQueueUrl)
	if send_queue_err != nil {
		// queue送信に失敗した場合、再度送信
		err := application.SendQueue(ctx, messageBody, triggerQueueUrl)
		if err != nil {
			fmt.Printf("%+v\n", err)
			fmt.Println("Failed send trigger queue again")

			// queue送信に再度失敗した場合、dlqに送信
			deadLetterQueueUrl, get_secret_err := secret.GetSecret("DEAD_LETTER_QUEUE_URL")
			if get_secret_err != nil {
				fmt.Printf("%+v\n", get_secret_err)
				return "", get_secret_err
			}

			dlq_err := application.SendQueue(ctx, messageBody, deadLetterQueueUrl)
			if dlq_err != nil {
				fmt.Printf("%+v\n", dlq_err)
				fmt.Println("Failed send dlq")
			}
		} else {
			fmt.Println("Succeeded send queue again.")
			fmt.Println("Finishing send queue.")

			fmt.Println("Time: ", time.Since(now).Milliseconds(), "ms")
			fmt.Printf("-- Exit Function: %s --\n", now.Format("2006-01-02 15:04:05"))

			return "", nil
		}

		fmt.Printf("%+v\n", send_queue_err)
		return "", send_queue_err
	}

	fmt.Println("Finishing send queue.")

	fmt.Println("Time: ", time.Since(now).Milliseconds(), "ms")
	fmt.Printf("-- Exit Function: %s --\n", now.Format("2006-01-02 15:04:05"))

	return "", nil
}
