FROM rust:latest as builder

ENV ARCH=x86_64-unknown-linux-musl
WORKDIR /app

RUN apt-get update -y && \
    apt-get install -y musl-tools && \
    rustup target add ${ARCH}

COPY ./app/ /app/

RUN PKG_CONFIG_ALLOW_CROSS=1 cargo build --release --target ${ARCH} && \
    mkdir bin && \
    cp ./target/${ARCH}/release/bootstrap ./bin/bootstrap

CMD ["/bin/sh"]

FROM public.ecr.aws/sam/build-provided.al2:latest-x86_64 as runner

ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie

RUN chmod 755 /usr/bin/aws-lambda-rie

COPY --from=builder /app/bin/bootstrap .

ENTRYPOINT [ "/usr/bin/aws-lambda-rie" ]
