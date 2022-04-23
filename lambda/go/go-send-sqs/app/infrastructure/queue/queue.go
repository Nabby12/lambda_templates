package queue

import (
	"os"

	"go-send-sqs-lambda/domain/repository"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
)

type QueueRepository struct {
	*session.Session
}

func NewQueueRepository() (repository.QueueRepository, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(os.Getenv("AWS_REGION"))},
	)

	return &QueueRepository{sess}, err
}
