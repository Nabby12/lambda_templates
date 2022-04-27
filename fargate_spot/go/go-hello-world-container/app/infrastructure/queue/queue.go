package queue

import (
	"fmt"
	"os"

	"app/domain/repository"
	"app/infrastructure/config"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/pkg/errors"
)

type QueueRepository struct {
	*sqs.SQS
}

func NewQueueRepository() (repository.QueueRepository, error) {
	sess, err := config.NewSession()
	if err != nil {
		err = errors.Wrap(err, "Failed init queue repository.")
		fmt.Printf("%+v\n", err)
		return nil, err
	}

	svc := sqs.New(
		sess,
		aws.NewConfig().WithEndpoint(os.Getenv("SQS_END_POINT")).WithS3ForcePathStyle(true),
	)

	return &QueueRepository{svc}, err
}
