package repository

import (
	"github.com/aws/aws-sdk-go/service/sqs"
)

type QueueRepository interface {
	ReceiveMsg(toUrl string) ([]*sqs.Message, error)
	DeleteMsg(toUrl string, msgs ...*sqs.Message) error
}
