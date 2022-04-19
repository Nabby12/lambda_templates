package config

import (
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
)

func NewSession() *session.Session {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		Config: aws.Config{
			Region: aws.String(os.Getenv("AWS_REGION")),
		},
		SharedConfigState: session.SharedConfigEnable,
	}))

	return sess
}
