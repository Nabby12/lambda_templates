package queue

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
)

func (qr QueueRepository) DeleteMsg(toUrl string, msgs ...*sqs.Message) error {
	delParams := sqs.DeleteMessageInput{
		QueueUrl: aws.String(toUrl),
	}

	for i, msg := range msgs {
		delParams.ReceiptHandle = msg.ReceiptHandle
		_, err := qr.DeleteMessage(&delParams)
		if err != nil {
			return err
		}

		fmt.Printf("message deleted %v: %v\n", i, *msg.Body)
	}

	return nil
}
