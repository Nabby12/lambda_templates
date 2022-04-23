package repository

import (
	"context"

	"go-send-sqs-lambda/domain"
)

type QueueRepository interface {
	SendMessage(ctx context.Context, messageBody *domain.MessageBody, toUrl string) error
}
