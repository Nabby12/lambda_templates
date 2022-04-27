package queue

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
)

func (qr QueueRepository) ReceiveMsg(toUrl string) ([]*sqs.Message, error) {
	rcvParams := sqs.ReceiveMessageInput{
		MaxNumberOfMessages: aws.Int64(1),
		QueueUrl:            aws.String(toUrl),
		WaitTimeSeconds:     aws.Int64(20),
	}

	res, err := qr.ReceiveMessage(&rcvParams)
	if err != nil {
		return nil, err
	}

	for i, msg := range res.Messages {
		fmt.Printf("message received %v: %v\n", i, *msg.Body)
	}

	return res.Messages, nil
}
