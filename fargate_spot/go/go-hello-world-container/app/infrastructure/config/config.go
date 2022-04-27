package config

import (
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/pkg/errors"
)

func NewSession() (*session.Session, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(os.Getenv("AWS_DEFAULT_REGION"))},
	)

	if err != nil {
		err := errors.Wrap(err, "Failed init session.")
		fmt.Printf("%+v\n", err)
		return nil, err
	}

	return sess, err
}
