FROM golang:1.18-alpine as builder

ENV TZ=Asia/Tokyo
WORKDIR /go/src/app/

COPY ./app/ ./

RUN apk update && \
    apk add --no-cache git alpine-sdk tzdata && \
    go mod download && \
    go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bootstrap .

CMD ["/bin/sh"]

FROM public.ecr.aws/sam/build-provided.al2:latest-x86_64 as runner

ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie

RUN chmod 755 /usr/bin/aws-lambda-rie

COPY --from=builder /go/src/app/bootstrap .

ENTRYPOINT [ "/usr/bin/aws-lambda-rie" ]
