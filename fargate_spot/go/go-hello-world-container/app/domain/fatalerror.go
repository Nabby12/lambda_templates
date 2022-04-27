package domain

import (
	"github.com/pkg/errors"
)

type FatalErr struct {
	Message string
}

func (e *FatalErr) Error() string {
	return e.Message
}

func (e *FatalErr) FatalError() bool {
	return true
}

func IsFatal(err error) bool {
	_, ok := errors.Cause(err).(*FatalErr)
	return ok
}
