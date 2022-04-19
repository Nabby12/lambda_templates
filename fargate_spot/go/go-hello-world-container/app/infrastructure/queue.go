package infrastructure

import (
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
)

var (
	FromSqsUrl = os.Getenv("FROM_SQS_URL")
)

func ReceiveMessage(svc *sqs.SQS) ([]*sqs.Message, error) {
	rcvParams := sqs.ReceiveMessageInput{
		MaxNumberOfMessages: aws.Int64(1),
		QueueUrl:            aws.String(FromSqsUrl),
		WaitTimeSeconds:     aws.Int64(20),
	}

	res, err := svc.ReceiveMessage(&rcvParams)
	if err != nil {
		return nil, err
	}

	for i, msg := range res.Messages {
		fmt.Printf("message received %v: %v\n", i, *msg.Body)
	}

	return res.Messages, nil
}

func DeleteMessage(svc *sqs.SQS, msgs ...*sqs.Message) error {
	delParams := sqs.DeleteMessageInput{
		QueueUrl: aws.String(FromSqsUrl),
	}

	for i, msg := range msgs {
		delParams.ReceiptHandle = msg.ReceiptHandle
		_, err := svc.DeleteMessage(&delParams)
		if err != nil {
			return err
		}

		fmt.Printf("message deleted %v: %v\n", i, *msg.Body)
	}

	return nil
}
