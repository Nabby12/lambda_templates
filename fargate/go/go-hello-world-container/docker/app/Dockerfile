FROM golang:1.18-alpine as builder

ENV TZ=Asia/Tokyo
WORKDIR /go/src/app/

COPY ./app/ ./

RUN apk update && \
    apk add --no-cache git alpine-sdk tzdata && \
    go mod download && \
    go mod tidy && \
    CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -installsuffix cgo -o main .

CMD ["go", "run", "./main.go"]

FROM gcr.io/distroless/static as runner

COPY --from=builder /go/src/app/main ./main

CMD ["./main"]
