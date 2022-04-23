package secret

import (
	"os"

	"go-send-sqs-lambda/domain/repository"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
)

type SecretRepository struct {
	*session.Session
}

func NewSecretRepository() (repository.SecretRepository, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(os.Getenv("AWS_REGION"))},
	)

	return &SecretRepository{sess}, err
}
