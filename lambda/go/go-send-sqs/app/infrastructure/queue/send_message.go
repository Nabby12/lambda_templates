package queue

import (
	"context"
	"encoding/json"
	"fmt"

	"go-send-sqs-lambda/domain"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/pkg/errors"
)

func (qr QueueRepository) SendMessage(ctx context.Context, messageBody *domain.MessageBody, toUrl string) error {
	svc := sqs.New(qr)

	bytes, _ := json.Marshal(&messageBody)
	params := &sqs.SendMessageInput{
		MessageBody: aws.String(string(bytes)),
		QueueUrl:    aws.String(toUrl),
	}
	_, err := svc.SendMessageWithContext(ctx, params)
	if err != nil {
		err = errors.Wrap(err, "Failed send message.")
		fmt.Printf("%+v\n", err)
		return err
	}

	return nil
}
