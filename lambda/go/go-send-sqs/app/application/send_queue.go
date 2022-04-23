package application

import (
	"context"
	"fmt"

	"go-send-sqs-lambda/domain"
	"go-send-sqs-lambda/infrastructure/queue"

	"github.com/pkg/errors"
)

func SendQueue(ctx context.Context, messageBody *domain.MessageBody, toUrl string) error {
	queue, err := queue.NewQueueRepository()
	if err != nil {
		err = errors.Wrap(err, "Failed init queue repository.")
		fmt.Printf("%+v\n", err)
		return err
	}

	send_message_err := queue.SendMessage(ctx, messageBody, toUrl)
	if send_message_err != nil {
		fmt.Printf("%+v\n", send_message_err)
		return send_message_err
	}

	return nil
}
