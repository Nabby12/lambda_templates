deps:
	go mod download && go mod tidy

build:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -installsuffix cgo -o bootstrap .

copy:
	cp ./bootstrap $(ARTIFACTS_DIR)

build-GoSendSqsLambda: deps build copy
