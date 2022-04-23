package secret

import (
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ssm"
	"github.com/pkg/errors"
)

func (sr SecretRepository) GetSecret(key string) (string, error) {
	svc := ssm.New(sr)

	parameterKey := fmt.Sprintf("/%v/%v/%v", os.Getenv("SSM_PATH"), os.Getenv("ENV"), key)

	res, err := svc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String(parameterKey),
		WithDecryption: aws.Bool(true),
	})
	if err != nil {
		err = errors.Wrap(err, "Failed get secret.")
		fmt.Printf("%+v\n", err)
		return "", err
	}

	return *res.Parameter.Value, nil
}
