package domain

import (
	"github.com/pkg/errors"
)

type FatalError struct {
	Message string
}

func (e *FatalError) Error() string {
	return e.Message
}

func IsFatal(err error) bool {
	_, ok := errors.Cause(err).(*FatalError)
	return ok
}

type SomeError struct {
	Message string
}

func (e *SomeError) Error() string {
	return e.Message
}

func IsSome(err error) bool {
	_, ok := errors.Cause(err).(*SomeError)
	return ok
}
