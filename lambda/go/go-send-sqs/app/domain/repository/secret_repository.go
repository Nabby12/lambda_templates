package repository

type SecretRepository interface {
	GetSecret(key string) (string, error)
}
